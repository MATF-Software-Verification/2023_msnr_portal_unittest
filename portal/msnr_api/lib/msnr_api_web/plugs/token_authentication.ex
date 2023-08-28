defmodule MsnrApiWeb.Plugs.TokenAuthentication do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, payload} <- MsnrApiWeb.Authentication.verify_access_token(token) do
      assign(conn, :user_info, payload)
    else
      _ ->
        assign(conn, :user_info, nil)
    end
  end
end
