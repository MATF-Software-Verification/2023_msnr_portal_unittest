defmodule MsnrApi.ActivityTypesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MsnrApi.ActivityTypes` context.
  """

  @doc """
  Generate a activity_type.
  """
  def activity_type_fixture(attrs \\ %{}) do
    {:ok, activity_type} =
      attrs
      |> Enum.into(%{
        content: %{},
        description: "some description",
        has_signup: true,
        is_group: true,
        name: "some name"
      })
      |> MsnrApi.ActivityTypes.create_activity_type()

    activity_type
  end
end
