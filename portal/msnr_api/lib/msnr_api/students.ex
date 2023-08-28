defmodule MsnrApi.Students do
  @moduledoc """
  The Students context.
  """

  import Ecto.Query, warn: false
  alias MsnrApi.Repo

  alias MsnrApi.Accounts.User
  alias MsnrApi.Students.Student
  alias MsnrApi.Students.StudentSemester

  @doc """
  Returns the list of students.

  ## Examples

      iex> list_students()
      [%Student{}, ...]

  """
  def list_students(semester_id) do
    from(ss in StudentSemester,
      join: s in Student,
      on: ss.semester_id == ^semester_id and ss.student_id == s.user_id,
      join: u in assoc(s, :user),
      preload: [student: {s, user: u}],
      select: ss
    )
    |> Repo.all()
  end

  @doc """
  Gets a single student.

  Raises `Ecto.NoResultsError` if the Student does not exist.

  ## Examples

      iex> get_student!(123)
      %Student{}

      iex> get_student!(456)
      ** (Ecto.NoResultsError)

  """
  def get_student!(id) do
    from(s in Student,
      where: s.user_id == ^id,
      join: u in assoc(s, :user),
      preload: [user: u],
      select: s
    )
    |> Repo.one!()
  end

  @doc """
  Creates a student.

  ## Examples

      iex> create_student(%{field: value})
      {:ok, %Student{}}

      iex> create_student(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_student(%User{} = user, attrs \\ %{}) do
    Student.changeset(user, attrs) |> Repo.insert()
  end

  @doc """
  Updates a student.

  ## Examples

      iex> update_student(student, %{field: new_value})
      {:ok, %Student{}}

      iex> update_student(student, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

      TO DO: ispravi updae
  """
  def update_student(student, attrs) do
    student
    |> Student.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a student.

  ## Examples

      iex> delete_student(student)
      {:ok, %Student{}}

      iex> delete_student(student)
      {:error, %Ecto.Changeset{}}

  """
  def delete_student(%Student{} = student) do
    Repo.delete(student)
  end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking student changes.

  # ## Examples

  #     iex> change_student(student)
  #     %Ecto.Changeset{data: %Student{}}

  # """
  # def change_student(%Student{} = student, attrs \\ %{}) do
  #   Student.changeset(student, attrs)
  # end
end
