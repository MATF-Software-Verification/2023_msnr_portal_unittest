defmodule MsnrApiWeb.StudentView do
  use MsnrApiWeb, :view
  alias MsnrApiWeb.StudentView

  def render("index.json", %{students: students}) do
    %{data: render_many(students, StudentView, "student.json")}
  end

  def render("show.json", %{student: student}) do
    %{data: render_one(student, StudentView, "student.json")}
  end

  def render("student.json", %{
        student: %{
          student: %{user: user, index_number: index_number},
          group_id: group_id
        }
      }) do
    %{
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      index_number: index_number,
      group_id: group_id
    }
  end
end
