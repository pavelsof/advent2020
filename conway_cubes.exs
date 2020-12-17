defmodule ConwayCubes do
  def new_cube(x, y, dimensions) do
    case dimensions do
      2 -> {x, y}
      higher -> Tuple.append(new_cube(x, y, higher - 1), 0)
    end
  end

  def parse(lines, dimensions: dimensions) do
    lines
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {line, y}, acc ->
      line
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {char, x}, acc ->
        case char do
          "#" -> MapSet.put(acc, new_cube(x, y, dimensions))
          _ -> acc
        end
      end)
    end)
  end

  def get_adjacent({x, y, z}) do
    space =
      for p <- (x - 1)..(x + 1),
          q <- (y - 1)..(y + 1),
          r <- (z - 1)..(z + 1) do
        {p, q, r}
      end

    space |> MapSet.new() |> MapSet.delete({x, y, z})
  end

  def get_adjacent({x, y, z, w}) do
    space =
      for p <- (x - 1)..(x + 1),
          q <- (y - 1)..(y + 1),
          r <- (z - 1)..(z + 1),
          s <- (w - 1)..(w + 1) do
        {p, q, r, s}
      end

    space |> MapSet.new() |> MapSet.delete({x, y, z, w})
  end

  def count_adjacent(state, cube) do
    cube
    |> get_adjacent()
    |> Enum.count(fn coords -> MapSet.member?(state, coords) end)
  end

  def will_be_cube?(state, coords) do
    adjacent = count_adjacent(state, coords)

    case MapSet.member?(state, coords) do
      true -> adjacent == 2 or adjacent == 3
      false -> adjacent == 3
    end
  end

  def run_cycle(state) do
    state
    |> Enum.reduce(state, fn cube, acc ->
      MapSet.union(acc, get_adjacent(cube))
    end)
    |> Enum.reduce(MapSet.new(), fn coords, acc ->
      case will_be_cube?(state, coords) do
        true -> MapSet.put(acc, coords)
        false -> acc
      end
    end)
  end

  def count_cubes_after(state, cycles: cycles) do
    1..cycles
    |> Enum.reduce(state, fn _, state -> run_cycle(state) end)
    |> MapSet.size()
  end
end

File.read!("inputs/conway_cubes")
|> String.split("\n", trim: true)
|> Enum.map(&String.graphemes/1)
|> ConwayCubes.parse(dimensions: 4)
|> ConwayCubes.count_cubes_after(cycles: 6)
|> IO.puts()
