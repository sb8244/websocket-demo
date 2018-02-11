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

      push(socket, "ping:300", %{})

      expected = %{delay: 300}
      refute_push "pong", ^expected, 250
      assert_push "pong", ^expected, 55 # give a few ms for the message to arrive

      leave(socket)
    end
  end
end
