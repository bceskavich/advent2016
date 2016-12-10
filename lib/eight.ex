defmodule Advent.Eight do

  @path "./static/eight.txt"
  @pattern_rect ~r/rect\s((?<width>\d+)x(?<height>\d+))/
  @pattern_rotate_column ~r/rotate\scolumn\sx=(?<column>\d+)\sby\s(?<shift>\d+)/
  @pattern_rotate_row ~r/rotate\srow\sy=(?<row>\d+)\sby\s(?<shift>\d+)/

  @num_rows 6
  @num_columns 50

  def test() do
    build_screen()
    |> activate_grid(3, 2)
    |> rotate_column(1, 1)
    |> rotate_row(0, 4)
    |> rotate_column(1, 1)
  end

  def run() do
    screen = build_screen()
    result = File.stream!(@path)
    |> Enum.reduce(screen, &apply_row_instructions/2)
    |> num_on()

    IO.puts "number on = #{result}"
  end

  def run_and_print() do
    screen = build_screen()
    File.stream!(@path)
    |> Enum.reduce(screen, &apply_row_instructions/2)
    |> Enum.each(&print_row/1)
  end

  defp print_row(row) do
    row
    |> Enum.map(&cell_to_string/1)
    |> Enum.join("")
    |> IO.puts
  end

  defp cell_to_string(cell) do
    case cell do
      :on   -> "X"
      :off  -> " "
    end
  end

  ### screen logic

  defp build_screen() do
    for _ <- 1..@num_rows do
      for _ <- 1..@num_columns do
        :off
      end
    end
  end

  defp num_on(screen) do
    screen
    |> Enum.reduce(0, fn(row, acc) -> Enum.reduce(row, acc, &count_on/2) end)
  end

  defp count_on(:off, acc), do: acc
  defp count_on(:on, acc), do: acc + 1


  ### row parser

  defp apply_row_instructions(row, screen) do
    row = String.trim(row)
    cond do
      Regex.match?(@pattern_rect, row) ->
        instructions = Regex.named_captures(@pattern_rect, row)
        width = instructions["width"] |> String.to_integer
        height = instructions["height"] |> String.to_integer
        activate_grid(screen, width, height)

      Regex.match?(@pattern_rotate_column, row) ->
        instructions = Regex.named_captures(@pattern_rotate_column, row)
        column = instructions["column"] |> String.to_integer
        shift = instructions["shift"] |> String.to_integer
        rotate_column(screen, column, shift)

      Regex.match?(@pattern_rotate_row, row) ->
        instructions = Regex.named_captures(@pattern_rotate_row, row)
        row = instructions["row"] |> String.to_integer
        shift = instructions["shift"] |> String.to_integer
        rotate_row(screen, row, shift)

      true ->
        IO.puts "row fails to match any instruction set"
        IO.puts row
        screen
    end
  end

  ### rect <width>x<height>

  defp activate_grid(screen, width, height) do
    screen
    |> Enum.with_index()
    |> Enum.map(fn(row) -> update_row(row, width, height) end)
  end

  defp update_row({row, index}, width, height) do
    case index < height do
      true ->
        row
        |> Enum.with_index()
        |> Enum.map(fn(cell) -> update_cell(cell, width) end)

      false ->
        row
    end
  end

  defp update_cell({cell, index}, width) do
    case index < width do
      true  -> :on
      false -> cell
    end
  end

  ### rotate row y=<row> by <shift>

  defp rotate_row(screen, row_index, shift) do
    row = Enum.at(screen, row_index)
    shifted = for n <- 0..@num_columns - 1 do
      Enum.at(row, get_index(n, shift, @num_columns))
    end

    List.replace_at(screen, row_index, shifted)
  end

  ### rotate column x=<column> by <shift>

  defp rotate_column(screen, column_index, shift) do
    shifted = for n <- 0..@num_rows - 1 do
      Enum.at(screen, get_index(n, shift, @num_rows))
      |> Enum.at(column_index)
    end

    screen
    |> Enum.with_index()
    |> Enum.map(fn({row, index}) ->
      List.replace_at(row, column_index, Enum.at(shifted, index))
    end)
  end

  ### shared helper

  defp get_index(index, shift, max) do
    result = index - shift
    case result < 0 do
      true  -> result + max
      false -> result
    end
  end
end
