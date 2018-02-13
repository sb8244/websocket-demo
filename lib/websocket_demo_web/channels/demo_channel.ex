defmodule WebsocketDemoWeb.DemoChannel do
  require Logger
  use Phoenix.Channel

  intercept ["debounce_ping"]

  def join("demo:" <> _id, _params, socket) do
    timer_ref = Process.send(self(), :tick, [])

    socket =
      socket
      |> assign(:current_tick, 0)
      |> assign(:tick_timer, timer_ref)
      |> assign(:debounce_ping_debounce_state, :idle)

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

  # We can async handle messages to this process and push websocket events down
  def handle_info(:tick, socket = %{assigns: %{current_tick: tick}}) do
    push socket, "tick", %{value: tick}
    timer_ref = Process.send_after(self(), :tick, 5000)

    new_socket =
      socket
      |> assign(:current_tick, tick + 1)
      |> assign(:tick_timer, timer_ref)

    {:noreply, new_socket}
  end

  def handle_info(:debounce_ping, socket = %{assigns: %{debounce_ping_debounce_state: :debouncing}}) do
    new_socket =
      socket
      |> assign(:debounce_ping_debounce_state, :idle)
      |> assign(:debounce_ping_debounce_timer, nil)

    {:noreply, new_socket}
  end

  def handle_info(:debounce_ping, socket = %{assigns: %{debounce_ping_debounce_state: :called}}) do
    {:noreply, handle_debounce_ping_call(socket)}
  end

  def handle_out("debounce_ping", _, socket = %{assigns: %{debounce_ping_debounce_state: :idle}}) do
    {:noreply, handle_debounce_ping_call(socket)}
  end

  def handle_out("debounce_ping", _, socket = %{assigns: %{debounce_ping_debounce_state: :debouncing}}) do
    {:noreply, assign(socket, :debounce_ping_debounce_state, :called)}
  end

  def handle_out("debounce_ping", _, socket = %{assigns: %{debounce_ping_debounce_state: :called}}) do
    {:noreply, socket}
  end

  defp handle_debounce_ping_call(socket) do
    push socket, "debounce_ping", %{}
    timer = Process.send_after(self(), :debounce_ping, 3000)

    socket
      |> assign(:debounce_ping_debounce_state, :debouncing)
      |> assign(:debounce_ping_debounce_timer, timer)
  end
end
