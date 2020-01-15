defmodule LoyaltyWeb.DataAcquisitionController do
  use LoyaltyWeb, :controller
  require Logger
  require Loyalty.DataParser

  def dispatch(conn, _params) do
    %{"url" => url} = conn.query_params
    try do
      case ExternalApi.dispatch!(url) do
        {:ok, result} ->
          {:ok,v} = Loyalty.DataParser.import_data(result.body)
          conn
          |> put_resp_header("content-type", "application/json; charset=utf-8")
          |> send_resp(200, v)

        error ->
          Logger.error("Unknown error while trying to disptach: #{inspect(error)}")
          send_resp(conn, 503, "")
      end
    rescue
      e in [ExternalService.RetriesExhaustedError, ExternalService.FuseBlownError] ->
        Logger.error(Exception.format(:error, e))
        send_resp(conn, 503, "")
    end
  end
 
end
