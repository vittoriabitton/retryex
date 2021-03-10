defmodule RetryexTest do
  use ExUnit.Case

  require Logger

  import ExUnit.CaptureLog, only: [capture_log: 1]

  doctest Retryex

  describe "retry/2" do
    test "retries a function four times when it returns an error tuple" do
      function = fn ->
        Logger.info("Running")
        {:error, "error"}
      end

      logs = capture_log(fn -> Retryex.retry(function, retry_attempts: 4) end)

      ocurrences = text_ocurrences(logs, "Running")
      assert ocurrences == 4
    end

    test "retries a function four times when it returns an error atom" do
      function = fn ->
        Logger.info("Running")
        :error
      end

      logs = capture_log(fn -> Retryex.retry(function, retry_attempts: 4) end)

      ocurrences = text_ocurrences(logs, "Running")
      assert ocurrences == 4
    end

    test "retries a function four times when it raises an exception" do
      function = fn ->
        Logger.error("Running")
        raise RuntimeError, "boom"
      end

      logs =
        capture_log(fn ->
          assert_raise(RuntimeError, fn -> Retryex.retry(function, retry_attempts: 4) end)
        end)

      ocurrences = text_ocurrences(logs, "Running")
      assert ocurrences == 4
    end

    test "does not retry a function that runs successfully" do
      function = fn -> :ok end

      assert :ok == Retryex.retry(function, retry_attempts: 4)
    end
  end

  defp text_ocurrences(text, pattern) do
    String.split(text, pattern) |> length() |> Kernel.-(1)
  end
end
