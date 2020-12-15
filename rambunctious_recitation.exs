defmodule RambunctiousRecitation do
  def take_turn(turn, %{number: last_number, ages: ages}) do
    case Map.get(ages, last_number) do
      nil ->
        %{number: 0, ages: Map.put(ages, last_number, turn)}

      age ->
        %{number: turn - age, ages: Map.put(ages, last_number, turn)}
    end
  end

  def solve(starting_numbers, last_turn) do
    ages =
      starting_numbers
      |> Enum.with_index(1)
      |> Enum.into(%{})

    %{number: last_number} =
      Enum.reduce(
        length(starting_numbers)..(last_turn - 1),
        %{number: List.last(starting_numbers), ages: ages},
        &take_turn/2
      )

    last_number
  end
end

"0,3,6"
|> String.split(",")
|> Enum.map(&String.to_integer/1)
|> RambunctiousRecitation.solve(2020)
|> IO.puts()
