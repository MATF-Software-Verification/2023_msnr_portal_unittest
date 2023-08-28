defmodule MsnrApi.Documents do
  @moduledoc """
  The Documents context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset, only: [change: 2]
  alias MsnrApi.Repo
  # alias Ecto.Multi

  alias MsnrApi.Documents.Document
  alias MsnrApi.Accounts.TokenPayload
  alias MsnrApi.Assignments
  # alias MsnrApi.Assignments.Assignment
  alias MsnrApi.Assignments.AssignmentDocument

  @documents_store Application.get_env(:msnr_api, :documents_store)

  @doc """
  Returns the list of documents.

  ## Examples

      iex> list_documents(assignment_id)
      [%Document{}, ...]

  """
  def list_documents(%{"assignment_id" => assignment_id}) do
    from(ad in AssignmentDocument,
      join: doc in Document,
      on: ad.assignment_id == ^assignment_id and doc.id == ad.document_id,
      select: %{
        id: doc.id,
        attached: ad.attached,
        file_name: doc.file_name
      }
    )
    |> Repo.all()
  end

  # def list_documents(  %{"activity_id" => activity_id}) do
  #   from(as in Assignment,
  #     join: ad in AssignmentDocument, on: as.activity_id == ^activity_id and as.id == ad.assignment_id,
  #     join: doc in Document,on: doc.id == ad.document_id,
  #     select: %{
  #       id: doc.id,
  #       attached: ad.attached,
  #       file_name: doc.file_name
  #     }
  #   )
  #   |> Repo.all()
  # end

  @doc """
  Gets a single document.

  Raises `Ecto.NoResultsError` if the Document does not exist.

  ## Examples

      iex> get_document!(123)
      %Document{}

      iex> get_document!(456)
      ** (Ecto.NoResultsError)

  """
  def get_document!(id), do: Repo.get!(Document, id)

  @doc """
  Creates a document.

  ## Examples

      iex> create_document(%{field: value})
      {:ok, %Document{}}

      iex> create_document(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_document(attrs \\ %{}) do
    %Document{}
    |> Document.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a document.

  ## Examples

      iex> update_document(document, %{field: new_value})
      {:ok, %Document{}}

      iex> update_document(document, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_document(%Document{} = document, attrs) do
    document
    |> Document.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a document.

  ## Examples

      iex> delete_document(document)
      {:ok, %Document{}}

      iex> delete_document(document)
      {:error, %Ecto.Changeset{}}

  """
  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking document changes.

  ## Examples

      iex> change_document(document)
      %Ecto.Changeset{data: %Document{}}

  """
  def change_document(%Document{} = document, attrs \\ %{}) do
    Document.changeset(document, attrs)
  end

  def create_documents(file_tuples, assignment_extended, %TokenPayload{} = curr_user) do
    assignment = assignment_extended.assignment
    infix_name = filename_infix(assignment)

    # multi_struct = Multi.new()
    # |> Multi.run(:file_tuples, fn _, _ ->
    #   Validation.validate_files(docIds, docs, assignment_extended.content)
    # end)
    # |> Mulit.run

    Repo.transaction(fn ->
      docs =
        Enum.map(file_tuples, fn {prefix_name, extenstion, path} ->
          file_name = "#{prefix_name}_#{infix_name}#{extenstion}"

          folder_path =
            @documents_store
            |> Path.join("#{assignment_extended.semester_year}")
            |> Path.join(prefix_name)

          new_path = Path.join(folder_path, file_name)

          File.mkdir_p!(folder_path)
          File.copy!(path, new_path)

          doc =
            %Document{}
            |> Document.changeset(%{
              file_name: file_name,
              file_path: new_path,
              creator_id: curr_user.id
            })
            |> Repo.insert!()

          %AssignmentDocument{}
          |> AssignmentDocument.changeset(%{document_id: doc.id, assignment_id: assignment.id, attached: false})
          |> Repo.insert!()

          doc
        end)

      # complete assignment
      Repo.update!(change(assignment, completed: true))

      # return created documents
      docs
    end)
  end

  def create_document(assignment_id, %{filename: filename, path: path}, %TokenPayload{} = curr_user) do
    assignment_extended = Assignments.get_assignment_extended!(assignment_id)
    assignment = assignment_extended.assignment

    Repo.transaction(fn ->
      folder_path =
        @documents_store
        |> Path.join("professor")
        |> Path.join("#{assignment_extended.semester_year}")
        |> Path.join(assignment_extended.name)

      new_path = Path.join(folder_path, filename)

      File.mkdir_p!(folder_path)
      File.copy!(path, new_path)

      doc =
        %Document{}
        |> Document.changeset(%{
          file_name: filename,
          file_path: new_path,
          creator_id: curr_user.id
        })
        |> Repo.insert!()

      %AssignmentDocument{}
      |> AssignmentDocument.changeset(%{document_id: doc.id, assignment_id: assignment.id, attached: true})
      |> Repo.insert!()


      # complete assignment
      Repo.update!(change(assignment, completed: true))

      # return created document
      doc
    end)
  end


  def filename_infix(%{student_id: s_id, group_id: nil}) do
    st = MsnrApi.Students.get_student!(s_id)
    "#{st.user.first_name}#{st.user.last_name}"
  end

  def filename_infix(%{student_id: nil, group_id: group_id}) do
    %{students: students, topic: topic} = MsnrApi.Groups.get_group!(group_id)

    last_names =
      students
      |> Enum.map(& &1.user.last_name)
      |> Enum.join()

    topic_number = String.pad_leading("#{topic.number}", 2, "0")

    "#{topic_number}_#{last_names}_#{pascal_case_string(topic.title)}"
  end


  defp pascal_case_string(name) do
    name
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join()
  end
end
