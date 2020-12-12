defmodule RainRisk do
  @cardinals ["N", "E", "S", "W"]

  def parse(line) do
    [_, dir, param] = Regex.run(~r/([NSEWLRF])(\d+)/, line)
    {dir, String.to_integer(param)}
  end

  def turn_starboard(degrees, fore) do
    start = Enum.find_index(@cardinals, fn x -> x == fore end)
    Enum.at(@cardinals, rem(round(degrees / 90) + start, 4))
  end

  def move({dir, param}, {lat, long, fore} = pos) do
    case dir do
      "N" -> {lat - param, long, fore}
      "S" -> {lat + param, long, fore}
      "E" -> {lat, long + param, fore}
      "W" -> {lat, long - param, fore}
      "L" -> {lat, long, turn_starboard(-param, fore)}
      "R" -> {lat, long, turn_starboard(param, fore)}
      "F" -> move({fore, param}, pos)
    end
  end

  def solve(lines) do
    {lat, long, _} = Enum.reduce(lines, {0, 0, "E"}, &move/2)
    abs(lat) + abs(long)
  end
end

File.read!("inputs/rain_risk")
|> String.split("\n", trim: true)
|> Enum.map(&RainRisk.parse/1)
|> RainRisk.solve()
|> IO.puts()
