defmodule GpsWeb.MapLive.Show do
  use GpsWeb, :live_view
  alias Phoenix.Socket.Broadcast

  @impl true
  def render(assigns) do
    ~L"""
    <%= @id %>

    <div phx-hook="Map" id="map" phx-update="ignore">
    </div>

    <p><%= @timestamp %>: <%= @longitude %>, <%= @latitude %></p>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    Phoenix.PubSub.subscribe(Gps.PubSub, "map:" <> id)
    {timestamp, longitude, latitude} = case :ets.lookup(:last_known_location, "map:" <> id) do
      [{_, timestamp, longitude, latitude}] ->
        {timestamp, longitude, latitude}
      _ ->
        {"None", "Longitude", "Latitude"}
    end

    {:ok,
      socket
      |> assign(:id, id)
      |> assign(:timestamp, timestamp)
      |> assign(:longitude, longitude)
      |> assign(:latitude, latitude)
      |> push_event("position", %{timestamp: timestamp, longitude: longitude, latitude: latitude})
    }
  end

  @impl true
  def handle_info(%Broadcast{event: "location_update", payload: %{longitude: longitude, latitude: latitude, timestamp: timestamp} = coords}, socket) do
    {:noreply,
      socket
      |> assign(:longitude, longitude)
      |> assign(:latitude, latitude)
      |> assign(:timestamp, timestamp)
      |> push_event("position", coords)
    }
  end
end
