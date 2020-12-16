defmodule TicketTranslation do
  def parse_rule(line, rules) do
    match = Regex.run(~r/(\w+): (\d+)-(\d+) or (\d+)-(\d+)/, line)

    case match do
      nil ->
        rules

      [_, rule | numbers] ->
        Map.put(rules, rule, Enum.map(numbers, &String.to_integer/1))
    end
  end

  def parse_ticket(line, tickets) do
    match = Regex.run(~r/[\d,]/, line)

    case match do
      nil ->
        tickets

      _ ->
        numbers =
          line
          |> String.split(",")
          |> Enum.map(&String.to_integer/1)

        [numbers | tickets]
    end
  end

  def parse(chunks) do
    [rules, our, others] = chunks

    %{
      rules: rules |> Enum.reduce(%{}, &parse_rule/2),
      our: our |> Enum.reduce([], &parse_ticket/2) |> List.last(),
      others: others |> Enum.reduce([], &parse_ticket/2)
    }
  end

  def solve(%{rules: rules, others: tickets}) do
    allowed_numbers =
      rules
      |> Map.values()
      |> Enum.reduce(MapSet.new(), fn [m, n, p, q], acc ->
        acc
        |> MapSet.union(MapSet.new(m..n))
        |> MapSet.union(MapSet.new(p..q))
      end)

    tickets
    |> List.flatten()
    |> Enum.reject(fn x -> MapSet.member?(allowed_numbers, x) end)
    |> Enum.sum()
  end
end

File.read!("inputs/ticket_translation")
|> String.split("\n")
|> Enum.chunk_by(fn line -> line == "" end)
|> Enum.reject(fn line -> line == [""] end)
|> TicketTranslation.parse()
|> TicketTranslation.solve()
|> IO.inspect()
