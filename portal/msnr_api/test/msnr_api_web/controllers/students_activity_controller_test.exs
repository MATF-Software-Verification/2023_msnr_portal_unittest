defmodule MsnrApiWeb.StudentsActivityControllerTest do
  use MsnrApiWeb.ConnCase

  import MsnrApi.StudentsActivitiesFixtures

  alias MsnrApi.StudentsActivities.StudentsActivity

  @create_attrs %{
    comment: "some comment",
    completed: true,
    grade: 42
  }
  @update_attrs %{
    comment: "some updated comment",
    completed: false,
    grade: 43
  }
  @invalid_attrs %{comment: nil, completed: nil, grade: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all students_activities", %{conn: conn} do
      conn = get(conn, Routes.students_activity_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create students_activity" do
    test "renders students_activity when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.students_activity_path(conn, :create), students_activity: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.students_activity_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "comment" => "some comment",
               "completed" => true,
               "grade" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.students_activity_path(conn, :create), students_activity: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update students_activity" do
    setup [:create_students_activity]

    test "renders students_activity when data is valid", %{
      conn: conn,
      students_activity: %StudentsActivity{id: id} = students_activity
    } do
      conn =
        put(conn, Routes.students_activity_path(conn, :update, students_activity),
          students_activity: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.students_activity_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "comment" => "some updated comment",
               "completed" => false,
               "grade" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      students_activity: students_activity
    } do
      conn =
        put(conn, Routes.students_activity_path(conn, :update, students_activity),
          students_activity: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete students_activity" do
    setup [:create_students_activity]

    test "deletes chosen students_activity", %{conn: conn, students_activity: students_activity} do
      conn = delete(conn, Routes.students_activity_path(conn, :delete, students_activity))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.students_activity_path(conn, :show, students_activity))
      end
    end
  end

  defp create_students_activity(_) do
    students_activity = students_activity_fixture()
    %{students_activity: students_activity}
  end
end
