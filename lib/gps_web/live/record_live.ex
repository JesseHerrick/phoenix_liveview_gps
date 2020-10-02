defmodule GpsWeb.RecordLive do
  use GpsWeb, :live_view

  @impl true
  def render(assigns) do
    ~L"""
    <div phx-hook="InitGps">
      <%= @longitude %>, <%= @latitude %>
    </div>

    """
  end

  @impl true
  @spec mount(map(), map(), Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:longitude, "Nothing")
      |> assign(:latitude, "Nothing")
    }
  end

  @impl true
  def handle_event("location_update", %{"longitude" => longitude, "latitude" => latitude}, socket) do
    {:noreply, assign(socket, longitude: longitude, latitude: latitude)}
  end
end
