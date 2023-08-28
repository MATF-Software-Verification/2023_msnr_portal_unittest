defmodule MsnrApi.StudentRegistrationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MsnrApi.StudentRegistrations` context.
  """

  @doc """
  Generate a student_registration.
  """
  def student_registration_fixture(attrs \\ %{}) do
    {:ok, student_registration} =
      attrs
      |> Enum.into(%{
        email: "some email",
        first_name: "some first_name",
        index_number: "some index_number",
        last_name: "some last_name",
        status: "some status"
      })
      |> MsnrApi.StudentRegistrations.create_student_registration()

    student_registration
  end
end
