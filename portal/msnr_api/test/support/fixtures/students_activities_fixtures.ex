defmodule MsnrApi.StudentsActivitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MsnrApi.StudentsActivities` context.
  """

  @doc """
  Generate a students_activity.
  """
  def students_activity_fixture(attrs \\ %{}) do
    {:ok, students_activity} =
      attrs
      |> Enum.into(%{
        comment: "some comment",
        completed: true,
        grade: 42
      })
      |> MsnrApi.StudentsActivities.create_student_activity()

    students_activity
  end
end
