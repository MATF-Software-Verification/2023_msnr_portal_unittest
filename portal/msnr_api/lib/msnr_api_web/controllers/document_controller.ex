defmodule MsnrApiWeb.DocumentController do
  use MsnrApiWeb, :controller

  alias MsnrApi.Documents
  alias MsnrApi.Documents.Document
  alias MsnrApi.Assignments
  alias MsnrApiWeb.Validation

  action_fallback MsnrApiWeb.FallbackController

  @professor %{assigns: %{user_info: %{role: :professor}}}

  def index(conn, params) do
    documents = Documents.list_documents(params)
    render(conn, "index.json", documents: documents)
  end

  def create(conn, %{
        "assignment_id" => assignment_id,
        "documentsIds" => docIds,
        "documents" => docs
      }) do
    assignment_extended = Assignments.get_assignment_extended!(assignment_id)
    curr_user = conn.assigns[:user_info]

    with {:ok} <- Validation.validate_user(curr_user, assignment_extended.assignment),
         {:ok} <- Validation.validate_time(curr_user, assignment_extended),
         {:ok, file_tuples} <-
           Validation.validate_files(docIds, docs, assignment_extended.content),
         {:ok, documents} <-
           Documents.create_documents(file_tuples, assignment_extended, curr_user) do
      render(conn, "index.json", documents: documents)
    end
  end

  def create(@professor = conn, %{
    "assignment_id" => assignment_id,
    "document" => file
  }) do
    curr_user = conn.assigns[:user_info]
    IO.inspect(file)
    with {:ok, %Document{} = document} <-
      Documents.create_document(assignment_id, file, curr_user) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.document_path(conn, :show, document))
        |> render("show.json", document: document)
    end


    # curr_user = conn.assigns[:user_info]

    # with {:ok} <- Validation.validate_user(curr_user, assignment_extended.assignment),
    #     {:ok} <- Validation.validate_time(curr_user, assignment_extended),
    #     {:ok, file_tuples} <-
    #       Validation.validate_files(docIds, docs, assignment_extended.content),
    #     {:ok, documents} <-
    #       Documents.create_documents(file_tuples, assignment_extended, curr_user) do
    #   render(conn, "index.json", documents: documents)
#end
end


  def show(conn, %{"id" => id}) do
    document = Documents.get_document!(id)
    send_download(conn, {:file, document.file_path})
  end

  def update(conn, %{"id" => id, "document" => %{path: path}}) do
    document = Documents.get_document!(id)

    with {:ok, _} <- File.copy(path, document.file_path) do
      render(conn, "show.json", document: document)
    end
  end

  # def delete(conn, %{"id" => id}) do
  #   document = Documents.get_document!(id)

  #   with {:ok, %Document{}} <- Documents.delete_document(document) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
