defmodule RealDealApi.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  alias RealDealApi.Users.User
  @optional_fields [:id, :inserted_at, :updated_at]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "accounts" do
    field :email, :string
    field :hashed_password, :string
    has_one :user, User

    timestamps(type: :utc_datetime)
  end

  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, all_fields())
    |> validate_required(all_fields() -- @optional_fields)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{hashed_password: hashed_password}} = changeset
       ) do
    change(changeset, hashed_password: Bcrypt.hash_pwd_salt(hashed_password))
  end

  defp put_password_hash(changeset), do: changeset
end
