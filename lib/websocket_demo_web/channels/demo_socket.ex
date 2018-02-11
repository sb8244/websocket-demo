defmodule WebsocketDemoWeb.DemoSocket do
  use Phoenix.Socket

  ## Channels
  channel "demo:*", WebsocketDemoWeb.DemoChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket

  # Allow any socket to connect; this should be behind authentication most likely
  def connect(_params, socket) do
    {:ok, socket}
  end

  # No need to identify sockets here, as there is no authentication
  def id(_socket), do: nil
end
