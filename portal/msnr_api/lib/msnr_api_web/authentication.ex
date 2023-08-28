defmodule MsnrApiWeb.Authentication do
  @salt "user_auth"
  @access_token_expiration Application.get_env(:msnr_api, :access_token_expiration)
  @refresh_token_expiration Application.get_env(:msnr_api, :refresh_token_expiration)

  def sign(data) do
    Phoenix.Token.sign(MsnrApiWeb.Endpoint, @salt, data)
  end

  def verify_access_token(token) do
    Phoenix.Token.verify(MsnrApiWeb.Endpoint, @salt, token, max_age: @access_token_expiration)
  end

  def verify_refresh_token(token) do
    Phoenix.Token.verify(MsnrApiWeb.Endpoint, @salt, token, max_age: @refresh_token_expiration)
  end
end
