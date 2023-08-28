defmodule MsnrApiWeb.ActivityTypeControllerTest do
  use MsnrApiWeb.ConnCase

  import MsnrApi.ActivityTypesFixtures

  alias MsnrApi.ActivityTypes.ActivityType

  @create_attrs %{
    content: %{},
    description: "some description",
    has_signup: true,
    is_group: true,
    name: "some name"
  }
  @update_attrs %{
    content: %{},
    description: "some updated description",
    has_signup: false,
    is_group: false,
    name: "some updated name"
  }
  @invalid_attrs %{content: nil, description: nil, has_signup: nil, is_group: nil, name: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all activity_types", %{conn: conn} do
      conn = get(conn, Routes.activity_type_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create activity_type" do
    test "renders activity_type when data is valid", %{conn: conn} do
      conn = post(conn, Routes.activity_type_path(conn, :create), activity_type: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.activity_type_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "content" => %{},
               "description" => "some description",
               "has_signup" => true,
               "is_group" => true,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.activity_type_path(conn, :create), activity_type: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update activity_type" do
    setup [:create_activity_type]

    test "renders activity_type when data is valid", %{
      conn: conn,
      activity_type: %ActivityType{id: id} = activity_type
    } do
      conn =
        put(conn, Routes.activity_type_path(conn, :update, activity_type),
          activity_type: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.activity_type_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "content" => %{},
               "description" => "some updated description",
               "has_signup" => false,
               "is_group" => false,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, activity_type: activity_type} do
      conn =
        put(conn, Routes.activity_type_path(conn, :update, activity_type),
          activity_type: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete activity_type" do
    setup [:create_activity_type]

    test "deletes chosen activity_type", %{conn: conn, activity_type: activity_type} do
      conn = delete(conn, Routes.activity_type_path(conn, :delete, activity_type))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.activity_type_path(conn, :show, activity_type))
      end
    end
  end

  defp create_activity_type(_) do
    activity_type = activity_type_fixture()
    %{activity_type: activity_type}
  end
end
