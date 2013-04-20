root = @
root.app = {}

# Map setup
someUrl = "http://a.tiles.mapbox.com/v3/mapbox.world-bright/{z}/{x}/{y}.png"
layer = new L.TileLayer someUrl
center = new L.LatLng 33.610044573695625, -111.50024414062501
zoom = 11

@map = new L.Map "map",
  center: center
  zoom: zoom
  layers: layer

# Get some GeoJSON
geochronUrl = "http://services.usgin.org/geoserver/ows?service=wfs&version=1.0.0&request=GetFeature&typename=azgs:azgeochron&outputformat=json"
polysUrl = "http://services.usgin.org/geoserver/ows?service=wfs&version=1.0.0&request=GetFeature&typename=ncgmp:mapunitpolys&outputformat=json"
topoUrl = "http://data.usgin.org/topojson/geoserver/arizona/azgs:mapunitpolys?format=topojson"

'''
Use the asynchronous bbox-based layer
'''
app.polys = layer = new L.GeoJSON.d3.async polysUrl,
  styler: "mapunit"
@map.addLayer layer

'''
Use the asynchronous bbox-based layer with TopoJSON
'''
app.topopolys = layer = new L.GeoJSON.d3.async topoUrl,
   styler: "mapunit"
@map.addLayer layer

'''
Use the synchronous "all at once" layer
'''
d3.json geochronUrl, (geojson) ->
  app.points = syncLayer = new L.GeoJSON.d3 geojson,
    styler: "cartoobjid"
  root.map.addLayer syncLayer
'''
please understand that layer ordering is still wonky
'''