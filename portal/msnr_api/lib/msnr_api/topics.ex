defmodule MsnrApi.Topics do
  @moduledoc """
  The Topics context.
  """

  import Ecto.Query, warn: false
  alias MsnrApi.Repo

  alias MsnrApi.Topics.Topic
  alias MsnrApi.Groups.Group

  @doc """
  Returns the list of topics.

  ## Examples

      iex> list_topics()
      [%Topic{}, ...]

  """
  def list_topics(%{"semester_id" => semester_id, "available" => "true"}) do
    from(t in Topic,
      left_join: g in Group,
      on: t.id == g.topic_id,
      where: t.semester_id == ^semester_id and is_nil(g.topic_id),
      select: t
    )
    |> Repo.all()
  end

  def list_topics(%{"semester_id" => semester_id}) do
    Repo.all(from t in Topic, where: t.semester_id == ^semester_id)
  end

  @doc """
  Gets a single topic.

  Raises `Ecto.NoResultsError` if the Topic does not exist.

  ## Examples

      iex> get_topic!(123)
      %Topic{}

      iex> get_topic!(456)
      ** (Ecto.NoResultsError)

  """
  def get_topic!(id), do: Repo.get!(Topic, id)

  @doc """
  Creates a topic.

  ## Examples

      iex> create_topic(%{field: value})
      {:ok, %Topic{}}

      iex> create_topic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a topic.

  ## Examples

      iex> update_topic(topic, %{field: new_value})
      {:ok, %Topic{}}

      iex> update_topic(topic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a topic.

  ## Examples

      iex> delete_topic(topic)
      {:ok, %Topic{}}

      iex> delete_topic(topic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking topic changes.

  ## Examples

      iex> change_topic(topic)
      %Ecto.Changeset{data: %Topic{}}

  """
  def change_topic(%Topic{} = topic, attrs \\ %{}) do
    Topic.changeset(topic, attrs)
  end

  def selected_topics_ids(semester_id) do
    Repo.all(
      from g in MsnrApi.Groups.Group,
        join: ss in MsnrApi.Students.StudentSemester,
        on: ss.semester_id == ^semester_id and ss.group_id == g.id,
        distinct: true,
        select: g.topic_id
    )
  end

  def next_topic_number(semester_id) do
    query = from t in Topic, where: t.semester_id == ^semester_id, select: max(t.number)

    case Repo.one(query) do
      nil -> 1
      val -> val + 1
    end
  end
end
