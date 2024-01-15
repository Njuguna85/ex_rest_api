defmodule RealDealApiWeb.Auth.Guardian do
  use Guardian, otp_app: :real_deal_api
  alias RealDealApi.Accounts

  def subject_for_token(%{id: id}, _claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_, _), do: {:error, :no_id_provided}

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_account!(id) do
      nil ->
        {:error, :not_found}

      resource ->
        {:ok, resource}
    end
  end

  def resource_from_claims(_claims), do: {:error, :no_id_provided}

  def authenticate(email, password) do
    case Accounts.get_account_by_email(email) do
      nil ->
        {:error, :unauthorized}

      account ->
        case validate_password(password, account.hashed_password) do
          false ->
            {:error, :unauthorized}

          true ->
            create_token(account, :access)
        end
    end
  end

  def authenticate(token) do
    with {:ok, claims} <- decode_and_verify(token),
         {:ok, account} <- resource_from_claims(claims),
         {:ok, _old, {new_token, _new_claims}} <-
           refresh(token) do
      {:ok, account, new_token}
    end
  end

  def validate_password(password, hashed_password) do
    Bcrypt.verify_pass(password, hashed_password)
  end

  defp create_token(account, type) do
    {:ok, token, _claims} = encode_and_sign(account, %{}, token_options(type))

    {:ok, account, token}
  end

  defp token_options(type) do
    case type do
      :access -> [ttl: {2, :hour}, token_type: "access"]
      :reset -> [ttl: {15, :minute}, token_type: "reset"]
      :admin -> [ttl: {90, :day}, token_type: "access"]
    end
  end

  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  def on_verify(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  def on_refresh({old_token, old_claims}, {new_token, new_claims}, _options) do
    with {:ok, _, _} <- Guardian.DB.on_refresh({old_token, old_claims}, {new_token, new_claims}) do
      {:ok, {old_token, old_claims}, {new_token, new_claims}}
    end
  end

  def on_revoke(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
      {:ok, claims}
    end
  end
end
