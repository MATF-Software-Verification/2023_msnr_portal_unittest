defmodule MsnrApiWeb.GroupView do
  use MsnrApiWeb, :view
  alias MsnrApiWeb.GroupView

  def render("index.json", %{groups: groups}) do
    %{data: render_many(groups, GroupView, "group.json")}
  end

  def render("show.json", %{group: group}) do
    %{data: render_one(group, GroupView, "group.json")}
  end

  def render("show_shallow.json", %{group: group}) do
    %{data: render_one(group, GroupView, "group_shallow.json")}
  end

  def render("group.json", %{group: group}) do
    %{
      id: group.id,
      students:
        render_many(
          Enum.map(group.students, fn st -> %{student: st, group_id: group.id} end),
          MsnrApiWeb.StudentView,
          "student.json"
        ),
      topic: group.topic && MsnrApiWeb.TopicView.render("topic.json", topic: group.topic)
    }
  end

  def render("group_shallow.json", %{group: group}), do: %{id: group.id}
end
