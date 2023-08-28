defmodule MsnrApiWeb.ActivityTypeView do
  use MsnrApiWeb, :view
  alias MsnrApiWeb.ActivityTypeView

  def render("index.json", %{activity_types: activity_types}) do
    %{data: render_many(activity_types, ActivityTypeView, "activity_type.json")}
  end

  def render("show.json", %{activity_type: activity_type}) do
    %{data: render_one(activity_type, ActivityTypeView, "activity_type.json")}
  end

  def render("activity_type.json", %{activity_type: activity_type}) do
    %{
      id: activity_type.id,
      name: activity_type.name,
      code: activity_type.code,
      description: activity_type.description,
      has_signup: activity_type.has_signup,
      is_group: activity_type.is_group,
      content: activity_type.content
    }
  end
end
