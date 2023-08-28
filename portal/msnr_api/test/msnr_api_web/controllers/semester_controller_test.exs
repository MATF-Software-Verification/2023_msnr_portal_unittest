defmodule MsnrApiWeb.SemesterControllerTest do
  use MsnrApiWeb.ConnCase

  import MsnrApi.SemestersFixtures

  alias MsnrApi.Semesters.Semester

  @create_attrs %{
    is_active: true,
    module: "some module",
    year: 42
  }
  @update_attrs %{
    is_active: false,
    module: "some updated module",
    year: 43
  }
  @invalid_attrs %{is_active: nil, module: nil, year: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all semester", %{conn: conn} do
      conn = get(conn, Routes.semester_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create semester" do
    test "renders semester when data is valid", %{conn: conn} do
      conn = post(conn, Routes.semester_path(conn, :create), semester: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.semester_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "is_active" => true,
               "module" => "some module",
               "year" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.semester_path(conn, :create), semester: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update semester" do
    setup [:create_semester]

    test "renders semester when data is valid", %{
      conn: conn,
      semester: %Semester{id: id} = semester
    } do
      conn = put(conn, Routes.semester_path(conn, :update, semester), semester: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.semester_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "is_active" => false,
               "module" => "some updated module",
               "year" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, semester: semester} do
      conn = put(conn, Routes.semester_path(conn, :update, semester), semester: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete semester" do
    setup [:create_semester]

    test "deletes chosen semester", %{conn: conn, semester: semester} do
      conn = delete(conn, Routes.semester_path(conn, :delete, semester))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.semester_path(conn, :show, semester))
      end
    end
  end

  defp create_semester(_) do
    semester = semester_fixture()
    %{semester: semester}
  end
end
