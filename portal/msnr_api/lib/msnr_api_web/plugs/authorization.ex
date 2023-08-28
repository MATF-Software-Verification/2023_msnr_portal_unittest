defmodule MsnrApiWeb.Plugs.Authorization do
  import Plug.Conn

  def professor_only(conn, _options) do
    with %{role: :professor} <- conn.assigns[:user_info] do
        conn
     else
      mismatched ->
        conn
          |> send_response(mismatched)
    end
  end

  def allow_students(conn, options) do
    with %{role: :student, id: student_id} <- conn.assigns[:user_info],
        true <- valid_student_id?(conn.path_params["student_id"], student_id) do
          conn
    else
      _ ->
        professor_only(conn, options)
    end
  end

  defp valid_student_id?(studnet_id_param, student_id) do
    !studnet_id_param || "#{student_id}" == studnet_id_param
  end

  defp send_response(conn, nil) do
    conn
    |> resp(:unauthorized, "Unauthorized")
    |> send_resp()
    |> halt()
  end

  defp send_response(conn, _) do
    conn
    |> resp(:forbidden, "Forbidden")
    |> send_resp()
    |> halt()
  end



end
