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

      ref = push(socket, "ping:300", %{})

      expected = %{delay: 300, response: "pong"}

      # Give a few ms between when we expect it to receive, to account for async
      refute_reply(ref, :ok, ^expected, 299)
      assert_reply(ref, :ok, ^expected, 10)

      leave(socket)
    end
  end
end
