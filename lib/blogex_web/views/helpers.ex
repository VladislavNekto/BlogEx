defmodule BlogexWeb.Helpers do
  def toggle_direction(direction) do
    if direction == :asc do
      "desc"
    else
      "asc"
    end
  end

  def new_path(conn, key, value) do
    key = _to_string(key)
    query_params = Map.put(conn.query_params, key, value)
    "/#{Enum.join(conn.path_info, "/")}?#{URI.encode_query(query_params)}"
  end

  def new_path(conn, opts) do
    opts_map = for {k, v} <- opts, into: %{}, do: {_to_string(k), v}
    query_params = Map.merge(conn.query_params, opts_map)
    "/#{Enum.join(conn.path_info, "/")}?#{URI.encode_query(query_params)}"
  end

  defp _to_string(key) do
    if is_atom(key) do
      to_string(key)
    else
      key
    end
  end
end
