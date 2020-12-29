defmodule MonsterMessages do
  def parse_seq(value) do
    {:seq, String.split(value)}
  end

  def parse_union(value) do
    {:union, value |> String.split("|") |> Enum.map(&parse_seq/1)}
  end

  def parse_rule(line) do
    [char, key, seq, union] =
      Regex.run(
        ~r/^(?<key>\d+): ("(?<char>.)"|(?<seq>[0-9 ]+)|(?<union>.+))$/,
        line,
        capture: :all_names
      )

    value =
      cond do
        char != "" -> {:char, char}
        seq != "" -> parse_seq(seq)
        union != "" -> parse_union(union)
      end

    {key, value}
  end

  def parse(input) do
    [rules, messages] = String.split(input, "\n\n")

    rules =
      rules
      |> String.split("\n", trim: true)
      |> Enum.into(%{}, &parse_rule/1)

    messages = messages |> String.split("\n", trim: true)

    {rules, messages}
  end

  def build_regex({:char, char}, _rules) do
    char
  end

  def build_regex({:seq, seq}, rules = %{}) do
    seq
    |> Enum.map(fn key -> rules |> Map.get(key) |> build_regex(rules) end)
    |> Enum.join()
  end

  def build_regex({:union, union}, rules = %{}) do
    value =
      union
      |> Enum.map(fn seq -> build_regex(seq, rules) end)
      |> Enum.intersperse("|")
      |> Enum.join()

    "(" <> value <> ")"
  end

  def build_regex(rules) do
    top_rule = Map.get(rules, "0")
    source = "^" <> build_regex(top_rule, rules) <> "$"
    Regex.compile!(source)
  end

  def solve({rules, messages}) do
    regex = build_regex(rules)

    messages
    |> Enum.count(fn message -> Regex.match?(regex, message) end)
  end
end

File.read!("inputs/monster_messages")
|> MonsterMessages.parse()
|> MonsterMessages.solve()
|> IO.inspect()
