defmodule Loyalty.Application do
  use Application
  require Graph

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec
   
    ExternalApi.start()

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Loyalty.Repo, []),
      # Start the endpoint when the application starts
      supervisor(LoyaltyWeb.Endpoint, []),
      %{
         id: Loyalty.DataAcquisitionGraph,
         start: {Loyalty.DataAcquisitionGraph, :start_link, [Graph.new()]}
       }
      # Start your own worker by calling: Loyalty.Worker.start_link(arg1, arg2, arg3)
      # worker(Loyalty.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Loyalty.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LoyaltyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
