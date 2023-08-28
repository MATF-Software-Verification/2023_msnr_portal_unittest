defmodule MsnrApi.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :file_name, :string
      add :file_path, :string
      add :creator_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:documents, [:creator_id])
  end
end
