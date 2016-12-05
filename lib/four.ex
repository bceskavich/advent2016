defmodule Advent.Four do

  @path "./static/four.txt"
  @pattern ~r/(\D+)(?:(\d+)(?:\[(\w+)\]))/
  @expected_room ~r/north\s?pole\s?object\s?storage/
  @alphabet "abcdefghijklmnopqrstuvwxyz"

  ##############################################################################
  # Part 1 Logic:
  # Sum IDs of valid / decryptable rooms
  ##############################################################################

  def run do
    result = get_input
    |> check_each_room(0)

    IO.puts result
  end

  defp check_each_room([], sum), do: sum
  defp check_each_room(["" | tail], sum), do: check_each_room(tail, sum)
  defp check_each_room([room | tail], sum) do
    case check_room_validity(room) do
      :invalid ->
        check_each_room(tail, sum)
      {:valid, _, room_id} ->
        check_each_room(tail, sum + room_id)
    end
  end

  ##############################################################################
  # Part 2 Logic:
  # Get room ID of the room that is about North Pole object storage
  ##############################################################################

  def run_and_decode do
    result = get_input
    |> check_each_room_and_decode([])
    |> find_room()

    IO.puts "room id = #{result.id}"
  end

  defp check_each_room_and_decode([], result), do: result
  defp check_each_room_and_decode(["" | tail], result), do: check_each_room_and_decode(tail, result)
  defp check_each_room_and_decode([room | tail], result) do
    case check_room_validity(room) do
      :invalid ->
        check_each_room_and_decode(tail, result)
      {:valid, room_name, room_id} ->
        decoded_name = decode_room(room_name, room_id)
        result = List.insert_at(result, -1, %{id: room_id, name: decoded_name})
        check_each_room_and_decode(tail, result)
    end
  end

  defp find_room(rooms) do
    Enum.find(rooms, &(String.match?(&1.name, @expected_room)))
  end

  defp decode_room(name, id) do
    name
    |> String.split("")
    |> shift_and_join(id, "")
  end

  defp shift_and_join([], _, result), do: result
  defp shift_and_join(["" | tail], id, result) do
    shift_and_join(tail, id, result)
  end
  defp shift_and_join(["-" | tail], id, result) do
    shift_and_join(tail, id, result <> " ")
  end
  defp shift_and_join([letter | tail], id, result) do
    new_letter = shift_letter(id, letter)
    shift_and_join(tail, id, result <> new_letter)
  end

  defp shift_letter(0, letter), do: letter
  defp shift_letter(left, "z") do
    shift_letter(left - 1, String.at(@alphabet, 0))
  end
  defp shift_letter(left, letter) do
    index = String.split(@alphabet, "")
    |> Enum.find_index(&(&1 === letter))

    new_letter = String.at(@alphabet, index + 1)
    shift_letter(left - 1, new_letter)
  end

  ##############################################################################
  # Shared Logic
  ##############################################################################

  defp get_input do
    File.read!(@path)
    |> String.split("\n")
  end

  defp check_room_validity(room) do
    {room_name, room_id, checksum} = parse_room_name(room)

    expected_checksum = room_name
    |> String.split("")
    |> generate_frequency_distribution([])
    |> sort_frequency_distribution()
    |> get_expected_checksum()

    case expected_checksum === checksum do
      true  -> {:valid, room_name, String.to_integer(room_id)}
      false -> :invalid
    end
  end

  defp parse_room_name(room) do
    parsed = Regex.run(@pattern, room)
    {
      Enum.at(parsed, 1),
      Enum.at(parsed, 2),
      Enum.at(parsed, 3)
    }
  end

  defp generate_frequency_distribution([], dist), do: dist
  defp generate_frequency_distribution(["-" | tail], dist) do
    generate_frequency_distribution(tail, dist)
  end
  defp generate_frequency_distribution(["" | tail], dist) do
    generate_frequency_distribution(tail, dist)
  end
  defp generate_frequency_distribution([letter | tail], dist) do
    case Enum.find_index(dist, fn(%{value: value}) -> value === letter end) do
      nil ->
        dist = List.insert_at(dist, -1, %{value: letter, freq: 1})
      index ->
        current = Enum.at(dist, index)
        dist = List.replace_at(dist, index, %{value: letter, freq: current.freq + 1})
    end

    generate_frequency_distribution(tail, dist)
  end

  defp sort_frequency_distribution(dist) do
    Enum.sort(dist, fn (current, prev) ->
      case current.freq > prev.freq do
        true  -> true
        false -> compare_alphabetically(current, prev)
      end
    end)
  end

  defp compare_alphabetically(current, previous) do
    case current.freq === previous.freq do
      true  -> current.value < previous.value
      false -> false
    end
  end

  defp get_expected_checksum(dist) do
    dist
    |> Enum.take(5)
    |> Enum.map(&(&1.value))
    |> Enum.join("")
  end
end
