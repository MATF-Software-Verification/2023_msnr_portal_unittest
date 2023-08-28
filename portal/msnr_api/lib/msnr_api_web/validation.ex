defmodule MsnrApiWeb.Validation do
  alias MsnrApi.Accounts.TokenPayload

  def validate_time(%{role: :professor}, _), do: {:ok}

  def validate_time(_, %{start_date: start_date, end_date: end_date}) do
    time = System.os_time(:second)

    case time > start_date && time <= end_date + 60 do
      true -> {:ok}
      false -> {:error, :bad_request}
    end
  end

  def validate_user(%TokenPayload{} = curr_user, %{student_id: student_id, group_id: group_id}) do
    case curr_user do
      %{role: :professor} -> {:ok}
      %{id: ^student_id} -> {:ok}
      %{group_id: ^group_id} -> {:ok}
      _ -> {:error, :unauthorized}
    end
  end

  def validate_files(docIds, docs, %{"files" => files}) do
    doc_map = Enum.zip_reduce(docIds, docs, %{}, fn id, doc, acc -> Map.put(acc, id, doc) end)

    result =
      Enum.reduce(files, [], fn %{"name" => name, "extension" => extension}, acc ->
        case doc_map[name <> extension] do
          %{path: path} -> [{name, extension, path} | acc]
          _ -> acc
        end
      end)

    if length(files) == length(result) do
      {:ok, result}
    else
      {:error, :bad_request}
    end
  end
end
