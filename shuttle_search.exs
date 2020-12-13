defmodule ShuttleSearch do
  def parse([first_line, second_line]) do
    buses =
      second_line
      |> String.split(",")
      |> Enum.map(fn item ->
        case Integer.parse(item) do
          :error -> :x
          {number, _} -> number
        end
      end)

    {String.to_integer(first_line), buses}
  end

  def solve({now, buses}) do
    buses
    |> Enum.filter(fn item -> item != :x end)
    |> Enum.reduce(%{bus: nil, wait: :infinity}, fn bus, %{} = winner ->
      wait = bus - rem(now, bus)
      cond do
        wait < winner[:wait] -> %{bus: bus, wait: wait}
        true -> winner
      end
    end)
    |> Map.values()
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  def find_first(x, mod_a, {rem_b, mod_b}) do
    cond do
      rem(x, mod_b) == rem_b -> x
      true -> find_first(x + mod_a, mod_a, {rem_b, mod_b})
    end
  end

  def merge({mod_a, rem_a}, {mod_b, rem_b}) do
    first =
      cond do
        mod_a < mod_b -> find_first(rem_a, mod_a, {rem_b, mod_b})
        true -> find_first(rem_b, mod_b, {rem_a, mod_a})
      end
    {mod_a * mod_b, first}
  end

  def solve_two({_now, buses}) do
    {mod, rem} =
      buses
      |> Enum.with_index()
      |> Enum.filter(fn {bus, _} -> bus != :x end)
      |> Enum.reduce(&merge/2)
    mod - rem
  end
end

File.read!("inputs/shuttle_search")
|> String.split("\n", trim: true)
|> ShuttleSearch.parse()
|> ShuttleSearch.solve_two()
|> IO.inspect()
