defmodule MsnrApiWeb.PasswordController do
  use MsnrApiWeb, :controller

  alias MsnrApi.Accounts

  action_fallback MsnrApiWeb.FallbackController

  def update(conn, %{"id" => uuid, "email" => email, "password" => password}) do
    with {:ok, user} <- Accounts.verify_user(%{email: email, uuid: uuid}),
         {:ok, _} <- Accounts.set_password(user, password) do
      send_resp(conn, :no_content, "")
    end
  end
end
