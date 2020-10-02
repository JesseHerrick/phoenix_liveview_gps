// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"
import mapboxgl from "mapbox-gl"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {}
Hooks.InitGps = {
  mounted() {
    // navigator.geolocation.watchPosition((pos) => {
    // window.setInterval(() => {
      // navigator.geolocation.getCurrentPosition(
      navigator.geolocation.watchPosition(
        (pos) => {
          this.pushEvent("location_update", {latitude: pos.coords.latitude, longitude: pos.coords.longitude, timestamp: pos.timestamp})
        },
        (err) => console.log(err),
        { maximumAge: 0, enableHighAccuracy: true }
      )
    // }, 1000)
  }
}

Hooks.Map = {
  mounted() {
    mapboxgl.accessToken = 'pk.eyJ1IjoiamVzc2VoZXJyaWNrIiwiYSI6ImNqeWFibXRpMTBkZTIza3MzMWgwdDVrdWIifQ.SYqKlVP0OngpIGSphYyTNg';
    var map = new mapboxgl.Map({
      container: "map",
      style: 'mapbox://styles/mapbox/streets-v11',
      zoom: 14
    });

    map.on("load", () => {
      map.addSource("location", {
        "type": "geojson",
        "data": {
          "type": "Point",
          "coordinates": [39, -83]
        }
      })

      map.addLayer({
        'id': 'location',
        'type': 'circle',
        'source': 'location',
        'paint': {
          'circle-radius': 5,
          'circle-color': '#007cbf'
        }
      })
    })

    this.handleEvent("position", (coords) => {
      let coordData = {
        "type": "Point",
        "coordinates": [coords.longitude, coords.latitude]
      }

      map.getSource("location").setData(coordData)

      map.flyTo({
        center: [
          coords.longitude,
          coords.latitude
        ],
        zoom: 18
      })
      map.addLayer({
        id: "me",
        type: "symbol",
      })
    })
  }
}

let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

