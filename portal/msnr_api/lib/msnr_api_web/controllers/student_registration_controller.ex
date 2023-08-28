defmodule MsnrApiWeb.StudentRegistrationController do
  use MsnrApiWeb, :controller

  alias MsnrApi.StudentRegistrations
  alias MsnrApi.StudentRegistrations.StudentRegistration

  action_fallback MsnrApiWeb.FallbackController

  def index(conn, %{"semester_id" => semester_id}) do
    student_registrations = StudentRegistrations.list_student_registrations(semester_id)
    render(conn, "index.json", student_registrations: student_registrations)
  end

  def create(conn, %{"student_registration" => student_registration_params}) do
    with {:ok, %StudentRegistration{} = student_registration} <-
           StudentRegistrations.create_student_registration(student_registration_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.student_registration_path(conn, :show, student_registration)
      )
      |> render("show.json", student_registration: student_registration)
    end
  end

  def show(conn, %{"id" => id}) do
    student_registration = StudentRegistrations.get_student_registration!(id)
    render(conn, "show.json", student_registration: student_registration)
  end

  def update(conn, %{"id" => id, "student_registration" => student_registration_params}) do
    student_registration = StudentRegistrations.get_student_registration!(id)

    with {:ok, %{student_registration: student_registration}} <-
           StudentRegistrations.update_student_registration(
             student_registration,
             student_registration_params
           ) do
      render(conn, "show.json", student_registration: student_registration)
    end
  end

  def delete(conn, %{"id" => id}) do
    student_registration = StudentRegistrations.get_student_registration!(id)

    with {:ok, %StudentRegistration{}} <-
           StudentRegistrations.delete_student_registration(student_registration) do
      send_resp(conn, :no_content, "")
    end
  end
end
