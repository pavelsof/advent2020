defmodule HandyHaversacks do
  def line_reducer(line, acc) do
    [_, container] = Regex.run(~r/^([a-z ]+) bags contain/, line)

    contents =
      Regex.scan(~r/(\d+) ([a-z ]+) bag/, line)
      |> Enum.map(fn [_, number, bag] -> {String.to_integer(number), bag} end)

    Map.put(acc, container, contents)
  end

  def inside_out_reducer({big_bag, contents}, acc) do
    Enum.reduce(contents, acc, fn {_number, small_bag}, acc ->
      case Map.get(acc, small_bag) do
        nil -> Map.put(acc, small_bag, MapSet.new([big_bag]))
        value -> Map.replace(acc, small_bag, MapSet.put(value, big_bag))
      end
    end)
  end

  def recurse_outwards(map, key) do
    case Map.get(map, key) do
      nil -> MapSet.new()
      values ->
        Enum.reduce(values, values, fn value, acc ->
          MapSet.union(acc, recurse_outwards(map, value))
        end)
    end
  end

  def solve(bags) do
    bags
    |> Map.to_list
    |> Enum.reduce(%{}, &inside_out_reducer/2)
    |> recurse_outwards("shiny gold")
    |> Enum.count
  end

  def count_inside(bags, big_bag) do
    Map.get(bags, big_bag)
    |> Enum.map(fn {number, small_bag} ->
      number * (1 + count_inside(bags, small_bag))
    end)
    |> Enum.sum
  end

  def solve_two(bags) do
    count_inside(bags, "shiny gold")
  end
end

File.read!("inputs/handy_haversacks")
|> String.split("\n", trim: true)
|> Enum.reduce(%{}, &HandyHaversacks.line_reducer/2)
|> HandyHaversacks.solve
|> IO.puts
