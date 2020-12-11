defmodule SeatingSystem do
  def get_cell(grid, {row, col}) do
    cond do
      (row < 0) or (col < 0) -> nil
      true ->
        case Enum.at(grid, row) do
          nil -> nil
          line -> Enum.at(line, col)
        end
    end
  end

  def count_adjacent(grid, {row, col}, what) do
    adjacent =
      for i <- -1..1, j <- -1..1 do
        cond do
          i == 0 and j == 0 -> nil
          true -> get_cell(grid, {row + i, col + j})
        end
      end
    Enum.count(adjacent, fn x -> x == what end)
  end

  def find_next_seat(grid, {row, col}, {dir_x, dir_y}) do
    case get_cell(grid, {row, col}) do
      "." -> find_next_seat(grid, {row + dir_x, col + dir_y}, {dir_x, dir_y})
      cell -> cell
    end
  end

  def count_queen(grid, {row, col}, what) do
    queen =
      for i <- -1..1, j <- -1..1 do
        cond do
          i == 0 and j == 0 -> nil
          true -> find_next_seat(grid, {row + i, col + j}, {i, j})
        end
      end
    Enum.count(queen, fn x -> x == what end)
  end

  def update_grid(grid, count_func, tol \\ 4) do
    grid
    |> Enum.with_index()
    |> Enum.map(fn {line, row} ->
      line
      |> Enum.with_index()
      |> Enum.map(fn {cell, col} ->
        case cell do
          "L" ->
            if count_func.(grid, {row, col}, "#") == 0, do: "#", else: "L"
          "#" ->
            if count_func.(grid, {row, col}, "#") >= tol, do: "L", else: "#"
          "." -> "."
        end
      end)
    end)
  end

  def solve(grid, count_func, tolerance) do
    next_grid = update_grid(grid, count_func, tolerance)
    if grid == next_grid do
      grid
      |> List.flatten()
      |> Enum.count(fn x -> x == "#" end)
    else
      solve(next_grid, count_func, tolerance)
    end
  end
end

File.read!("inputs/seating_system")
|> String.split("\n", trim: true)
|> Enum.map(&String.graphemes/1)
|> SeatingSystem.solve(&SeatingSystem.count_queen/3, 5)
|> IO.puts()
