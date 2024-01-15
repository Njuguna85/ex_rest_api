defmodule RealDealApiWeb.AccountJSON do
  alias RealDealApi.Accounts.Account

  @doc """
  Renders a list of accounts.
  """
  def index(%{accounts: accounts}) do
    %{data: for(account <- accounts, do: data(account))}
  end

  def show(%{account: account, token: token}) do
    %{
      id: account.id,
      email: account.email,
      token: token,
      user_id: account.user.id
    }
  end

  @doc """
  Renders a single account.
  """
  def show(%{account: account}) do
    %{data: data(account)}
  end

  defp data(%Account{} = account) do
    %{
      id: account.id,
      email: account.email,
      full_name: account.user.full_name,
      biography: account.user.biography,
      gender: account.user.gender
    }
  end
end
