defmodule MsnrApi.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    belongs_to :topic, MsnrApi.Topics.Topic
    has_many :student_semester, MsnrApi.Students.StudentSemester
    has_many :students, through: [:student_semester, :student]

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:topic_id])
    |> validate_required([:topic_id])
    |> unique_constraint([:topic_id])
  end
end
