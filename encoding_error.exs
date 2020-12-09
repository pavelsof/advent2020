defmodule EncodingError do
  def follows_rule?(preamble, next) do
    set = MapSet.new(preamble)
    Enum.any?(preamble, fn i -> MapSet.member?(set, next - i) end)
  end

  def solve(input, preamble_length) do
    input
    |> Enum.with_index
    |> Enum.slice(preamble_length..-1)
    |> Enum.find(fn {number, index} ->
      input
      |> Enum.slice((index - preamble_length)..(index - 1))
      |> follows_rule?(number)
      |> Kernel.not
    end)
    |> elem(0)
  end

  def find_weakness(seq, sum) do
    case seq
         |> Enum.with_index
         |> Enum.reduce_while(0, fn {x, index}, acc ->
           case acc + x do
             y when y < sum -> {:cont, y}
             y when y == sum -> {:halt, Enum.slice(seq, 0..(index - 1))}
             y when y > sum -> {:halt, nil}
           end
         end) do
      nil -> find_weakness(Enum.slice(seq, 1..-1), sum)
      subseq -> Enum.min(subseq) + Enum.max(subseq)
    end
  end

  def solve_two(input, preamble_length) do
    find_weakness(input, solve(input, preamble_length))
  end
end

File.read!("inputs/encoding_error")
|> String.split("\n", trim: true)
|> Enum.map(&String.to_integer/1)
|> EncodingError.solve_two(5)
|> IO.inspect
