defmodule MsnrApiWeb.SignupController do
  use MsnrApiWeb, :controller
  import Plug.Conn

  action_fallback MsnrApiWeb.FallbackController

  alias MsnrApi.Assignments

  def update(conn, %{"id" => id, "signed_up" => signed_up}) do
    with {:ok, signup} <- Assignments.get_signup(id),
         {:ok, _} <- Assignments.update_signup(signup, signed_up) do
      send_resp(conn, :no_content, "")
    end
  end
end
