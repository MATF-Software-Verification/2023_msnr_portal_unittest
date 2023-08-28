defmodule MsnrApi.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :topic_id, references(:topics, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:groups, [:topic_id])
  end
end
