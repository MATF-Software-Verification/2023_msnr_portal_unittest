defmodule MsnrApi.Repo.Migrations.CreateRegistrationStatus do
  use Ecto.Migration

  def up do
    execute "CREATE TYPE registration_status AS ENUM ('accepted', 'rejected', 'pending')"
  end

  def down do
    execute "DROP TYPE registration_status"
  end
end
