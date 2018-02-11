defmodule WebsocketDemoWeb.DemoChannel do
  require Logger
  use Phoenix.Channel

  intercept ["ping"]

  def join("demo:" <> _id, _params, socket) do
    {:ok, socket}
  end

  def handle_in("ping", _params, socket) do
    {:reply, {:ok, %{response: "pong"}}, socket}
  end
end
