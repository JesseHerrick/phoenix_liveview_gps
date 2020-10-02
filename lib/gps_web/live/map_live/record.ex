defmodule GpsWeb.MapLive.Record do
  use GpsWeb, :live_view
  alias Phoenix.Socket.Broadcast

  @impl true
  def render(assigns) do
    ~L"""
    <div phx-hook="InitGps" id="gps">
      <%= @timestamp %>: <%= @longitude %>, <%= @latitude %>
    </div>
    <div phx-hook="Map" id="map" phx-update="ignore">
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
      socket
      |> assign(:id, id)
      |> assign(:timestamp, "None")
      |> assign(:longitude, "Nothing")
      |> assign(:latitude, "Nothing")
    }
  end

  @impl true
  def handle_event("location_update", %{"longitude" => longitude, "latitude" => latitude, "timestamp" => timestamp} = coords, %{assigns: %{id: id}} = socket) do
    GpsWeb.Endpoint.broadcast_from!(self(), "map:" <> id, "location_update", coords)
    formatted_timestamp =
    :ets.insert(:last_known_location, {"map:" <> id, timestamp, longitude, latitude})

    {:noreply,
      socket
      |> assign(longitude: longitude, latitude: latitude, timestamp: timestamp)
      |> push_event("position", coords)
    }
  end
end
