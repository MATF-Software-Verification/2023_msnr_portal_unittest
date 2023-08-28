defmodule MsnrApi.Students.Student do
  use Ecto.Schema
  import Ecto.Changeset

  alias MsnrApi.Accounts.User
  alias MsnrApi.Semesters.Semester
  alias MsnrApi.Students.StudentSemester

  @primary_key {:user_id, :integer, []}
  schema "students" do
    belongs_to :user, User, define_field: false, foreign_key: :user_id
    field :index_number, :string

    many_to_many :semesters, Semester,
      join_through: StudentSemester,
      join_keys: [student_id: :user_id, semester_id: :id]

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> Ecto.build_assoc(:student)
    |> cast(attrs, [:index_number])
    |> validate_required([:index_number])
    |> unique_constraint([:index_number])
    |> put_assoc(:semesters, [MsnrApi.Semesters.get_active_semester!()])
  end
end
