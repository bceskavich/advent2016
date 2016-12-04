defmodule Advent.Three do

  @num_valid 0
  @path "./static/three.txt"

  def run() do
    result = File.read!(@path)
    |> parse_instructions()
    |> parse_by_column([])
    |> parse_triangles(@num_valid)

    IO.puts "num valid = #{result}"
  end

  def parse_instructions(instructions) do
    String.split(instructions, "\n")
    |> Enum.map(fn row ->
      String.split(row, " ")
      |> Enum.reduce([], fn(num, acc) ->
        case num do
          "" -> acc
          _ -> List.insert_at(acc, -1, String.to_integer(num))
        end
      end)
    end)
  end

  def parse_by_column([], new_grid), do: new_grid
  def parse_by_column(grid, new_grid) do
    section = Enum.take(grid, 3)
    case section do
      [[]] -> nil
      _ ->
        new_grid = Enum.concat(new_grid, [
                    flip_grid(section, 0),
                    flip_grid(section, 1),
                    flip_grid(section, 2)
                  ])
    end

    Enum.slice(grid, 3..-1)
    |> parse_by_column(new_grid)
  end

  def flip_grid(section, i) do
    [
      section |> Enum.at(0) |> Enum.at(i),
      section |> Enum.at(1) |> Enum.at(i),
      section |> Enum.at(2) |> Enum.at(i)
    ]
  end

  def parse_triangles([], count), do: count
  def parse_triangles([[] | tail], count), do: parse_triangles(tail, count)
  def parse_triangles([triangle | tail], count) do
    case is_valid(triangle) do
      true  -> parse_triangles(tail, count + 1)
      false -> parse_triangles(tail, count)
    end
  end

  def is_valid(triangle) do
    max = Enum.max(triangle)
    sum = Enum.sum(triangle) - max

    max < sum
  end
end
