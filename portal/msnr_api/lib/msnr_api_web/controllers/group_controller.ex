defmodule MsnrApiWeb.GroupController do
  use MsnrApiWeb, :controller

  alias MsnrApi.Groups
  alias MsnrApi.Groups.Group

  action_fallback MsnrApiWeb.FallbackController

  def index(conn, %{"semester_id" => semester_id}) do
    groups = Groups.list_groups(semester_id)
    render(conn, "index.json", groups: groups)
  end

  def create(conn, %{"semester_id" => sem_id, "students" => students}) do
    with {:ok, group} <- Groups.create_group(%{semester_id: sem_id, students: students}) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.group_path(conn, :show, group))
      |> render("show_shallow.json", group: group)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, group} <- Groups.get_group(id) do
      render(conn, "show.json", group: group)
    end
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Groups.get_group!(id)

    with {:ok, %Group{} = group} <- Groups.update_group(group, group_params) do
      render(conn, "show.json", group: group)
    end
  end

  # def delete(conn, %{"id" => id}) do
  #   group = Groups.get_group!(id)

  #   with {:ok, %Group{}} <- Groups.delete_group(group) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
