defmodule MsnrApi.ActivityTypesTest do
  use MsnrApi.DataCase

  alias MsnrApi.ActivityTypes

  describe "activity_types" do
    alias MsnrApi.ActivityTypes.ActivityType

    import MsnrApi.ActivityTypesFixtures

    @invalid_attrs %{content: nil, description: nil, has_signup: nil, is_group: nil, name: nil}

    test "list_activity_types/0 returns all activity_types" do
      activity_type = activity_type_fixture()
      assert ActivityTypes.list_activity_types() == [activity_type]
    end

    test "get_activity_type!/1 returns the activity_type with given id" do
      activity_type = activity_type_fixture()
      assert ActivityTypes.get_activity_type!(activity_type.id) == activity_type
    end

    test "create_activity_type/1 with valid data creates a activity_type" do
      valid_attrs = %{
        content: %{},
        description: "some description",
        has_signup: true,
        is_group: true,
        name: "some name"
      }

      assert {:ok, %ActivityType{} = activity_type} =
               ActivityTypes.create_activity_type(valid_attrs)

      assert activity_type.content == %{}
      assert activity_type.description == "some description"
      assert activity_type.has_signup == true
      assert activity_type.is_group == true
      assert activity_type.name == "some name"
    end

    test "create_activity_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ActivityTypes.create_activity_type(@invalid_attrs)
    end

    test "update_activity_type/2 with valid data updates the activity_type" do
      activity_type = activity_type_fixture()

      update_attrs = %{
        content: %{},
        description: "some updated description",
        has_signup: false,
        is_group: false,
        name: "some updated name"
      }

      assert {:ok, %ActivityType{} = activity_type} =
               ActivityTypes.update_activity_type(activity_type, update_attrs)

      assert activity_type.content == %{}
      assert activity_type.description == "some updated description"
      assert activity_type.has_signup == false
      assert activity_type.is_group == false
      assert activity_type.name == "some updated name"
    end

    test "update_activity_type/2 with invalid data returns error changeset" do
      activity_type = activity_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               ActivityTypes.update_activity_type(activity_type, @invalid_attrs)

      assert activity_type == ActivityTypes.get_activity_type!(activity_type.id)
    end

    test "delete_activity_type/1 deletes the activity_type" do
      activity_type = activity_type_fixture()
      assert {:ok, %ActivityType{}} = ActivityTypes.delete_activity_type(activity_type)

      assert_raise Ecto.NoResultsError, fn ->
        ActivityTypes.get_activity_type!(activity_type.id)
      end
    end

    test "change_activity_type/1 returns a activity_type changeset" do
      activity_type = activity_type_fixture()
      assert %Ecto.Changeset{} = ActivityTypes.change_activity_type(activity_type)
    end
  end
end
