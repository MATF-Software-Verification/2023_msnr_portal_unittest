defmodule MsnrApi.Repo.Migrations.CreateStudentRegistrations do
  use Ecto.Migration

  def change do
    create table(:student_registrations) do
      add :email, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :index_number, :string, null: false
      add :status, :registration_status, null: false
      add :semester_id, references(:semesters, on_delete: :nothing)

      timestamps()
    end

    create index(:student_registrations, [:semester_id])
  end
end
