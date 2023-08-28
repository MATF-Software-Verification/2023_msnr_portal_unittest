defmodule MsnrApi.ActivitiesTest do
  use MsnrApi.DataCase

  alias MsnrApi.Activities

  describe "activities" do
    alias MsnrApi.Activities.Activity

    import MsnrApi.ActivitiesFixtures

    @invalid_attrs %{end_date: nil, is_signup: nil, start_date: nil}

    test "list_activities/0 returns all activities" do
      activity = activity_fixture()
      assert Activities.list_activities() == [activity]
    end

    test "get_activity!/1 returns the activity with given id" do
      activity = activity_fixture()
      assert Activities.get_activity!(activity.id) == activity
    end

    test "create_activity/1 with valid data creates a activity" do
      valid_attrs = %{end_date: 42, is_signup: true, start_date: 42}

      assert {:ok, %Activity{} = activity} = Activities.create_activity(valid_attrs)
      assert activity.end_date == 42
      assert activity.is_signup == true
      assert activity.start_date == 42
    end

    test "create_activity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Activities.create_activity(@invalid_attrs)
    end

    test "update_activity/2 with valid data updates the activity" do
      activity = activity_fixture()
      update_attrs = %{end_date: 43, is_signup: false, start_date: 43}

      assert {:ok, %Activity{} = activity} = Activities.update_activity(activity, update_attrs)
      assert activity.end_date == 43
      assert activity.is_signup == false
      assert activity.start_date == 43
    end

    test "update_activity/2 with invalid data returns error changeset" do
      activity = activity_fixture()
      assert {:error, %Ecto.Changeset{}} = Activities.update_activity(activity, @invalid_attrs)
      assert activity == Activities.get_activity!(activity.id)
    end

    test "delete_activity/1 deletes the activity" do
      activity = activity_fixture()
      assert {:ok, %Activity{}} = Activities.delete_activity(activity)
      assert_raise Ecto.NoResultsError, fn -> Activities.get_activity!(activity.id) end
    end

    test "change_activity/1 returns a activity changeset" do
      activity = activity_fixture()
      assert %Ecto.Changeset{} = Activities.change_activity(activity)
    end
  end
end
