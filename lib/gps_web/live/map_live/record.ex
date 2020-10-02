defmodule GpsWeb.MapLive.Record do
  use GpsWeb, :live_view

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
  def handle_event("location_update", %{"timestamp" => timestamp, "longitude" => longitude, "latitude" => latitude}, %{assigns: %{id: id}} = socket) do
    key = "map:" <> id

    formatted_coords = %{timestamp: formatted_time(timestamp), longitude: longitude, latitude: latitude}

    GpsWeb.Endpoint.broadcast_from!(self(), key, "location_update", formatted_coords)
    :ets.insert(:last_known_location, {key, formatted_time(timestamp), longitude, latitude})

    {:noreply,
      socket
      |> assign(formatted_coords)
      |> push_event("position", formatted_coords)
    }
  end

  defp formatted_time(timestamp) do
    timestamp
    |> DateTime.from_unix!(:millisecond)
    |> DateTime.shift_zone!("America/New_York")
  end
end
