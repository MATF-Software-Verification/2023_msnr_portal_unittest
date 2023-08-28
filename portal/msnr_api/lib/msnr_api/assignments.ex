defmodule MsnrApi.Assignments do
  @moduledoc """
  The Assignments context.
  """

  import Ecto.Query, warn: false
  alias MsnrApi.Repo

  alias MsnrApi.Assignments.Assignment
  alias MsnrApi.Activities.Activity
  alias MsnrApi.ActivityTypes.ActivityType
  alias MsnrApi.Students.StudentSemester

  @doc """
  Returns the list of assignments.

  ## Examples

      iex> list_assignments()
      [%Assignment{}, ...]

  """

  # def list_assignments(%{"semester_id" => semester_id}) do
  #   from(as in Assignment,
  #     join: a in Activity,
  #     on: a.semester_id == ^semester_id and a.id == as.activity_id,
  #     select: as
  #   )
  #   |> Repo.all
  # end

  def list_assignments(%{
        "student_id" => student_id,
        "semester_id" => semester_id
      }) do
    query =
      from a in Activity,
        join: as in Assignment,
        on: a.semester_id == ^semester_id and a.id == as.activity_id,
        join: ss in StudentSemester,
        on:
          ss.semester_id == a.semester_id and ss.student_id == ^student_id and
            (ss.student_id == as.student_id or ss.group_id == as.group_id),
        join: at in assoc(a, :activity_type),
        select: %{
          activity: a,
          activity_type: at,
          id: as.id,
          grade: as.grade,
          comment: as.comment,
          completed: as.completed
        }

    Repo.all(query)
  end

  def list_assignments(%{"semester_id" => semester_id}) do
    from(a in Activity,
      join: as in Assignment, on: a.semester_id == ^semester_id and a.id == as.activity_id,
      select: as
    )
    |> Repo.all()
  end

  def get_assignment_extended!(id) do
    query =
      from as in Assignment,
        where: as.id == ^id,
        join: a in Activity,
        on: a.id == as.activity_id,
        join: at in ActivityType,
        on: a.activity_type_id == at.id,
        join: s in MsnrApi.Semesters.Semester,
        on: s.id == a.semester_id,
        select: %{
          assignment: as,
          semester_year: s.year,
          start_date: a.start_date,
          end_date: a.end_date,
          content: at.content,
          name: at.name
        }

    Repo.one!(query)
  end

  @doc """
  Gets a single assignment.

  Raises `Ecto.NoResultsError` if the Students activity does not exist.

  ## Examples

      iex> get_assignment!(123)
      %Assignment{}

      iex> get_assignment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_assignment!(id), do: Repo.get!(Assignment, id)

  @doc """
  Creates a assignment.

  ## Examples

      iex> create_assignment(%{field: value})
      {:ok, %Assignment{}}

      iex> create_assignment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_assignment(attrs \\ %{}) do
    %Assignment{}
    |> Assignment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a assignment.

  ## Examples

      iex> update_assignment(assignment, %{field: new_value})
      {:ok, %Assignment{}}

      iex> update_assignment(assignment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_assignment(%Assignment{} = assignment, attrs) do
    assignment
    |> Assignment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a assignment.

  ## Examples

      iex> delete_assignment(assignment)
      {:ok, %Assignment{}}

      iex> delete_assignment(assignment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_assignment(%Assignment{} = assignment) do
    Repo.delete(assignment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking assignment changes.

  ## Examples

      iex> change_assignment(assignment)
      %Ecto.Changeset{data: %Assignment{}}

  """
  def change_assignment(%Assignment{} = assignment, attrs \\ %{}) do
    Assignment.changeset(assignment, attrs)
  end

  def get_signup(id) do
    query =
      from as in Assignment,
        join: ac in Activity,
        on: as.id == ^id and as.activity_id == ac.id and ac.is_signup == true,
        select: as

    case Repo.one(query) do
      nil -> {:error, :not_found}
      signup -> {:ok, signup}
    end
  end

  def update_signup(%Assignment{} = assignment, signed_up) do
    assignment
    |> Assignment.signup_changeset(%{completed: signed_up})
    |> Repo.update()
  end
end
