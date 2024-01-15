defmodule RealDealApiWeb.AccountController do
  use RealDealApiWeb, :controller

  alias RealDealApi.{Users, Users.User, Accounts, Accounts.Account}
  alias RealDealApiWeb.Auth.{Guardian, ErrorResponse}

  import RealDealApiWeb.Auth.AuthorizedPlug

  plug :is_authorized when action in [:update, :delete]

  action_fallback RealDealApiWeb.FallbackController

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, :index, accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.create_account(account_params),
         {:ok, %User{} = _user} <- Users.create_user(account, account_params) do
      authorize_account(conn, account.email, account_params["hashed_password"])
    end
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_full_account(id)

    render(conn, :show, account: account)
  end

  def current_account_session(conn, %{}) do
    conn
    |> put_status(:ok)
    |> render(:show, account: conn.assigns.account)
  end

  def update(conn, %{"current_hash" => current_hash, "account" => account_params}) do
    case Guardian.validate_password(current_hash, conn.assigns.account.hashed_password) do
      true ->
        {:ok, %Account{} = account} =
          Accounts.update_account(conn.assigns.account, account_params)

        render(conn, :show, account: account)

      false ->
        raise ErrorResponse.Unauthorized
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end

  def sign_in(conn, %{"email" => email, "password" => hashed_password}) do
    authorize_account(conn, email, hashed_password)
  end

  defp authorize_account(conn, email, hashed_password) do
    case Guardian.authenticate(email, hashed_password) do
      {:ok, account, token} ->
        conn
        |> put_status(:ok)
        |> put_session(:account_id, account.id)
        |> render(:show, %{account: account, token: token})

      {:error, :unauthorized} ->
        raise ErrorResponse.Unauthorized, "Email or Password incorrect."
    end
  end

  def sign_out(conn, %{}) do
    account = conn.assigns[:account]

    token = Guardian.Plug.current_token(conn)
    Guardian.revoke(token)

    conn
    |> clear_session()
    |> put_status(:ok)
    |> render(:show, %{account: account})
  end

  def refresh_session(conn, %{}) do
    token = Guardian.Plug.current_token(conn)
    {:ok, account, new_token} = Guardian.authenticate(token)

    conn
    |> put_session(:account_id, account.id)
    |> put_status(:ok)
    |> render(:show, %{account: account, token: new_token})
  end
end
