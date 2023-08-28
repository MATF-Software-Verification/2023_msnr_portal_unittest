defmodule MsnrApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :hashed_password, :string
      add :refresh_token, :uuid, null: false
      add :password_url_path, :uuid, null: false
      add :role, :user_role, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
