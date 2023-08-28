defmodule MsnrApi.StudentRegistrations do
  @moduledoc """
  The StudentRegistrations context.
  """

  import Ecto.Query
  alias MsnrApi.Repo
  alias Ecto.Multi

  alias MsnrApi.StudentRegistrations.StudentRegistration
  alias MsnrApi.Accounts
  alias MsnrApi.Students
  alias MsnrApi.Mailer
  alias MsnrApi.Emails

  @doc """
  Returns the list of student_registrations.

  ## Examples

      iex> list_student_registrations()
      [%StudentRegistration{}, ...]

  """
  def list_student_registrations(semester_id) do
    Repo.all(from sr in StudentRegistration, where: sr.semester_id == ^semester_id)
  end

  @doc """
  Gets a single student_registration.

  Raises `Ecto.NoResultsError` if the Student registration does not exist.

  ## Examples

      iex> get_student_registration!(123)
      %StudentRegistration{}

      iex> get_student_registration!(456)
      ** (Ecto.NoResultsError)

  """
  def get_student_registration!(id), do: Repo.get!(StudentRegistration, id)

  @doc """
  Creates a student_registration.

  ## Examples

      iex> create_student_registration(%{field: value})
      {:ok, %StudentRegistration{}}

      iex> create_student_registration(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_student_registration(attrs \\ %{}) do
    %StudentRegistration{}
    |> StudentRegistration.changeset_insert(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a student_registration.

  ## Examples

      iex> update_student_registration(student_registration, %{field: new_value})
      {:ok, %StudentRegistration{}}

      iex> update_student_registration(student_registration, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_student_registration(
        %StudentRegistration{} = registration,
        %{"status" => "accepted"} = attrs
      ) do
    create_user = fn _repo, %{student_registration: reg} ->
      Accounts.create_student_account(reg)
    end

    create_student = fn _repo, %{user: user} ->
      Students.create_student(user, %{index_number: registration.index_number})
    end

    send_email = fn _repo, %{user: user} ->
      Emails.accept(user) |> Mailer.deliver()
    end

    Multi.new()
    |> Multi.update(:student_registration, StudentRegistration.changeset(registration, attrs))
    |> Multi.run(:user, create_user)
    |> Multi.run(:student, create_student)
    |> Multi.run(:email, send_email)
    |> MsnrApi.Repo.transaction()
  end

  def update_student_registration(
        %StudentRegistration{} = registration,
        %{"status" => "rejected"} = attrs
      ) do
    send_email = fn _repo, _ ->
      Emails.reject(registration) |> Mailer.deliver()
    end

    Multi.new()
    |> Multi.update(:student_registration, StudentRegistration.changeset(registration, attrs))
    |> Multi.run(:email, send_email)
    |> MsnrApi.Repo.transaction()
  end

  @doc """
  Deletes a student_registration.

  ## Examples

      iex> delete_student_registration(student_registration)
      {:ok, %StudentRegistration{}}

      iex> delete_student_registration(student_registration)
      {:error, %Ecto.Changeset{}}

  """
  def delete_student_registration(%StudentRegistration{} = student_registration) do
    Repo.delete(student_registration)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking student_registration changes.

  ## Examples

      iex> change_student_registration(student_registration)
      %Ecto.Changeset{data: %StudentRegistration{}}

  """
  def change_student_registration(%StudentRegistration{} = student_registration, attrs \\ %{}) do
    StudentRegistration.changeset(student_registration, attrs)
  end
end
