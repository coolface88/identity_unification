defmodule ExternalApi do
  import HttpClient
  require Logger

  @fuse_name __MODULE__
  @fuse_options [
    # Tolerate 5 failures for every 1 second time window.
    fuse_strategy: {:standard, 5, 1_000},
    # Reset the fuse 5 seconds after it is blown.
    fuse_refresh: 5_000,
    # Limit to 100 calls per second.
    rate_limit: {100, 1_000}
  ]
  @retry_errors [
    429, # RESOURCE_EXHAUSTED
    500, # INTERNAL
    503, # UNAVAILABLE
    504, # DEADLINE_EXCEEDED
  ]
  @retry_opts %ExternalService.RetryOptions{
    # Use linear backoff. Exponential backoff is also available.
    backoff: {:linear, 100, 1},
    # Stop retrying after 5 seconds.
    expiry: 5_000,
  }

  def start do
    ExternalService.start(@fuse_name, @fuse_options)
  end
 
  def dispatch!(url) do
    Logger.info(url)
    ExternalService.call!(@fuse_name, @retry_opts, fn -> try_dispatch(url) end)
  end

  defp try_dispatch(url) do
      url
      |> get(url)
      |> case do
           {:error, reason, code} when code in @retry_errors ->
             {:retry, reason}
           result ->
             # If not a retriable error, just return the result.
             result
         end
  end

end
