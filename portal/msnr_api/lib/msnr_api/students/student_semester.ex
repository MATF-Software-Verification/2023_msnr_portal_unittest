defmodule MsnrApi.Students.StudentSemester do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "students_semesters" do
    belongs_to :student, MsnrApi.Students.Student, references: :user_id, primary_key: true
    belongs_to :semester, MsnrApi.Semesters.Semester, primary_key: true
    belongs_to :group, MsnrApi.Groups.Group

    timestamps()
  end

  @doc false
  def changeset(student_semester, attrs) do
    student_semester
    |> cast(attrs, [:student_id, :semester_id])
    |> validate_required([:student_id, :semester_id])
  end
end
