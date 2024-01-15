defmodule RealDealApi.Schema.AccountTest do
  use ExUnit.Case
  alias Ecto.Changeset
  alias RealDealApi.Accounts.Account

  @expected_fields_with_types [
    {:id, :binary_id},
    {:email, :string},
    {:hashed_password, :string},
    {:inserted_at, :utc_datetime},
    {:updated_at, :utc_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- Account.__schema__(:fields) do
          type = Account.__schema__(:type, field)
          {field, type}
        end

      assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

  describe "changeset/2" do
    test "success: returns a valid changeset when given valid arguments" do
      valid_params = %{
        "id" => Ecto.UUID.generate(),
        "email" => "test@email.com",
        "hashed_password" => "test password"
      }

      changeset = Account.changeset(%Account{}, valid_params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      mutated = [:hashed_password]

      for {field, _type} <- @expected_fields_with_types, field not in mutated do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]

        assert actual == expected,
               "Values did not match for: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert Bcrypt.verify_pass(valid_params["hashed_password"], changes.hashed_password),
             "Password: #{inspect(valid_params["hashed_password"])} does not match\n hashed password: #{inspect(changes.hashed_password)}"
    end

    test "error: returns an error changeset when given invalid arguments" do
      invalid_params = %{
        "id" => nil,
        "email" => nil,
        "hashed_password" => nil
      }

      assert %Changeset{valid?: false, errors: _errors} =
               Account.changeset(%Account{}, invalid_params)
    end

    test "error: returns an error changeset when required fields are missing" do
      invalid_params = %{}

      assert %Changeset{valid?: false, errors: _errors} =
               Account.changeset(%Account{}, invalid_params)
    end
  end
end
