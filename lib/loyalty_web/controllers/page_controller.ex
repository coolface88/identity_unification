defmodule LoyaltyWeb.PageController do
  use LoyaltyWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
