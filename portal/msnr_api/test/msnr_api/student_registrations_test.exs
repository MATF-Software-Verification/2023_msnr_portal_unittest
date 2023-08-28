defmodule MsnrApi.StudentRegistrationsTest do
  use MsnrApi.DataCase

  alias MsnrApi.StudentRegistrations

  describe "student_registrations" do
    alias MsnrApi.StudentRegistrations.StudentRegistration

    import MsnrApi.StudentRegistrationsFixtures

    @invalid_attrs %{email: nil, first_name: nil, index_number: nil, last_name: nil, status: nil}

    test "list_student_registrations/0 returns all student_registrations" do
      student_registration = student_registration_fixture()
      assert StudentRegistrations.list_student_registrations() == [student_registration]
    end

    test "get_student_registration!/1 returns the student_registration with given id" do
      student_registration = student_registration_fixture()

      assert StudentRegistrations.get_student_registration!(student_registration.id) ==
               student_registration
    end

    test "create_student_registration/1 with valid data creates a student_registration" do
      valid_attrs = %{
        email: "some email",
        first_name: "some first_name",
        index_number: "some index_number",
        last_name: "some last_name",
        status: "some status"
      }

      assert {:ok, %StudentRegistration{} = student_registration} =
               StudentRegistrations.create_student_registration(valid_attrs)

      assert student_registration.email == "some email"
      assert student_registration.first_name == "some first_name"
      assert student_registration.index_number == "some index_number"
      assert student_registration.last_name == "some last_name"
      assert student_registration.status == "some status"
    end

    test "create_student_registration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               StudentRegistrations.create_student_registration(@invalid_attrs)
    end

    test "update_student_registration/2 with valid data updates the student_registration" do
      student_registration = student_registration_fixture()

      update_attrs = %{
        email: "some updated email",
        first_name: "some updated first_name",
        index_number: "some updated index_number",
        last_name: "some updated last_name",
        status: "some updated status"
      }

      assert {:ok, %StudentRegistration{} = student_registration} =
               StudentRegistrations.update_student_registration(
                 student_registration,
                 update_attrs
               )

      assert student_registration.email == "some updated email"
      assert student_registration.first_name == "some updated first_name"
      assert student_registration.index_number == "some updated index_number"
      assert student_registration.last_name == "some updated last_name"
      assert student_registration.status == "some updated status"
    end

    test "update_student_registration/2 with invalid data returns error changeset" do
      student_registration = student_registration_fixture()

      assert {:error, %Ecto.Changeset{}} =
               StudentRegistrations.update_student_registration(
                 student_registration,
                 @invalid_attrs
               )

      assert student_registration ==
               StudentRegistrations.get_student_registration!(student_registration.id)
    end

    test "delete_student_registration/1 deletes the student_registration" do
      student_registration = student_registration_fixture()

      assert {:ok, %StudentRegistration{}} =
               StudentRegistrations.delete_student_registration(student_registration)

      assert_raise Ecto.NoResultsError, fn ->
        StudentRegistrations.get_student_registration!(student_registration.id)
      end
    end

    test "change_student_registration/1 returns a student_registration changeset" do
      student_registration = student_registration_fixture()

      assert %Ecto.Changeset{} =
               StudentRegistrations.change_student_registration(student_registration)
    end
  end
end
