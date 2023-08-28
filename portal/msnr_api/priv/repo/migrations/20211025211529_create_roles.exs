defmodule MsnrApi.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def up do
    execute "CREATE TYPE user_role AS ENUM ('student', 'professor')"
  end

  def down do
    execute "DROP TYPE user_role"
  end
end
