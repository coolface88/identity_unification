defmodule Loyalty.DataAcquisitionGraph do
  use GenServer
  require Logger
  require Graph

  @node_table Module.concat(__MODULE__, "node_properties")
  @edge_table Module.concat(__MODULE__, "edge_properties")

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  ## Callbacks

  @impl true
  def init(graph) do
    :ets.new(@node_table, [:named_table])
    :ets.new(@edge_table, [:named_table])
    {:ok, graph}
  end

  @impl true
  def handle_call(request, _from, g) do
    case request do
      [:add_vertex, v, l]            -> ng = Graph.add_vertex(g, v, l)
                                        {:reply, ng, ng}
      [:add_vertex_properties, v, p] -> :ets.insert(@node_table, {v,p})
                                        {:reply, :ets.lookup(@node_table, v), g}
      [:vertices]                    -> {:reply, Graph.vertices(g) , g}
      [:info]                        -> {:reply, g , g}
      [:vertex_labels, v]            -> {:reply, Graph.vertex_labels(g , v), g}
      [:look_up, v]                     -> {:reply, :ets.lookup(@node_table, v), g}
      [:add_edge, v1, v2, l]         -> ng = Graph.add_edge(g, v1, v2, label: l)
                                        {:reply, ng, ng}
      [:components]                  -> {:reply, Graph.components(g), g}
      [:out_neighbors, v]            -> {:reply, Graph.out_neighbors(g, v), g}
    end
  end

end
