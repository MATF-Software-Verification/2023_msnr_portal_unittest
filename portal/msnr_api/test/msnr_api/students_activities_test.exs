defmodule MsnrApi.StudentsActivitiesTest do
  use MsnrApi.DataCase

  alias MsnrApi.StudentsActivities

  describe "students_activities" do
    alias MsnrApi.StudentsActivities.StudentsActivity

    import MsnrApi.StudentsActivitiesFixtures

    @invalid_attrs %{comment: nil, completed: nil, grade: nil}

    test "list_students_activities/0 returns all students_activities" do
      students_activity = students_activity_fixture()
      assert StudentsActivities.list_students_activities() == [students_activity]
    end

    test "get_students_activity!/1 returns the students_activity with given id" do
      students_activity = students_activity_fixture()
      assert StudentsActivities.get_students_activity!(students_activity.id) == students_activity
    end

    test "create_students_activity/1 with valid data creates a students_activity" do
      valid_attrs = %{comment: "some comment", completed: true, grade: 42}

      assert {:ok, %StudentsActivity{} = students_activity} =
               StudentsActivities.create_students_activity(valid_attrs)

      assert students_activity.comment == "some comment"
      assert students_activity.completed == true
      assert students_activity.grade == 42
    end

    test "create_students_activity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               StudentsActivities.create_students_activity(@invalid_attrs)
    end

    test "update_students_activity/2 with valid data updates the students_activity" do
      students_activity = students_activity_fixture()
      update_attrs = %{comment: "some updated comment", completed: false, grade: 43}

      assert {:ok, %StudentsActivity{} = students_activity} =
               StudentsActivities.update_students_activity(students_activity, update_attrs)

      assert students_activity.comment == "some updated comment"
      assert students_activity.completed == false
      assert students_activity.grade == 43
    end

    test "update_students_activity/2 with invalid data returns error changeset" do
      students_activity = students_activity_fixture()

      assert {:error, %Ecto.Changeset{}} =
               StudentsActivities.update_students_activity(students_activity, @invalid_attrs)

      assert students_activity == StudentsActivities.get_students_activity!(students_activity.id)
    end

    test "delete_students_activity/1 deletes the students_activity" do
      students_activity = students_activity_fixture()

      assert {:ok, %StudentsActivity{}} =
               StudentsActivities.delete_students_activity(students_activity)

      assert_raise Ecto.NoResultsError, fn ->
        StudentsActivities.get_students_activity!(students_activity.id)
      end
    end

    test "change_students_activity/1 returns a students_activity changeset" do
      students_activity = students_activity_fixture()
      assert %Ecto.Changeset{} = StudentsActivities.change_students_activity(students_activity)
    end
  end
end
