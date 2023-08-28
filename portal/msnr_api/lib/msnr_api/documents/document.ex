defmodule MsnrApi.Documents.Document do
  use Ecto.Schema
  import Ecto.Changeset

  schema "documents" do
    field :file_name, :string
    field :file_path, :string
    field :creator_id, :id

    timestamps()
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:file_name, :file_path, :creator_id])
    |> validate_required([:file_name, :file_path, :creator_id])
  end
end
