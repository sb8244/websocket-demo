defmodule WebsocketDemoWeb.DemoChannelTest do
  use WebsocketDemoWeb.ChannelCase, async: true

  alias WebsocketDemoWeb.DemoChannel

  describe "join demo:id" do
    test "any socket can join the channel" do
      {:ok, _, socket} =
        socket(nil, %{})
        |> subscribe_and_join(DemoChannel, "demo:1")

      leave(socket)
    end

    test "a tick is immediately invoked" do
      {:ok, _, _socket} =
        socket(nil, %{})
        |> subscribe_and_join(DemoChannel, "demo:1")

      expected = %{value: 0}
      assert_push("tick", ^expected)
    end
  end

  describe "handle_info :tick" do
    test "another tick is invoked for 5s from now" do
      {:ok, _, socket} =
        socket(nil, %{})
        |> subscribe_and_join(DemoChannel, "demo:1")

      assert :sys.get_state(socket.channel_pid).assigns.current_tick == 1
      Process.send(socket.channel_pid, :tick, [])
      assert :sys.get_state(socket.channel_pid).assigns.current_tick == 2
      assert_in_delta Process.read_timer(socket.assigns.tick_timer), 5000, 10
    end
  end

  describe "handle_in ping" do
    test "a pong response is returned" do
      {:ok, _, socket} =
        socket(nil, %{})
        |> subscribe_and_join(DemoChannel, "demo:1")

      ref = push(socket, "ping", %{})
      assert_reply(ref, :ok, %{response: "pong"}, 1000)

      leave(socket)
    end
  end

  describe "handle_in ping:ms" do
    test "a pong response is returned after the ms time" do
      {:ok, _, socket} =
        socket(nil, %{})
        |> subscribe_and_join(DemoChannel, "demo:1")

      ref = push(socket, "ping:300", %{})

      expected = %{delay: 300, response: "pong"}

      # Give a few ms between when we expect it to receive, to account for async
      refute_reply(ref, :ok, ^expected, 299)
      assert_reply(ref, :ok, ^expected, 10)

      leave(socket)
    end
  end

  describe "handle_out debounce_ping" do
    test "state=idle, the socket receives an immediate push" do
      {:ok, _, socket} =
        socket(nil, %{})
        |> subscribe_and_join(DemoChannel, "demo:1")

      broadcast_from! socket, "debounce_ping", %{}
      assert_push "debounce_ping", %{}
    end

    test "state=idle, the timer is setup for 3s from now, and sets the next state" do
      {:ok, _, socket} =
        socket(nil, %{})
        |> subscribe_and_join(DemoChannel, "demo:1")

      broadcast_from! socket, "debounce_ping", %{}
      assert_push "debounce_ping", %{}

      state = :sys.get_state(socket.channel_pid).assigns
      assert_in_delta Process.read_timer(state.debounce_ping_debounce_timer), 3000, 10
      assert state.debounce_ping_debounce_state == :debouncing
    end

    test "state=debouncing, the state is set to called" do
      {:ok, _, socket} =
        socket(nil, %{})
        |> subscribe_and_join(DemoChannel, "demo:1")

      broadcast_from! socket, "debounce_ping", %{}
      assert_push "debounce_ping", %{}
      broadcast_from! socket, "debounce_ping", %{}

      state = :sys.get_state(socket.channel_pid).assigns
      assert_in_delta Process.read_timer(state.debounce_ping_debounce_timer), 3000, 10
      assert state.debounce_ping_debounce_state == :called
    end

    test "state=called, the state is not changed" do
      {:ok, _, socket} =
        socket(nil, %{})
        |> subscribe_and_join(DemoChannel, "demo:1")

      broadcast_from! socket, "debounce_ping", %{}
      assert_push "debounce_ping", %{}
      broadcast_from! socket, "debounce_ping", %{}
      broadcast_from! socket, "debounce_ping", %{}

      state = :sys.get_state(socket.channel_pid).assigns
      assert_in_delta Process.read_timer(state.debounce_ping_debounce_timer), 3000, 10
      assert state.debounce_ping_debounce_state == :called
    end
  end

  describe "handle_info :debounce_ping" do
    test "from state=debouncing, sets the state to idle without a push" do
      {:ok, _, socket} =
        socket(nil, %{})
        |> subscribe_and_join(DemoChannel, "demo:1")

      broadcast_from! socket, "debounce_ping", %{}
      assert_push "debounce_ping", %{}

      send socket.channel_pid, :debounce_ping

      state = :sys.get_state(socket.channel_pid).assigns
      assert state.debounce_ping_debounce_timer == nil
      assert state.debounce_ping_debounce_state == :idle
    end

    test "from state=called, sets the state to debouncing with a push" do
      {:ok, _, socket} =
        socket(nil, %{})
        |> subscribe_and_join(DemoChannel, "demo:1")

      broadcast_from! socket, "debounce_ping", %{}
      assert_push "debounce_ping", %{}
      broadcast_from! socket, "debounce_ping", %{}

      state = :sys.get_state(socket.channel_pid).assigns
      assert state.debounce_ping_debounce_state == :called

      send socket.channel_pid, :debounce_ping
      assert_push "debounce_ping", %{}

      state = :sys.get_state(socket.channel_pid).assigns
      assert_in_delta Process.read_timer(state.debounce_ping_debounce_timer), 3000, 10
      assert state.debounce_ping_debounce_state == :debouncing
    end
  end
end
