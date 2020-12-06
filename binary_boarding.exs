defmodule BinaryBoarding do
  def parse_row(seat) do
    seat
    |> String.slice(0..6)
    |> String.replace("F", "0")
    |> String.replace("B", "1")
    |> String.to_integer(2)
  end

  def parse_col(seat) do
    seat
    |> String.slice(7..10)
    |> String.replace("L", "0")
    |> String.replace("R", "1")
    |> String.to_integer(2)
  end

  def calc_seat_id(seat) do
    parse_row(seat) * 8 + parse_col(seat)
  end

  def solve(seats) do
    seats |> Enum.map(&calc_seat_id/1) |> Enum.max
  end

  def solve_two(seats) do
    ids_set = Enum.into(seats, MapSet.new(), &calc_seat_id/1)
    check = fn id -> MapSet.member?(ids_set, id) end
    range = 1..Enum.at(Enum.sort(ids_set), -1)

    Enum.find(range, fn id ->
      not check.(id) and check.(id-1) and check.(id+1)
    end)
  end
end

File.read!("inputs/binary_boarding")
|> String.split("\n", trim: true)
|> BinaryBoarding.solve_two
|> IO.inspect
