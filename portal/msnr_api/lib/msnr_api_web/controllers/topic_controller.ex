defmodule MsnrApiWeb.TopicController do
  use MsnrApiWeb, :controller

  alias MsnrApi.Topics
  alias MsnrApi.Topics.Topic

  action_fallback MsnrApiWeb.FallbackController

  def index(conn, params) do
    topics = Topics.list_topics(params)
    render(conn, "index.json", topics: topics)
  end

  def create(conn, %{"semester_id" => sem_id, "topic" => topic_params}) do
    params =
      topic_params
      |> Map.put("semester_id", sem_id)

    with {:ok, %Topic{} = topic} <- Topics.create_topic(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.topic_path(conn, :show, topic))
      |> render("show.json", topic: topic)
    end
  end

  def show(conn, %{"id" => id}) do
    topic = Topics.get_topic!(id)
    render(conn, "show.json", topic: topic)
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    topic = Topics.get_topic!(id)

    with {:ok, %Topic{} = topic} <- Topics.update_topic(topic, topic_params) do
      render(conn, "show.json", topic: topic)
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = Topics.get_topic!(id)

    with {:ok, %Topic{}} <- Topics.delete_topic(topic) do
      send_resp(conn, :no_content, "")
    end
  end
end
