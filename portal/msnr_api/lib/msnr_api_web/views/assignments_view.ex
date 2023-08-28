defmodule MsnrApiWeb.AssignmentView do
  use MsnrApiWeb, :view
  alias MsnrApiWeb.AssignmentView

  def render("index.json", %{assignments: assignments}) do
    %{data: render_many(assignments, AssignmentView, "assignment.json")}
  end

  def render("show.json", %{assignment: assignment}) do
    %{data: render_one(assignment, AssignmentView, "assignment_shallow.json")}
  end

  def render("assignment.json", %{assignment: assignment}) do
    %{
      id: assignment.id,
      grade: assignment.grade,
      comment: assignment.comment,
      completed: assignment.completed,
      activity: MsnrApiWeb.ActivityView.render("activity.json", activity: assignment.activity),
      activity_type:
        MsnrApiWeb.ActivityTypeView.render("activity_type.json",
          activity_type: assignment.activity_type
        )
    }
  end

  def render("index_shallow.json", %{assignments: assignments}) do
    %{data: render_many(assignments, AssignmentView, "assignment_shallow.json")}
  end

  def render("assignment_shallow.json", %{assignment: assignment}) do
    %{
      id: assignment.id,
      activity_id: assignment.activity_id,
      student_id: assignment.student_id,
      group_id: assignment.group_id,
      grade: assignment.grade,
      comment: assignment.comment,
      completed: assignment.completed
    }
  end
end
