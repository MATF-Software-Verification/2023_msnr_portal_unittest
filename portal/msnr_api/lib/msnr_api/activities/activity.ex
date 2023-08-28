defmodule MsnrApi.Activities.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "activities" do
    field :end_date, :integer
    field :is_signup, :boolean, default: false
    field :start_date, :integer
    field :points, :integer
    belongs_to :activity_type, MsnrApi.ActivityTypes.ActivityType
    belongs_to :semester, MsnrApi.Semesters.Semester

    timestamps()
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:semester_id, :activity_type_id, :start_date, :end_date, :is_signup, :points])
    |> validate_required([
      :semester_id,
      :activity_type_id,
      :start_date,
      :end_date,
      :is_signup,
      :points
    ])
    |> unique_constraint([:semester_id, :activity_type_id, :is_signup])
  end
end
