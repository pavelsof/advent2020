defmodule AdapterArray do
  def solve(sorted) do
    diffs =
      [0 | sorted]
      |> Enum.zip(sorted ++ [nil])
      |> Enum.reduce(%{}, fn {i, j}, acc ->
        diff = if j, do: j - i, else: 3
        Map.update(acc, diff, 1, fn x -> x + 1 end)
      end)

    diffs[1] * diffs[3]
  end

  def count_ways([x | list], %{} = counts) when map_size(counts) == 0 do
    count_ways(list, Map.put(counts, x, 1))
  end

  def count_ways([], %{} = counts) do
    counts
  end

  def count_ways([x | list], %{} = counts) do
    value =
      [1, 2, 3]
      |> Enum.reduce(0, fn y, acc ->
        case Map.get(counts, x + y) do
          nil -> acc
          value -> acc + value
        end
      end)

    count_ways(list, Map.put(counts, x, value))
  end

  def solve_two(sorted) do
    [0 | sorted]
    |> Enum.reverse
    |> count_ways(%{})
    |> Map.get(0)
  end
end

File.read!("inputs/adapter_array")
|> String.split("\n", trim: true)
|> Enum.map(&String.to_integer/1)
|> Enum.sort()
|> AdapterArray.solve_two()
|> IO.inspect
