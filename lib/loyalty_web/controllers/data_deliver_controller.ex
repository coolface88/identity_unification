defmodule LoyaltyWeb.DataDeliverController do
  use LoyaltyWeb, :controller
  require Logger
  require Loyalty.DataModel

  def deliver_by_id(conn, _params) do
    %{"ids" => ids} = conn.query_params
    {:ok,decoded} = Jason.decode(ids)
    result = cond do
              ids != nil -> Enum.map(decoded, fn x -> Loyalty.DataModel.merge_data({"hotel_id",x}) end)
              true       -> "not a valid parameter"
             end
    {:ok,encoded} = Jason.encode(result)
    conn
          |> put_resp_header("content-type", "application/json; charset=utf-8")
          |> send_resp(200, encoded)
  end
 
  def deliver_by_destination(conn, _params) do
    %{"destination" => dest} = conn.query_params
    {:ok,decoded} = Jason.decode(dest)
    result = cond do
              dest != nil -> Loyalty.DataModel.merge_data({"hotel_destination",decoded})
              true        -> "not a valid parameter"
             end 
    {:ok,encoded} = Jason.encode(result)
    conn  
          |> put_resp_header("content-type", "application/json; charset=utf-8")
          |> send_resp(200, encoded)
  end
 
end
