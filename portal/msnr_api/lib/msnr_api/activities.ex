defmodule MsnrApi.Activities do
  @moduledoc """
  The Activities context.
  """

  import Ecto.Query, warn: false
  alias MsnrApi.Repo
  alias Ecto.Multi

  alias MsnrApi.Activities.Activity
  alias MsnrApi.Assignments.Assignment
  alias MsnrApi.ActivityTypes
  alias MsnrApi.ActivityTypes.ActivityType
  # alias MsnrApi.Students.StudentSemester

  @review ActivityTypes.TypeCode.review()

  @doc """
  Returns the list of activities.

  ## Examples

      iex> list_activities()
      [%Activity{}, ...]

  """
  def list_activities do
    Repo.all(Activity)
  end

  @doc """
  Gets a single activity.

  Raises `Ecto.NoResultsError` if the Activity does not exist.

  ## Examples

      iex> get_activity!(123)
      %Activity{}

      iex> get_activity!(456)
      ** (Ecto.NoResultsError)

  """
  def get_activity!(id), do: Repo.get!(Activity, id)

  @doc """
  Creates a activity.

  ## Examples

      iex> create_activity(%{field: value})
      {:ok, %Activity{}}

      iex> create_activity(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_activity(str_semester_id, attrs) do
    {semester_id, _} = Integer.parse(str_semester_id)
    activity_changeset =
      %Activity{semester_id: semester_id}
      |> Activity.changeset(attrs)

    multi_struct = Multi.new()
    |> Multi.insert(:activity, activity_changeset)
    |> Multi.insert_all(:assignments, Assignment, &create_assignments_for_activity/1)

    case MsnrApi.Repo.transaction(multi_struct) do
      {:ok, %{activity: activity}} -> {:ok, activity}
      {:error, :activity, changeset, _changes} -> {:error, changeset}
      _ ->  {:error, :bad_request}
    end
  end

  defp create_assignments_for_activity(%{activity: %Activity{} = activity}) do
    activity_type = ActivityTypes.get_activity_type!(activity.activity_type_id)

    get_ids(activity_type, activity)
    |> create_assignements(activity_type, activity)
  end

  defp get_ids(%ActivityType{is_group: true}, %Activity{} = activity) do
    # get all group ids
    from(s in MsnrApi.Semesters.Semester,
      where: s.id == ^activity.semester_id,
      join: g in assoc(s, :groups),
      distinct: true,
      select: g.id
    )
    |> Repo.all()
  end

  defp get_ids(%ActivityType{is_group: false} = type, %Activity{} = activity) do
    query =
      if type.has_signup && !activity.is_signup do
        # students with signups
        from a in Activity,
          where:
            a.activity_type_id == ^type.id and a.semester_id == ^activity.semester_id and
            a.is_signup == true,
          join: as in Assignment,
          on: a.id == as.activity_id and as.completed == true,
          select: as.student_id
      else
        # all students
        from s in MsnrApi.Semesters.Semester,
          where: s.id == ^activity.semester_id,
          join: st in assoc(s, :students),
          select: st.user_id
      end

    Repo.all(query)
  end

  defp create_assignements(
         students_ids,
         %ActivityType{code: @review},
         %Activity{is_signup: false} = activity
       ) do
    selected_topics_ids = MsnrApi.Topics.selected_topics_ids(activity.semester_id)
    # students_topics =
    #     Repo.all(from s in StudentSemester, join: g in assoc(s, :group), preload: [group: g],  where: s.student_id in ^students_ids, select: {s.student_id, g.topic_id})

    topics_cnt = length(selected_topics_ids)
    students_cnt = length(students_ids)

    x = Integer.floor_div(students_cnt, topics_cnt)
    y = Integer.mod(students_cnt, topics_cnt)

    duplicated_topics =
      selected_topics_ids
      |> List.duplicate(x)
      |> List.flatten()

    y_random_topics =
      selected_topics_ids
      |> Enum.shuffle()
      |> Enum.take(y)

    topic_ids = duplicated_topics ++ y_random_topics # |> Enum.sort(:desc)

    Enum.zip_with(students_ids, topic_ids, fn student_id, topic_id ->
      %{
        activity_id: activity.id,
        student_id: student_id,
        group_id: nil,
        related_topic_id: topic_id,
        inserted_at: activity.inserted_at,
        updated_at: activity.inserted_at
      }
    end)
  end

  defp create_assignements(ids, %ActivityType{is_group: is_group}, %Activity{} = activity) do
    Enum.map(ids, fn id ->
      {student_id, group_id} = if is_group, do: {nil, id}, else: {id, nil}

      %{
        activity_id: activity.id,
        student_id: student_id,
        group_id: group_id,
        inserted_at: activity.inserted_at,
        updated_at: activity.inserted_at
      }
    end)
  end

  # defp insert_assignments(semester, activity) do
  #   {count, _} =
  #     Repo.insert_all(
  #       StudentActivity,
  #       create_assignments(semester, activity)
  #     )

  #   if count > 0, do: {:ok, count}, else: {:error, nil}
  # end

  # defp create_assignments(semester, activity) do
  #   inserted_at = activity.inserted_at
  #   enumerables = if activity.is_group, do: semester.groups, else: semester.students

  #   Enum.map(enumerables, fn x ->
  #     {student_id, group_id} = if activity.is_group, do: {nil, x.id}, else: {x.user_id, nil}
  #     %{
  #       activity_id: activity.id,
  #       student_id: student_id,
  #       group_id: group_id,
  #       inserted_at: inserted_at,
  #       updated_at: inserted_at
  #     }
  #   end)
  # end

  @doc """
  Updates a activity.

  ## Examples

      iex> update_activity(activity, %{field: new_value})
      {:ok, %Activity{}}

      iex> update_activity(activity, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_activity(%Activity{} = activity, attrs) do
    activity
    |> Activity.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a activity.

  ## Examples

      iex> delete_activity(activity)
      {:ok, %Activity{}}

      iex> delete_activity(activity)
      {:error, %Ecto.Changeset{}}

  """
  def delete_activity(%Activity{} = activity) do
    Repo.delete(activity)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking activity changes.

  ## Examples

      iex> change_activity(activity)
      %Ecto.Changeset{data: %Activity{}}

  """
  def change_activity(%Activity{} = activity, attrs \\ %{}) do
    Activity.changeset(activity, attrs)
  end
end
