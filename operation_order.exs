defmodule OperationOrder do
  def tokenize(input) do
    Regex.scan(~r/\d+|\+|\*|\(|\)/, input)
    |> Enum.map(fn [token] ->
      case token do
        "+" -> {:op, fn a, b -> a + b end}
        "*" -> {:op, fn a, b -> a * b end}
        "(" -> {:bracket, :opening}
        ")" -> {:bracket, :closing}
        val -> {:val, String.to_integer(val)}
      end
    end)
  end

  def handle_val(val, %{} = vals, %{} = ops, depth) do
    case Map.get(vals, depth) do
      nil ->
        {Map.put(vals, depth, val), ops}

      last_val ->
        {op, new_ops} = Map.pop(ops, depth)
        new_val = apply(op, [val, last_val])
        {Map.put(vals, depth, new_val), new_ops}
    end
  end

  def eval([token | rest], %{} = vals, %{} = ops, depth) do
    case token do
      {:op, new_op} ->
        eval(rest, vals, Map.put(ops, depth, new_op), depth)

      {:bracket, :opening} ->
        eval(rest, vals, ops, depth + 1)

      {:bracket, :closing} ->
        {deeper_val, vals} = Map.pop(vals, depth)
        {vals, ops} = handle_val(deeper_val, vals, ops, depth - 1)
        eval(rest, vals, ops, depth - 1)

      {:val, val} ->
        {vals, ops} = handle_val(val, vals, ops, depth)
        eval(rest, vals, ops, depth)
    end
  end

  def eval([], %{} = vals, %{} = _ops, depth = 0) do
    Map.get(vals, depth)
  end
end

File.read!("inputs/operation_order")
|> String.split("\n", trim: true)
|> Enum.map(fn line ->
  line
  |> OperationOrder.tokenize()
  |> OperationOrder.eval(%{}, %{}, 0)
end)
|> Enum.sum()
|> IO.puts()
