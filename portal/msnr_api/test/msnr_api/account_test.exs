defmodule MsnrApi.AccountTest do
  use MsnrApi.DataCase

  alias MsnrApi.Account

  describe "users1" do
    alias MsnrApi.Account.User1

    import MsnrApi.AccountFixtures

    @invalid_attrs %{}

    test "list_users1/0 returns all users1" do
      user1 = user1_fixture()
      assert Account.list_users1() == [user1]
    end

    test "get_user1!/1 returns the user1 with given id" do
      user1 = user1_fixture()
      assert Account.get_user1!(user1.id) == user1
    end

    test "create_user1/1 with valid data creates a user1" do
      valid_attrs = %{}

      assert {:ok, %User1{} = user1} = Account.create_user1(valid_attrs)
    end

    test "create_user1/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_user1(@invalid_attrs)
    end

    test "update_user1/2 with valid data updates the user1" do
      user1 = user1_fixture()
      update_attrs = %{}

      assert {:ok, %User1{} = user1} = Account.update_user1(user1, update_attrs)
    end

    test "update_user1/2 with invalid data returns error changeset" do
      user1 = user1_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_user1(user1, @invalid_attrs)
      assert user1 == Account.get_user1!(user1.id)
    end

    test "delete_user1/1 deletes the user1" do
      user1 = user1_fixture()
      assert {:ok, %User1{}} = Account.delete_user1(user1)
      assert_raise Ecto.NoResultsError, fn -> Account.get_user1!(user1.id) end
    end

    test "change_user1/1 returns a user1 changeset" do
      user1 = user1_fixture()
      assert %Ecto.Changeset{} = Account.change_user1(user1)
    end
  end
end
