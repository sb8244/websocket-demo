defmodule WebsocketDemoWeb.DemoChannel do
  require Logger
  use Phoenix.Channel

  intercept ["ping"]

  def join("demo:" <> _id, _params, socket) do
    {:ok, socket}
  end

  # Immediate pings will reply inline
  def handle_in("ping", _params, socket) do
    {:reply, {:ok, %{response: "pong"}}, socket}
  end

  # Delayed pings will not reply inline, and instead switch to an async model
  def handle_in("ping:" <> duration_string, _params, socket) do
    duration = String.to_integer(duration_string)
    Process.send_after(self(), {"ping", duration, socket_ref(socket)}, duration)
    {:noreply, socket}
  end

  # Once we receive this command, we know that the socket needs to be pushed a message
  def handle_info({"ping", delay, ref}, socket) do
    reply ref, {:ok, %{delay: delay, response: "pong"}}
    {:noreply, socket}
  end
end
