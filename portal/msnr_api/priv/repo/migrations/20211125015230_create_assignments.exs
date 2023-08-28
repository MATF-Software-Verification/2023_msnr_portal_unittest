defmodule MsnrApi.Repo.Migrations.CreateAssignments do
  use Ecto.Migration

  def change do
    create table(:assignments) do
      add :grade, :integer
      add :comment, :string
      add :completed, :boolean, default: false, null: false
      add :student_id, references(:students, on_delete: :nothing, column: :user_id)
      add :group_id, references(:groups, on_delete: :nothing)
      add :activity_id, references(:activities, on_delete: :nothing)
      add :related_topic_id, references(:topics, on_delete: :nothing)

      timestamps()
    end

    create index(:assignments, [:student_id])
    create index(:assignments, [:group_id])
    create index(:assignments, [:activity_id])
  end
end
