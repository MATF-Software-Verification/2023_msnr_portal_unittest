defmodule MsnrApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias MsnrApi.StudentRegistrations.StudentRegistration

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :hashed_password, :string
    field :password, :string, virtual: true
    field :password_url_path, Ecto.UUID, autogenerate: true
    field :refresh_token, Ecto.UUID, autogenerate: true
    field :role, Ecto.Enum, values: [:student, :professor]
    has_one :student, MsnrApi.Students.Student

    timestamps()
  end

  def changeset(user, %StudentRegistration{} = student_registration) do
    student_attrs =
      student_registration
      |> Map.from_struct()
      |> Map.put(:role, :student)

    changeset(user, student_attrs)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :first_name, :last_name, :role])
    |> validate_required([:email, :first_name, :last_name, :role])
    |> unique_constraint(:email)
  end

  def changeset_password(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:password])
    |> validate_required(:password)
    |> validate_length(:password, min: 4)
    |> hash_password()
    |> changeset(attrs)
  end

  def changeset_token(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:refresh_token])
    |> validate_required(:refresh_token)
    |> changeset(attrs)
  end

  defp hash_password(%Ecto.Changeset{changes: %{password: password}} = changeset) do
    changeset
    |> put_change(:hashed_password, MsnrApi.Accounts.Password.hash(password))
  end

  defp hash_password(changeset), do: changeset
end
