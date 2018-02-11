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

  def handle_in("ping:" <> duration_string, _params, socket) do
    duration = String.to_integer(duration_string)
    Process.send_after(self(), {"ping", duration}, duration)
    {:noreply, socket}
  end

  def handle_info({"ping", delay}, socket) do
    push socket, "pong", %{delay: delay}
    {:noreply, socket}
  end
end
