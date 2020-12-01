defmodule ReportRepair do
  def recurse([], _counterparts, _total) do
    nil
  end

  def recurse([x | rest], counterparts, total) do
    case MapSet.member?(counterparts, x) do
      true -> {x, total - x}
      false -> recurse(rest, MapSet.put(counterparts, total - x), total)
    end
  end

  def solve(list, total) do
    {x, y} = recurse(list, MapSet.new(), total)
    x * y
  end

  def recurse_two([x | rest], total) do
    case recurse(rest, MapSet.new(), total - x) do
      {y, z} -> {x, y, z}
      nil -> recurse_two(rest, total)
    end
  end

  def solve_two(list, total) do
    {x, y, z} = recurse_two(list, total)
    x * y * z
  end
end

File.read!("inputs/report_repair")
|> String.split("\n", trim: true)
|> Enum.map(fn line -> String.to_integer(line) end)
|> ReportRepair.solve_two(2020)
|> IO.puts
