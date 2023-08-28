defmodule MsnrApi.Topics.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :title, :string
    field :number, :integer
    belongs_to :semester, MsnrApi.Semesters.Semester
    has_one :group, MsnrApi.Groups.Group

    timestamps()
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:title, :semester_id])
    |> validate_required([:title, :semester_id])
    |> set_number()
  end

  defp set_number(%Ecto.Changeset{changes: %{semester_id: semester_id}} = changeset) do
    changeset
    |> put_change(:number, MsnrApi.Topics.next_topic_number(semester_id))
  end

end
