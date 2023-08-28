defmodule MsnrApi.Accounts.TokenPayload do
  alias MsnrApi.Accounts.TokenPayload
  alias MsnrApi.Accounts.User

  defstruct [:id, :role, :group_id, :semester_id]

  def from_user_info(%{user: %User{} = user, student_info: st_info, semester_id: semester_id}) do
    %TokenPayload{
      id: user.id,
      role: user.role,
      group_id: st_info.group_id,
      semester_id: semester_id
    }
  end
end
