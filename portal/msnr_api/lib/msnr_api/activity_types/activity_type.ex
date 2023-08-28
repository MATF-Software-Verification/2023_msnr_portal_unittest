defmodule MsnrApi.ActivityTypes.ActivityType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "activity_types" do
    field :content, :map
    field :description, :string
    field :has_signup, :boolean, default: false
    field :is_group, :boolean, default: false
    field :name, :string
    field :code, :string

    has_many :activities, MsnrApi.Activities.Activity

    timestamps()
  end

  @doc false
  def changeset(activity_type, attrs) do
    activity_type
    |> cast(attrs, [:code, :name, :description, :has_signup, :is_group, :content])
    |> validate_required([:code, :name, :description, :content])
    |> unique_constraint(:name)
    |> unique_constraint(:code)
  end
end
