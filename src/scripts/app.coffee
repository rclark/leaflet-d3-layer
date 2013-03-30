
# Map setup
terrainUrl = "http://a.tiles/mapbox.com/v3/rclark.map-x9c4guq4/{z}/{x}/{y}.png"
someUrl = "http://a.tiles.mapbox.com/v3/mapbox.world-bright/{z}/{x}/{y}.png"
layer = new L.TileLayer someUrl
center = new L.LatLng 33.610044573695625, -111.50024414062501
zoom = 9

@map = new L.Map "map",
  center: center
  zoom: zoom
  layers: layer

# Get some GeoJSON
geochronUrl = "http://services.usgin.org/geoserver/ows?service=wfs&version=1.0.0&request=GetFeature&typename=azgs:azgeochron&outputformat=json"
polysUrl = "http://services.usgin.org/geoserver/ows?service=wfs&version=1.0.0&request=GetFeature&typename=ncgmp:mapunitpolys&outputformat=json"

'''
d3.json geochronUrl, (geojson) ->
  layer = new L.GeoJSON.d3 geojson
  @map.addLayer layer


layer = new L.GeoJSON.d3.async geochronUrl,
  styler: "cartoobjid"
'''
  
layer = new L.GeoJSON.d3.async polysUrl,
  styler: "mapunit"
@map.addLayer layer