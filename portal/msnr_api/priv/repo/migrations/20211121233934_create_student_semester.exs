defmodule MsnrApi.Repo.Migrations.CreateStudentsSemesters do
  use Ecto.Migration

  def change do
    create table(:students_semesters, primary_key: false) do
      add :student_id,
          references(:students, on_delete: :nothing, column: :user_id, primary_key: true)

      add :semester_id, references(:semesters, on_delete: :nothing, primary_key: true)
      add :group_id, references(:groups, on_delete: :nothing)

      timestamps()
    end

    create index(:students_semesters, [:student_id, :semester_id])
    create index(:students_semesters, [:group_id])
  end
end
