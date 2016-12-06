defmodule Advent.Five do

  @password               "cxdnnyjw"
  @pattern                ~r/^00000([0-9a-z])/
  @pattern_with_position  ~r/^00000([0-7])([0-9a-z])/

  defp make_hash(str) do
    :crypto.hash(:md5, str)
    |> Base.encode16()
    |> String.downcase()
  end

  ##############################################################################
  # Part 1 Logic: Incremental decryption
  ##############################################################################

  def run do
    decrypted = decrypt(@password, 0, "")
    IO.puts "decrypted password = `#{decrypted}`"
  end

  defp decrypt(_, _, result) when byte_size(result) === 8 do
    result
  end
  defp decrypt(password, number, result) do
    case hash_and_parse(password, number) do
      {:match, letter} ->
        decrypt(password, number + 1, result <> letter)
      :continue ->
        decrypt(password, number + 1, result)
    end
  end

  defp hash_and_parse(password, number) do
    password <> Integer.to_string(number)
    |> make_hash
    |> parse_hash
  end

  defp parse_hash(hash) do
    case Regex.match?(@pattern, hash) do
      true ->
        new_letter = Regex.run(@pattern, hash) |> Enum.at(1)
        {:match, new_letter}
      false ->
        :continue
    end
  end

  ##############################################################################
  # Part 2 Logic: Decryption w/ position
  ##############################################################################

  def run_with_position do
    initial = for _ <- 1..8 do "" end

    decrypted = @password
    |> decrypt(0, initial, 0)
    |> Enum.join("")

    IO.puts "decrypted password = `#{decrypted}`"
  end

  defp decrypt(_, _, result, 8), do: result
  defp decrypt(password, number, result, count) do
    case hash_and_parse(password, number, result) do
      {:match, position, letter} ->
        result = List.replace_at(result, position, letter)
        decrypt(password, number + 1, result, count + 1)
      :continue ->
        decrypt(password, number + 1, result, count)
    end
  end

  defp hash_and_parse(password, number, current) do
    password <> Integer.to_string(number)
    |> make_hash
    |> parse_hash_with_position(current)
  end

  defp parse_hash_with_position(hash, current) do
    case Regex.match?(@pattern_with_position, hash) do
      true  -> match_or_continue(hash, current)
      false -> :continue
    end
  end

  defp match_or_continue(hash, current) do
    match = Regex.run(@pattern_with_position, hash)
    letter = Enum.at(match, 2)
    position = match
    |> Enum.at(1)
    |> String.to_integer

    case Enum.at(current, position) === "" do
      true  -> {:match, position, letter}
      false -> :continue
    end
  end
end
