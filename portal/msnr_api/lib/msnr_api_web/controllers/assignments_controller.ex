defmodule MsnrApiWeb.AssignmentController do
  use MsnrApiWeb, :controller
  import MsnrApiWeb.Plugs.Authorization

  alias MsnrApi.Assignments
  alias MsnrApi.Assignments.Assignment

  action_fallback MsnrApiWeb.FallbackController

  plug :allow_students when action in [:index]
  plug :professor_only when action in [:create, :update, :delete, :show]

  def index(conn, %{"student_id" => _} = params) do
    assignments =
      Assignments.list_assignments(params)

    render(conn, "index.json", assignments: assignments)
  end

  def index(conn, params) do
    assignments =
      Assignments.list_assignments(params)
      render(conn, "index_shallow.json", assignments: assignments)
  end

  def show(conn, %{"id" => id}) do
    assignment = Assignments.get_assignment!(id)
    render(conn, "show.json", assignment: assignment)
  end

  def update(conn, %{"id" => id, "assignment" => assignment_params}) do
    assignment = Assignments.get_assignment!(id)

    with {:ok, %Assignment{} = assignment} <-
           Assignments.update_assignment(assignment, assignment_params) do
      render(conn, "show.json", assignment: assignment)
    end
  end

  def delete(conn, %{"id" => id}) do
    assignment = Assignments.get_assignment!(id)

    with {:ok, %Assignment{}} <- Assignments.delete_assignment(assignment) do
      send_resp(conn, :no_content, "")
    end
  end
end
