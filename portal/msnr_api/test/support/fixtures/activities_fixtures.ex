defmodule MsnrApi.ActivitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MsnrApi.Activities` context.
  """

  @doc """
  Generate a activity.
  """
  def activity_fixture(attrs \\ %{}) do
    {:ok, activity} =
      attrs
      |> Enum.into(%{
        end_date: 42,
        is_signup: true,
        start_date: 42
      })
      |> MsnrApi.Activities.create_activity()

    activity
  end
end
