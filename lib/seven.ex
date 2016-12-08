defmodule Advent.Seven do

  @path "./static/seven.txt"
  @sans_hypernet_pattern ~r/\[\w+\]/
  @hypernet_exclusive_pattern ~r/\[(\w+)\]/

  def run() do
    num_tls = File.stream!(@path)
    |> Enum.reduce(0, &num_support_tls/2)

    IO.puts "num support tls = #{num_tls}"
  end

  def run_ssl() do
    num_ssl = File.stream!(@path)
    |> Enum.reduce(0, &num_support_ssl/2)

    IO.puts "num support ssl = #{num_ssl}"
  end

  defp num_support_tls(row, count) do
    supernet_has_tsl = row
    |> trim_supernet()
    |> any_has_tsl(false)

    hypernet_has_tsl = row
    |> trim_hypernet()
    |> any_has_tsl(false)

    case supernet_has_tsl and !hypernet_has_tsl do
      true  -> count + 1
      false -> count
    end
  end

  defp num_support_ssl(row, count) do
    supernet_ssl_keys = row
    |> trim_supernet()
    |> Enum.reduce([], &ssl_keys_for_row/2)
    |> Enum.uniq()
    |> Enum.map(&inverse_ssl_keys/1)

    hypernet_ssl_keys = row
    |> trim_hypernet()
    |> Enum.reduce([], &ssl_keys_for_row/2)
    |> Enum.uniq()

    case ssl_keys_match(supernet_ssl_keys, hypernet_ssl_keys) do
      true  -> count + 1
      false -> count
    end
  end

  defp trim_supernet(row) do
    row
    |> String.replace(@sans_hypernet_pattern, "|")
    |> String.split("|")
  end

  defp trim_hypernet(row) do
    Regex.scan(@hypernet_exclusive_pattern, row)
    |> Enum.map(&(Enum.at(&1, 1)))
  end

  defp any_has_tsl(_, true), do: true
  defp any_has_tsl([], result), do: result
  defp any_has_tsl([section | tail], _) do
    result = section
    |> String.trim()
    |> String.graphemes()
    |> has_tsl(false)

    any_has_tsl(tail, result)
  end

  defp has_tsl(_, true), do: true
  defp has_tsl([], result), do: result
  defp has_tsl([letter | tail], _) do
    first = letter <> (Enum.at(tail, 0) || "")
    second = tail
    |> Enum.slice(1..2)
    |> Enum.reverse()
    |> Enum.join("")

    has_tsl(tail, first === second and has_unique_chars(first <> second))
  end

  defp has_unique_chars(str) do
    uniq = str
    |> String.graphemes()
    |> Enum.uniq()
    |> length()

    uniq > 1
  end

  defp ssl_keys_for_row(supernet, result) do
    section_result = supernet
    |> String.trim()
    |> String.graphemes()
    |> ssl_keys_for_row_section([])

    Enum.into(result, section_result)
  end

  defp ssl_keys_for_row_section([], result), do: result
  defp ssl_keys_for_row_section([letter | tail], result) do
    first = letter
    second = Enum.at(tail, 0) || ""
    third = Enum.at(tail, 1)  || ""

    result = case first === third and first !== second do
      true  -> Enum.into(result, [first <> second <> third])
      false -> result
    end

    ssl_keys_for_row_section(tail, result)
  end

  defp inverse_ssl_keys(str) do
    chars = String.graphemes(str)
    first = Enum.at(chars, 0)
    second = Enum.at(chars, 1)

    second <> first <> second
  end

  defp ssl_keys_match(supernet, hypernet) do
    supernet = Enum.into(supernet, HashSet.new)
    hypernet = Enum.into(hypernet, HashSet.new)

    matches = Set.intersection(supernet, hypernet)
    |> Set.to_list
    |> length()

    matches > 0
  end
end
