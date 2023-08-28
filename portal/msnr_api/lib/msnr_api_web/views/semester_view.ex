defmodule MsnrApiWeb.SemesterView do
  use MsnrApiWeb, :view
  alias MsnrApiWeb.SemesterView

  def render("index.json", %{semester: semester}) do
    %{data: render_many(semester, SemesterView, "semester.json")}
  end

  def render("show.json", %{semester: semester}) do
    %{data: render_one(semester, SemesterView, "semester.json")}
  end

  def render("semester.json", %{semester: semester}) do
    %{
      id: semester.id,
      year: semester.year,
      is_active: semester.is_active
    }
  end
end
