defmodule DockingData do
  def parse(line) do
    cond do
      String.starts_with?(line, "mask") ->
        [_, mask] = Regex.run(~r/mask = ([X01]+)/, line)
        {:mask, String.graphemes(mask)}

      String.starts_with?(line, "mem") ->
        [_, key, value] = Regex.run(~r/mem\[(\d+)\] = (\d+)/, line)
        {:mem, String.to_integer(key), String.to_integer(value)}
    end
  end

  def mask_value(value, mask) do
    digits =
      value
      |> Integer.digits(2)
      |> Enum.reverse()

    mask
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {bit, index} ->
      case bit do
        "X" ->
          case Enum.at(digits, index) do
            nil -> 0
            digit -> digit
          end

        "0" -> 0
        "1" -> 1
      end
    end)
    |> Enum.reverse()
    |> Integer.undigits(2)
  end

  def run(line, %{mask: mask, memory: memory}) do
    case line do
      {:mask, mask} ->
        %{mask: mask, memory: memory}

      {:mem, key, value} ->
        %{mask: mask, memory: Map.put(memory, key, mask_value(value, mask))}
    end
  end

  def expand_floats([], coll) do
    coll
  end

  def expand_floats([bit | rest], coll) do
    coll =
      case bit do
        :floating -> Enum.flat_map(coll, fn x -> [[1 | x], [0 | x]] end)
        bit -> Enum.map(coll, fn x -> [bit | x] end)
      end

    expand_floats(rest, coll)
  end

  def mask_address(address, mask) do
    digits = address |> Integer.digits(2) |> Enum.reverse()

    mask
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {bit, index} ->
      case bit do
        "0" ->
          case Enum.at(digits, index) do
            nil -> 0
            digit -> digit
          end

        "1" -> 1
        "X" -> :floating
      end
    end)
    |> expand_floats([[]])
    |> Enum.map(fn x -> Integer.undigits(x, 2) end)
  end

  def run_v2(line, %{mask: mask, memory: memory}) do
    case line do
      {:mask, new_mask} ->
        %{mask: new_mask, memory: memory}

      {:mem, key, value} ->
        memory =
          key
          |> mask_address(mask)
          |> Enum.reduce(memory, fn x, acc -> Map.put(acc, x, value) end)

        %{mask: mask, memory: memory}
    end
  end

  def solve(lines, run_func) do
    lines
    |> Enum.reduce(%{mask: nil, memory: %{}}, run_func)
    |> Map.get(:memory)
    |> Map.values()
    |> Enum.sum()
  end
end

File.read!("inputs/docking_data")
|> String.split("\n", trim: true)
|> Enum.map(&DockingData.parse/1)
|> DockingData.solve(&DockingData.run_v2/2)
|> IO.inspect()
