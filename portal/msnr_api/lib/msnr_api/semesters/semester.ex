defmodule MsnrApi.Semesters.Semester do
  use Ecto.Schema
  import Ecto.Changeset

  schema "semesters" do
    field :is_active, :boolean, default: false
    field :year, :integer

    has_many :topics, MsnrApi.Topics.Topic
    has_many :student_registrations, MsnrApi.StudentRegistrations.StudentRegistration

    # many_to_many :students, MsnrApi.Students.Student,
    # join_through: MsnrApi.Students.StudentSemester,
    # join_keys: [semester_id: :id, student_id: :user_id]

    has_many :student_semester, MsnrApi.Students.StudentSemester
    has_many :groups, through: [:student_semester, :group]
    has_many :students, through: [:student_semester, :student]

    timestamps()
  end

  @doc false
  def changeset(semester, attrs) do
    semester
    |> cast(attrs, [:year, :is_active])
    |> validate_required([:year, :is_active])
  end
end
