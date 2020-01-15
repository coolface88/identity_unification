defmodule LoyaltyWeb.Router do
  use LoyaltyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug CORSPlug, origin: "*"
    plug :accepts, ["json"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LoyaltyWeb do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
    get "/DataAcquisition", DataAcquisitionController, :dispatch
    get "/DataDeliver/hotel/ids", DataDeliverController, :deliver_by_id
    get "/DataDeliver/hotel/destination", DataDeliverController, :deliver_by_destination
  end

  # Other scopes may use custom stacks.
  # scope "/api", LoyaltyWeb do
  #   pipe_through :api
  # end
end
