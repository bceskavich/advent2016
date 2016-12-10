defmodule Advent.Nine do

  @path "./static/nine.txt"
  @pattern ~r/(\((\d+)x(\d+)\))/

  def run() do
    result = read_file()
    |> decrypt(0)

    IO.puts "decompressed length = #{result}"
  end

  def run_v2() do
    result = read_file()
    |> decrypt_v2(0)

    IO.puts "decompressed v2 length = #{result}"
  end

  defp read_file() do
    File.read!(@path)
    |> String.trim()
    |> String.replace(" ", "")
    |> String.graphemes()
  end

  defp get_sequence(string) do
    [sequence, _, count, by] = Regex.run(@pattern, string)
    rest = String.slice(string, String.length(sequence)..-1)

    %{count: String.to_integer(count), by: String.to_integer(by), rest: rest}
  end

  ### part 1: decryption

  defp decrypt([], result), do: result
  defp decrypt([letter | tail], result) do
    case letter do
      "(" ->
        {tail, result} = parse_sequence(letter <> Enum.join(tail, ""), result)
        decrypt(tail, result)

      _ ->
        decrypt(tail, result + 1)
    end
  end

  defp parse_sequence(string, result) do
    string
    |> get_sequence()
    |> apply_sequence(result)
  end

  defp apply_sequence(%{count: count, by: by, rest: rest}, result) do
    group_length = rest
    |> String.slice(0..count - 1)
    |> String.length()

    section_length = group_length * by
    tail = rest
    |> String.slice(count..-1)
    |> String.graphemes()

    {tail, result + section_length}
  end

  ### part 2: decryption v2 - recursive sequence application to count all groups

  defp decrypt_v2([], result), do: result
  defp decrypt_v2([letter | tail], result) do
    case letter do
      "(" ->
        {tail, result} = parse_sequence_v2(letter <> Enum.join(tail, ""), result)
        decrypt_v2(tail, result)

      _ ->
        decrypt_v2(tail, result + 1)
    end
  end

  defp parse_sequence_v2(string, result) do
    string
    |> get_sequence()
    |> apply_sequence_v2(result)
  end

  defp apply_sequence_v2(%{count: count, by: by, rest: rest}, result) do
    group_length = rest
    |> String.slice(0..count - 1)
    |> String.graphemes()
    |> decrypt_v2(0)

    section_length = group_length * by
    tail = rest
    |> String.slice(count..-1)
    |> String.graphemes()

    {tail, result + section_length}
  end
end
