defmodule HandheldHalting do
  def parse(line) do
    [_, operator, param] = Regex.run(~r/(acc|jmp|nop) ([0-9+-]+)/, line)
    {String.to_atom(operator), String.to_integer(param)}
  end

  def mark_done(code, line_num) do
    List.replace_at(code, line_num, {:done})
  end

  def run(code, line_num, accumulator) do
    case Enum.at(code, line_num) do
      {:acc, param} -> run(mark_done(code, line_num), line_num + 1, accumulator + param)
      {:jmp, param} -> run(mark_done(code, line_num), line_num + param, accumulator)
      {:nop, _} -> run(mark_done(code, line_num), line_num + 1, accumulator)
      {:done} -> {:infinite_loop, accumulator}
      nil -> {:ok, accumulator}
    end
  end

  def solve(code) do
    {:infinite_loop, accumulator} = run(code, 0, 0)
    accumulator
  end

  def check(code) do
    case run(code, 0, 0) do
      {:ok, accumulator} -> accumulator
      {:infinite_loop, _} -> nil
    end
  end

  def solve_two(code) do
    code
    |> Enum.with_index
    |> Enum.find_value(fn {line, index} ->
      case line do
        {:acc, _} -> nil
        {:jmp, param} -> check(List.replace_at(code, index, {:nop, param}))
        {:nop, param} -> check(List.replace_at(code, index, {:jmp, param}))
      end
    end)
  end
end

File.read!("inputs/handheld_halting")
|> String.split("\n", trim: true)
|> Enum.map(&HandheldHalting.parse/1)
|> HandheldHalting.solve_two
|> IO.inspect
