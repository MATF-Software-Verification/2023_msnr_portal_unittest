defmodule MsnrApi.DocumentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MsnrApi.Documents` context.
  """

  @doc """
  Generate a document.
  """
  def document_fixture(attrs \\ %{}) do
    {:ok, document} =
      attrs
      |> Enum.into(%{
        file_name: "some file_name",
        file_path: "some file_path"
      })
      |> MsnrApi.Documents.create_document()

    document
  end
end
