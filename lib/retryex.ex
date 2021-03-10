defmodule Retryex do
  @moduledoc """
  Documentation for `Retryex`.
  """

  def retry(function, opts \\ []) do
    retry_limit = Keyword.get(opts, :retry_limit, 3)
    retry_attempts = 1

    invoke_function_with_retry(function, retry_attempts, retry_limit)
  end

  defp invoke_function_with_retry(function, retry_attempts, retry_limit) do
    if retry_limit >= retry_attempts do
      retry(function, retry_attempts, retry_limit)
    else
      function.()
    end
  end

  defp retry(function, retry_attempts, retry_limit) do
    case function.() do
      {:error, _reason} ->
        invoke_function_with_retry(function, retry_attempts + 1, retry_limit)

      :error ->
        invoke_function_with_retry(function, retry_attempts + 1, retry_limit)
    end
  catch
    _type, _reason -> invoke_function_with_retry(function, retry_attempts + 1, retry_limit)
  end
end
