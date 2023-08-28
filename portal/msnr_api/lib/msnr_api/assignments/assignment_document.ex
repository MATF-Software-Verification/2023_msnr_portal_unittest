defmodule MsnrApi.Assignments.AssignmentDocument do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "assignments_documents" do
    field :assignment_id, :id, primary_key: true
    field :document_id, :id, primary_key: true
    field :attached, :boolean

    timestamps()
  end

  @doc false
  def changeset(assignment_document, attrs) do
    assignment_document
    |> cast(attrs, [:assignment_id, :document_id, :attached])
    |> validate_required([:assignment_id, :document_id, :attached])
  end
end
