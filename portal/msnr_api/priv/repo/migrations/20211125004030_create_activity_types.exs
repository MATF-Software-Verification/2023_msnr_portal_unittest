defmodule MsnrApi.Repo.Migrations.CreateActivityTypes do
  use Ecto.Migration

  def change do
    create table(:activity_types) do
      add :name, :string, null: false
      add :code, :string, null: false
      add :description, :string, null: false
      add :has_signup, :boolean, default: false, null: false
      add :is_group, :boolean, default: false, null: false
      add :content, :map

      timestamps()
    end

    create unique_index(:activity_types, [:name])
    create unique_index(:activity_types, [:code])
  end
end
