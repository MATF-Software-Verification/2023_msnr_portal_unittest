defmodule MsnrApiWeb.DocumentView do
  use MsnrApiWeb, :view
  alias MsnrApiWeb.DocumentView

  def render("index.json", %{documents: documents}) do
    %{data: render_many(documents, DocumentView, "document.json")}
  end

  def render("show.json", %{document: document}) do
    %{data: render_one(document, DocumentView, "document.json")}
  end

  def render("document.json", %{document: %{attached: true} = document}) do
    %{
      id: document.id,
      file_name: document.file_name,
      attached: true
    }
  end

  def render("document.json", %{document: document}) do
    %{
      id: document.id,
      file_name: document.file_name,
      attached: false
    }
  end
end
