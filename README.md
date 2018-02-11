# Websocket Demo

This repo is a demo of very basic websocket concepts. The demonstrated concepts are:

* Socket connection
* Reply immediately to commands
* Reply asynchronously to commands
* Handle completely out of band requests (tick once per 5s)

## Installation / Demo

To start the demo:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser. Open up
the console to view the output.

You can run `:observer.start` in the console to view the processes, such as what happens
when a websocket connects.

## Console Output

```
socket.js:28 Joined successfully {}
socket.js:20 ticked {value: 0}
socket.js:20 ok {response: "pong"}
socket.js:20 delayed {response: "pong", delay: 1000}
socket.js:20 delayed {response: "pong", delay: 2000}
socket.js:20 delayed {response: "pong", delay: 3000}
socket.js:20 ticked {value: 1}
```
