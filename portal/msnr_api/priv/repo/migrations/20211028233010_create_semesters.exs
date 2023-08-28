defmodule MsnrApi.Repo.Migrations.CreateSemesters do
  use Ecto.Migration

  def change do
    create table(:semesters) do
      add :year, :integer
      add :is_active, :boolean, default: false, null: false

      timestamps()
    end

    create index(:semesters, [:is_active],
             where: "is_active = true",
             unique: true,
             name: :active_semester_index
           )
  end
end
