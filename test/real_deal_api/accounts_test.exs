defmodule RealDealApi.AccountsTest do
  use RealDealApi.Support.DataCase
  alias RealDealApi.{Accounts, Accounts.Account}

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(RealDealApi.Repo)
  end

  describe "create_account/1" do
    test "success: it inserts an account in the db and returns the account" do
      params = Factory.string_params_for(:account)

      assert {:ok, %Account{} = returned_account} = Accounts.create_account(params)

      account_from_db = Repo.get(Account, returned_account.id)

      assert returned_account == account_from_db

      mutated = ["hashed_password"]

      for {param_field, expected} <- params, param_field not in mutated do
        schema_field = String.to_existing_atom(param_field)
        actual = Map.get(account_from_db, schema_field)

        assert actual == expected,
               "Values did not match for: #{param_field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert Bcrypt.verify_pass(params["hashed_password"], returned_account.hashed_password),
             "Password: #{inspect(params["hashed_password"])} does not match \nhash: #{inspect(returned_account.hashed_password)}"

      assert account_from_db.inserted_at == account_from_db.inserted_at
    end

    test "error: returns an error tuple when account can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = Accounts.create_account(missing_params)
    end
  end

  describe "get_account/1" do
    test "success: returns an account when given a valid UUID" do
      existing_account = Factory.insert(:account)

      assert returned_account = Accounts.get_account!(existing_account.id)
      assert returned_account == existing_account
    end

    test "error: raises an Ecto.NoResultsError when an account doesn't exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_account!(Ecto.UUID.autogenerate())
      end
    end
  end

  describe "update_account/2" do
    test "success: it updates and returns the account" do
      existing_account = Factory.insert(:account)

      params =
        Factory.string_params_for(:account)
        |> Map.take(["email"])

      assert {:ok, returned_account} = Accounts.update_account(existing_account, params)

      account_from_db = Repo.get(Account, returned_account.id)

      assert returned_account == account_from_db

      expected_account_data =
        existing_account
        |> Map.from_struct()
        |> Map.put(:email, params["email"])

      for {field, expected} <- expected_account_data do
        actual = Map.get(account_from_db, field)

        assert actual == expected,
               "Values did not match fpr field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    test "error: returns an error tuple when account can't be updated" do
      existing_account = Factory.insert(:account)

      bad_params = %{"email" => "bad email"}

      assert {:error, %Changeset{}} = Accounts.update_account(existing_account, bad_params)

      assert existing_account === Repo.get(Account, existing_account.id)
    end
  end

  describe "delete_account/1" do
    test "success: it deletes the account" do
      account = Factory.insert(:account)

      assert {:ok, _deleted_account} = Accounts.delete_account(account)

      refute Repo.get(Account, account.id)
    end
  end
end
