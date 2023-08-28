defmodule MsnrApiWeb.AuthView do
  use MsnrApiWeb, :view
  alias MsnrApi.Accounts.TokenPayload
  alias MsnrApi.Accounts.User
  alias MsnrApiWeb.Authentication

  def render(
        "login.json",
        %{user: %User{} = user, student_info: s, semester_id: sem_id} = user_info
      ) do
    json_result = %{
      access_token: Authentication.sign(TokenPayload.from_user_info(user_info)),
      expires_in: Application.get_env(:msnr_api, :access_token_expiration),
      user: %{
        id: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        role: user.role
      },
      semester_id: sem_id
    }

    case user.role do
      :student ->
        Map.put(
          json_result,
          :student_info,
          %{
            index_number: s.index_number,
            group_id: s.group_id
          }
        )

      _ ->
        json_result
    end
  end
end
