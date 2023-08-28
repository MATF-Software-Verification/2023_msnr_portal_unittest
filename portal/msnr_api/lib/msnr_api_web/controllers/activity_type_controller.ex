defmodule MsnrApiWeb.ActivityTypeController do
  use MsnrApiWeb, :controller

  alias MsnrApi.ActivityTypes
  alias MsnrApi.ActivityTypes.ActivityType

  action_fallback MsnrApiWeb.FallbackController

  def index(conn, _params) do
    activity_types = ActivityTypes.list_activity_types()
    render(conn, "index.json", activity_types: activity_types)
  end

  def create(conn, %{"activity_type" => activity_type_params}) do
    with {:ok, %ActivityType{} = activity_type} <-
           ActivityTypes.create_activity_type(activity_type_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.activity_type_path(conn, :show, activity_type))
      |> render("show.json", activity_type: activity_type)
    end
  end

  def show(conn, %{"id" => id}) do
    activity_type = ActivityTypes.get_activity_type!(id)
    render(conn, "show.json", activity_type: activity_type)
  end

  def update(conn, %{"id" => id, "activity_type" => activity_type_params}) do
    activity_type = ActivityTypes.get_activity_type!(id)

    with {:ok, %ActivityType{} = activity_type} <-
           ActivityTypes.update_activity_type(activity_type, activity_type_params) do
      render(conn, "show.json", activity_type: activity_type)
    end
  end

  def delete(conn, %{"id" => id}) do
    activity_type = ActivityTypes.get_activity_type!(id)

    with {:ok, %ActivityType{}} <- ActivityTypes.delete_activity_type(activity_type) do
      send_resp(conn, :no_content, "")
    end
  end
end
