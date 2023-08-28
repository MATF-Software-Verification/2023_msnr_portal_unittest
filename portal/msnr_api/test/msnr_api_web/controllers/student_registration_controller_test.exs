defmodule MsnrApiWeb.StudentRegistrationControllerTest do
  use MsnrApiWeb.ConnCase

  import MsnrApi.StudentRegistrationsFixtures

  alias MsnrApi.StudentRegistrations.StudentRegistration

  @create_attrs %{
    email: "some email",
    first_name: "some first_name",
    index_number: "some index_number",
    last_name: "some last_name",
    status: "some status"
  }
  @update_attrs %{
    email: "some updated email",
    first_name: "some updated first_name",
    index_number: "some updated index_number",
    last_name: "some updated last_name",
    status: "some updated status"
  }
  @invalid_attrs %{email: nil, first_name: nil, index_number: nil, last_name: nil, status: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all student_registrations", %{conn: conn} do
      conn = get(conn, Routes.student_registration_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create student_registration" do
    test "renders student_registration when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.student_registration_path(conn, :create),
          student_registration: @create_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.student_registration_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "email" => "some email",
               "first_name" => "some first_name",
               "index_number" => "some index_number",
               "last_name" => "some last_name",
               "status" => "some status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.student_registration_path(conn, :create),
          student_registration: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update student_registration" do
    setup [:create_student_registration]

    test "renders student_registration when data is valid", %{
      conn: conn,
      student_registration: %StudentRegistration{id: id} = student_registration
    } do
      conn =
        put(conn, Routes.student_registration_path(conn, :update, student_registration),
          student_registration: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.student_registration_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "email" => "some updated email",
               "first_name" => "some updated first_name",
               "index_number" => "some updated index_number",
               "last_name" => "some updated last_name",
               "status" => "some updated status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      student_registration: student_registration
    } do
      conn =
        put(conn, Routes.student_registration_path(conn, :update, student_registration),
          student_registration: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete student_registration" do
    setup [:create_student_registration]

    test "deletes chosen student_registration", %{
      conn: conn,
      student_registration: student_registration
    } do
      conn = delete(conn, Routes.student_registration_path(conn, :delete, student_registration))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.student_registration_path(conn, :show, student_registration))
      end
    end
  end

  defp create_student_registration(_) do
    student_registration = student_registration_fixture()
    %{student_registration: student_registration}
  end
end
