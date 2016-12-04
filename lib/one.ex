defmodule Advent.One do

  @start_position {0, 0}
  @start_heading 0
  @visited [{0, 0}]

  def run(instructions) do
    result = String.split(instructions, ", ")
    |> read_item(@start_position, @start_heading, @visited)
    |> sum_result()

    IO.puts result
  end

  def sum_result({x, y}), do: abs(x) + abs(y)

  def read_item([], position, _, _), do: position
  def read_item([action | tail], position, heading, visited) do
    direction = String.at(action, 0)
    heading = turn(direction, heading)
    steps = action
    |> String.slice(1..-1)
    |> String.to_integer

    case move(steps, position, heading, visited) do
      {:found, position, heading, visited} ->
        read_item([], position, heading, visited)
      {:continue, position, heading, visited} ->
        read_item(tail, position, heading, visited)
    end
  end

  def move(0, position, heading, visited), do: {:continue, position, heading, visited}
  def move(steps, position, heading, visited) do
    {x, y} = step(heading, position)
    case Enum.member?(visited, {x, y}) do
      true ->
        {:found, {x, y}, heading, visited}
      false ->
        visited = List.insert_at(visited, -1, {x, y})
        move(steps - 1, {x, y}, heading, visited)
    end
  end

  # 0: North
  # 1: East
  # 2: South
  # 3: West
  def step(0, {x, y}), do: { x, y - 1 }
  def step(1, {x, y}), do: { x + 1, y }
  def step(2, {x, y}), do: { x, y + 1 }
  def step(3, {x, y}), do: { x - 1, y }

  def turn("R", 3), do: 0
  def turn("R", dir), do: dir + 1
  def turn("L", 0), do: 3
  def turn("L", dir), do: dir - 1
end
