defmodule MsnrApi.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities) do
      add :start_date, :integer
      add :end_date, :integer
      add :points, :integer
      add :is_signup, :boolean, default: false, null: false
      add :semester_id, references(:semesters, on_delete: :nothing)
      add :activity_type_id, references(:activity_types, on_delete: :nothing)

      timestamps()
    end

    create index(:activities, [:semester_id])
    create index(:activities, [:activity_type_id])
    create unique_index(:activities, [:semester_id, :activity_type_id, :is_signup])
  end
end
