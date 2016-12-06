defmodule Advent.Six do

  @path "./static/six.txt"

  def run do
    result = get_input
    |> read_row(initial)
    |> sort_each_column()
    |> build_message()

    IO.puts "decrypted message = #{result}"
  end

  def run_asc do
    result = get_input
    |> read_row(initial)
    |> sort_each_column_asc()
    |> build_message()

    IO.puts "decrypted message = #{result}"
  end

  defp get_input do
    File.read!(@path)
    |> String.split("\n")
  end

  defp initial do
    for _ <- 1..8 do [] end
  end

  defp read_row([], dist), do: dist
  defp read_row([[] | tail], dist), do: read_row(tail, dist)
  defp read_row([row | tail], dist) do
    dist = String.split(row, "")
    |> Enum.with_index
    |> Enum.reduce(dist, fn(with_index, current) -> update_frequency_dist(with_index, current) end)

    read_row(tail, dist)
  end

  defp update_frequency_dist({"", _}, current), do: current
  defp update_frequency_dist({letter, index}, current) do
    case index < length(current) do
      true ->
        column = Enum.at(current, index)
        column_index = column
        |> Enum.find_index(fn(%{value: value}) -> value === letter end)

        update = case column_index do
          nil ->
            List.insert_at(column, -1, %{value: letter, freq: 1})
          idx ->
            List.replace_at(column, idx, %{value: letter, freq: Enum.at(column, idx).freq + 1})
        end

        List.replace_at(current, index, update)

      false ->
        current
    end
  end

  defp sort_each_column(dist) do
    Enum.map(dist, fn(column) ->
      Enum.sort(column, &(&1.freq > &2.freq))
    end)
  end

  defp sort_each_column_asc(dist) do
    Enum.map(dist, fn(column) ->
      Enum.sort(column, &(&1.freq < &2.freq))
    end)
  end

  defp build_message(sorted) do
    Enum.map(sorted, &(Enum.at(&1, 0).value))
    |> Enum.join("")
  end
end
