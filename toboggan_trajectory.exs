defmodule TobogganTrajectory do
  def is_tree?(map_row, x) do
    String.at(map_row, Integer.mod(x, String.length(map_row))) == "#"
  end

  def move(map_row, %{x: x, trees: trees}, jump) do
    case is_tree?(map_row, x) do
      true -> %{x: x + jump, trees: trees + 1}
      false -> %{x: x + jump, trees: trees}
    end
  end

  def solve(map, jump \\ 3) do
    map
    |> Enum.reduce(%{x: 0, trees: 0}, fn row, acc -> move(row, acc, jump) end)
    |> Map.get(:trees)
  end

  def solve_two(map) do
    result =
      [1, 3, 5, 7]
      |> Enum.map(fn n -> solve(map, n) end)
      |> Enum.reduce(1, fn n, acc -> n * acc end)

    result * solve(Enum.drop_every([""] ++ map, 2), 1)
  end
end

File.read!("inputs/toboggan_trajectory")
|> String.split("\n", trim: true)
|> TobogganTrajectory.solve_two
|> IO.inspect
