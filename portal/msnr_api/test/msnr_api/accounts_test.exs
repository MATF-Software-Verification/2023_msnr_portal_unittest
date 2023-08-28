defmodule MsnrApi.AccountsTest do
  use MsnrApi.DataCase

  alias MsnrApi.Accounts

  describe "users" do
    alias MsnrApi.Accounts.User

    import MsnrApi.AccountsFixtures

    @invalid_attrs %{
      email: nil,
      first_name: nil,
      hashed_password: nil,
      last_name: nil,
      password_url_path: nil,
      refresh_token: nil
    }

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        email: "some email",
        first_name: "some first_name",
        hashed_password: "some hashed_password",
        last_name: "some last_name",
        password_url_path: "7488a646-e31f-11e4-aace-600308960662",
        refresh_token: "7488a646-e31f-11e4-aace-600308960662"
      }

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.email == "some email"
      assert user.first_name == "some first_name"
      assert user.hashed_password == "some hashed_password"
      assert user.last_name == "some last_name"
      assert user.password_url_path == "7488a646-e31f-11e4-aace-600308960662"
      assert user.refresh_token == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      update_attrs = %{
        email: "some updated email",
        first_name: "some updated first_name",
        hashed_password: "some updated hashed_password",
        last_name: "some updated last_name",
        password_url_path: "7488a646-e31f-11e4-aace-600308960668",
        refresh_token: "7488a646-e31f-11e4-aace-600308960668"
      }

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.email == "some updated email"
      assert user.first_name == "some updated first_name"
      assert user.hashed_password == "some updated hashed_password"
      assert user.last_name == "some updated last_name"
      assert user.password_url_path == "7488a646-e31f-11e4-aace-600308960668"
      assert user.refresh_token == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
