defmodule MsnrApi.StudentRegistrations.StudentRegistration do
  use Ecto.Schema
  import Ecto.Changeset

  schema "student_registrations" do
    field :email, :string
    field :first_name, :string
    field :index_number, :string
    field :last_name, :string
    field :status, Ecto.Enum, values: [:accepted, :rejected, :pending], default: :pending
    belongs_to :semester, MsnrApi.Semesters.Semester

    timestamps()
  end

  @doc false
  def changeset(student_registration, attrs) do
    student_registration
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end

  @doc false
  def changeset_insert(student_registration, attrs) do
    student_registration
    |> cast(attrs, [:email, :first_name, :last_name, :index_number, :status])
    |> validate_required([:email, :first_name, :last_name, :index_number, :status])
    |> put_assoc(:semester, MsnrApi.Semesters.get_active_semester!())
  end
end
