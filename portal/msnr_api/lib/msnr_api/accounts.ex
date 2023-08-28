defmodule MsnrApi.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias MsnrApi.Repo

  alias MsnrApi.Accounts.User
  alias MsnrApi.Students.StudentSemester
  alias MsnrApi.Semesters.Semester
  alias MsnrApi.Accounts.Password
  alias MsnrApi.StudentRegistrations.StudentRegistration

  def authenticate(email, password) do
    user_info = get_user_info(email: email)

    with %{user: %{hashed_password: hash}} <- user_info,
         true <- Password.verify_with_hash(password, hash) do
      {:ok, user_info}
    else
      _ -> {:error, :unauthorized}
    end
  end

  def verify_user(%{id: id, refresh_token: token}) do
    case get_user_info(id: id, refresh_token: token) do
      nil -> {:error, :unauthorized}
      user_info -> {:ok, user_info}
    end
  end

  def verify_user(%{email: email, uuid: uuid}) do
    case Repo.get_by(User, email: email, password_url_path: uuid) do
      nil -> {:error, :unauthorized}
      user -> {:ok, user}
    end
  end

  def set_password(user, password) do
    user
    |> User.changeset_password(%{password: password})
    |> Repo.update()
  end

  def get_user_info(where_clause) do
    student_query = create_student_query(where_clause)

    query =
      from u in User,
        where: u.role == :professor,
        where: ^where_clause,
        select: %{
          user: u,
          semester_id: nil,
          student_info: %{
            index_number: nil,
            group_id: nil
          }
        },
        union_all: ^student_query

    user_info = Repo.one(query)

    case user_info do
      %{semester_id: nil} ->
        Map.put(user_info, :semester_id, MsnrApi.Semesters.get_active_semester!().id)

      _ ->
        user_info
    end
  end

  defp create_student_query(where_clause) do
    from u in User,
      where: u.role == :student,
      where: ^where_clause,
      join: st in assoc(u, :student),
      join: st_sem in StudentSemester,
      on: st_sem.student_id == u.id,
      join: sem in Semester,
      on: sem.is_active and sem.id == st_sem.semester_id,
      select: %{
        user: u,
        semester_id: sem.id,
        student_info: %{
          index_number: st.index_number,
          group_id: st_sem.group_id
        }
      }
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def create_student_account(%StudentRegistration{} = registration) do
    %User{}
    |> User.changeset(registration)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
