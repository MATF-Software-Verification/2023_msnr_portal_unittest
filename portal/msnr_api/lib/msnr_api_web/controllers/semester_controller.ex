defmodule MsnrApiWeb.SemesterController do
  use MsnrApiWeb, :controller

  alias MsnrApi.Semesters
  alias MsnrApi.Semesters.Semester

  action_fallback MsnrApiWeb.FallbackController

  def index(conn, _params) do
    semester = Semesters.list_semester()
    render(conn, "index.json", semester: semester)
  end

  def create(conn, %{"semester" => semester_params}) do
    with {:ok, %Semester{} = semester} <- Semesters.create_semester(semester_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.semester_path(conn, :show, semester))
      |> render("show.json", semester: semester)
    end
  end

  def show(conn, %{"id" => id}) do
    semester = Semesters.get_semester!(id)
    render(conn, "show.json", semester: semester)
  end

  def update(conn, %{"id" => id, "semester" => semester_params}) do
    semester = Semesters.get_semester!(id)

    with {:ok, %Semester{} = semester} <- Semesters.update_semester(semester, semester_params) do
      render(conn, "show.json", semester: semester)
    end
  end

  def delete(conn, %{"id" => id}) do
    semester = Semesters.get_semester!(id)

    with {:ok, %Semester{}} <- Semesters.delete_semester(semester) do
      send_resp(conn, :no_content, "")
    end
  end
end
