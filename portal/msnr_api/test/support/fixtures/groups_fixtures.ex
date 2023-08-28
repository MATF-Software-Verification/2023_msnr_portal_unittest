defmodule MsnrApi.GroupsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MsnrApi.Groups` context.
  """

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(%{})
      |> MsnrApi.Groups.create_group()

    group
  end
end
