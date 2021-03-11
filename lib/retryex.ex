defmodule Retryex do
  @moduledoc """
  Documentation for `Retryex`.
  """

  @spec retry((() -> any), keyword) :: any
  def retry(function, opts \\ []) do
    retry_limit = Keyword.get(opts, :retry_limit, 3)

    Enum.reduce_while(1..retry_limit, 0, fn i, _acc ->
      if i == retry_limit do
        {:halt, function.()}
      else
        invoke_function_with_retry(function)
      end
    end)
  end

  defp invoke_function_with_retry(function) do
    try do
      case function.() do
        {:error, reason} -> {:cont, {:error, reason}}
        :error -> {:cont, :error}
        result -> {:halt, result}
      end
    catch
      type, reason -> {:cont, {type, reason}}
    end
  end
end
