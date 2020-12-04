defmodule PassportProcessing do
  @passport_attrs MapSet.new([:byr, :iyr, :eyr, :hgt, :hcl, :ecl, :pid, :cid])
  @north_pole_attrs MapSet.delete(@passport_attrs, :cid)

  def line_reducer(line, %{passports: passports, curr: curr}) do
    if line == "" do
      %{passports: [curr | passports], curr: %{}}
    else
      curr =
        Regex.scan(~r/([a-z]+):(\S+)/, line, [capture: :all_but_first])
        |> Enum.map(fn [key, value] -> %{String.to_atom(key) => value} end)
        |> Enum.reduce(curr, fn pair, acc -> Map.merge(acc, pair) end)

      %{passports: passports, curr: curr}
    end
  end

  def looks_valid?(passport) do
    case MapSet.new(Map.keys(passport)) do
      @passport_attrs -> true
      @north_pole_attrs -> true
      _ -> false
    end
  end
end

File.read!("inputs/passport_processing")
|> String.split("\n")
|> Enum.reduce(%{passports: [], curr: %{}}, &PassportProcessing.line_reducer/2)
|> Map.get(:passports)
|> Enum.count(&PassportProcessing.looks_valid?/1)
|> IO.puts
