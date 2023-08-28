defmodule MsnrApi.Repo.Migrations.CreateStudents do
  use Ecto.Migration

  def change do
    create table(:students, primary_key: false) do
      add :user_id, references(:users, on_delete: :nothing), primary_key: true
      add :index_number, :string, null: false

      timestamps()
    end

    create index(:students, [:user_id])
    create unique_index(:students, [:index_number])
  end
end
