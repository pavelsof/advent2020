defmodule PasswordPhilosophy do
  def parse_line(line) do
    [min, max, char, pass] = Regex.run(
      ~r/(\d+)-(\d+) (\w): (\w+)/,
      line,
      [capture: :all_but_first]
    )
    [String.to_integer(min), String.to_integer(max), char, pass]
  end

  def is_valid?([min, max, char, pass]) do
    count =
      pass
      |> String.graphemes
      |> Enum.count(fn x -> x == char end)

    (min <= count) and (count <= max)
  end

  def is_valid_two?([pos_one, pos_two, char, pass]) do
    count =
      [pos_one, pos_two]
      |> Enum.map(fn pos -> String.at(pass, pos-1) == char end)
      |> Enum.count(fn bool -> bool end)

    count == 1
  end
end

File.read!("inputs/password_philosophy")
|> String.split("\n", trim: true)
|> Enum.map(&PasswordPhilosophy.parse_line/1)
|> Enum.count(&PasswordPhilosophy.is_valid_two?/1)
|> IO.puts
