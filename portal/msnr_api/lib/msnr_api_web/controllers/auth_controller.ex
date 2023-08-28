defmodule MsnrApiWeb.AuthController do
  use MsnrApiWeb, :controller
  import Plug.Conn
  import MsnrApi.Accounts, only: [authenticate: 2, verify_user: 1]

  alias MsnrApi.Accounts.User
  alias MsnrApi.Repo
  alias MsnrApiWeb.Authentication

  action_fallback MsnrApiWeb.FallbackController

  @refresh_token "refresh_token"

  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, user_info} <- authenticate(email, password) do
      return_tokens(conn, user_info)
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_resp_cookie(@refresh_token)
    |> send_resp(:no_content, "")
  end

  def refresh(conn, _params) do
    with {:ok, user_info} <- get_user_by_token(conn.req_cookies[@refresh_token]) do
      return_tokens(conn, user_info)
    end
  end

  defp get_user_by_token(token) do
    case MsnrApiWeb.Authentication.verify_refresh_token(token) do
      {:ok, %{id: id, uuid: uuid}} -> verify_user(%{id: id, refresh_token: uuid})
      _ -> {:error, :unauthorized}
    end
  end

  defp return_tokens(conn, user_info) do
    with {:ok, refresh_token} <- create_refresh_token(user_info.user) do
      conn
      |> set_refresh_cookie(refresh_token)
      |> render("login.json", user_info)
    end
  end

  defp create_refresh_token(user) do
    uuid = Ecto.UUID.generate()
    changeset = User.changeset_token(user, %{refresh_token: uuid})

    case Repo.update(changeset) do
      {:ok, user} -> {:ok, signed_token(user, uuid)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp signed_token(user, uuid), do: Authentication.sign(%{id: user.id, uuid: uuid})

  defp set_refresh_cookie(conn, refresh_token) do
    opts = [
      max_age: Application.get_env(:msnr_api, :refresh_token_expiration),
      secure: Application.get_env(:msnr_api, :secure_cookie)
    ]

    put_resp_cookie(conn, @refresh_token, refresh_token, opts)
  end
end
