defmodule MsnrApi.SemestersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MsnrApi.Semesters` context.
  """

  @doc """
  Generate a semester.
  """
  def semester_fixture(attrs \\ %{}) do
    {:ok, semester} =
      attrs
      |> Enum.into(%{
        is_active: true,
        module: "some module",
        year: 42
      })
      |> MsnrApi.Semesters.create_semester()

    semester
  end
end
