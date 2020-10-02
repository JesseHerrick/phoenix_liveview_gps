defmodule Gps.LastKnownLocation do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl true
  def init(_) do
    :ets.new(:last_known_location, [:set, :public, :named_table])

    {:ok, []}
  end
end
