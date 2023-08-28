defmodule MsnrApiWeb.ActivityView do
  use MsnrApiWeb, :view
  alias MsnrApiWeb.ActivityView

  def render("index.json", %{activities: activities}) do
    %{data: render_many(activities, ActivityView, "activity.json")}
  end

  def render("show.json", %{activity: activity}) do
    %{data: render_one(activity, ActivityView, "activity.json")}
  end

  def render("activity.json", %{activity: activity}) do
    %{
      id: activity.id,
      activity_type_id: activity.activity_type_id,
      semester_id: activity.semester_id,
      start_date: activity.start_date,
      end_date: activity.end_date,
      is_signup: activity.is_signup,
      points: activity.points
    }
  end
end
