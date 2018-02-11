defmodule WebsocketDemoWeb.PageController do
  use WebsocketDemoWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
