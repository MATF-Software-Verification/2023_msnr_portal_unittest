defmodule MsnrApi.Repo.Migrations.CreateAssignmentsDocuments do
  use Ecto.Migration

  def change do
    create table(:assignments_documents, primary_key: false) do
      add :assignment_id, references(:assignments, on_delete: :nothing), primary_key: true
      add :document_id, references(:documents, on_delete: :nothing), primary_key: true
      add :attached, :boolean, default: false, null: false

      timestamps()
    end

    create index(:assignments_documents, [:assignment_id])
    create index(:assignments_documents, [:document_id])
  end
end
