defmodule MsnrApiWeb.StudentRegistrationView do
  use MsnrApiWeb, :view
  alias MsnrApiWeb.StudentRegistrationView

  def render("index.json", %{student_registrations: student_registrations}) do
    %{
      data:
        render_many(student_registrations, StudentRegistrationView, "student_registration.json")
    }
  end

  def render("show.json", %{student_registration: student_registration}) do
    %{
      data: render_one(student_registration, StudentRegistrationView, "student_registration.json")
    }
  end

  def render("student_registration.json", %{student_registration: student_registration}) do
    %{
      id: student_registration.id,
      email: student_registration.email,
      first_name: student_registration.first_name,
      last_name: student_registration.last_name,
      index_number: student_registration.index_number,
      status: student_registration.status
    }
  end
end
