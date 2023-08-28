defmodule MsnrApi.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :title, :string
      add :number, :integer
      add :semester_id, references(:semesters, on_delete: :nothing)

      timestamps()
    end

    create index(:topics, [:semester_id])
  end
end
