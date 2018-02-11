defmodule WebsocketDemoWeb.DemoChannel do
  require Logger
  use Phoenix.Channel

  def join("demo:" <> id, _params, socket) do
    {:ok, socket}
  end
end
