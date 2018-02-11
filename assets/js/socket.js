// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

const printOut = (tag) => (data) => console.log(tag, data);

// Now that you are connected, you can join channels with a topic:
const id = Math.floor(Math.random() * 50000)
let channel = socket.channel(`demo:${id}`, {})
channel.join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp)

    channel.push("ping", {})
      .receive("ok", printOut("ok"))
      .receive("error", printOut("error"))
      .receive("timeout", printOut("timeout"))

    // Known async messages, so the response can't be handled inline
    // This is contrived for the demo purposes
    channel.push("ping:1000", {})
    channel.push("ping:2000", {})
    channel.push("ping:3000", {})
  })
  .receive("error", resp => { console.log("Unable to join", resp) })

// Response from the async messages
channel.on("pong", printOut("pong async response"))

export default socket
