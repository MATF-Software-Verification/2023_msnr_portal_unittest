defmodule MsnrApi.StudentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MsnrApi.Students` context.
  """

  @doc """
  Generate a student.
  """
  def student_fixture(attrs \\ %{}) do
    {:ok, student} =
      attrs
      |> Enum.into(%{
        index_number: "some index_number"
      })
      |> MsnrApi.Students.create_student()

    student
  end
end
