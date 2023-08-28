defmodule MsnrApi.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MsnrApi.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        first_name: "some first_name",
        hashed_password: "some hashed_password",
        last_name: "some last_name",
        password_url_path: "7488a646-e31f-11e4-aace-600308960662",
        refresh_token: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> MsnrApi.Accounts.create_user()

    user
  end
end
