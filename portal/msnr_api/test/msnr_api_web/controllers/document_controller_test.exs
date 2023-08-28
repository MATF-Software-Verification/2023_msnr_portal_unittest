defmodule MsnrApiWeb.DocumentControllerTest do
  use MsnrApiWeb.ConnCase

  import MsnrApi.DocumentsFixtures

  alias MsnrApi.Documents.Document

  @create_attrs %{
    file_name: "some file_name",
    file_path: "some file_path"
  }
  @update_attrs %{
    file_name: "some updated file_name",
    file_path: "some updated file_path"
  }
  @invalid_attrs %{file_name: nil, file_path: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all documents", %{conn: conn} do
      conn = get(conn, Routes.document_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create document" do
    test "renders document when data is valid", %{conn: conn} do
      conn = post(conn, Routes.document_path(conn, :create), document: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.document_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "file_name" => "some file_name",
               "file_path" => "some file_path"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.document_path(conn, :create), document: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update document" do
    setup [:create_document]

    test "renders document when data is valid", %{
      conn: conn,
      document: %Document{id: id} = document
    } do
      conn = put(conn, Routes.document_path(conn, :update, document), document: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.document_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "file_name" => "some updated file_name",
               "file_path" => "some updated file_path"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, document: document} do
      conn = put(conn, Routes.document_path(conn, :update, document), document: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete document" do
    setup [:create_document]

    test "deletes chosen document", %{conn: conn, document: document} do
      conn = delete(conn, Routes.document_path(conn, :delete, document))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.document_path(conn, :show, document))
      end
    end
  end

  defp create_document(_) do
    document = document_fixture()
    %{document: document}
  end
end
