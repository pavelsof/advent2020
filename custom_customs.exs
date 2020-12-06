defmodule CustomCustoms do
  def parse_group(text) do
    text
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  def count_unique(group) do
    group
    |> List.flatten
    |> MapSet.new
    |> Enum.count
  end

  def count_common(group) do
    group
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.intersection/2)
    |> Enum.count
  end
end

File.read!("inputs/custom_customs")
|> String.split("\n\n")
|> Enum.map(fn chunk ->
  chunk
  |> CustomCustoms.parse_group
  |> CustomCustoms.count_common
end)
|> Enum.sum
|> IO.inspect
