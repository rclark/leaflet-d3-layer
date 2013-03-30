# leaflet-d3-layer
utilizes [Mike Bostock's excellent instructions](http://bost.ocks.org/mike/leaflet/) to use D3 to render GeoJSON features on a Leaflet Map

logic is wrapped into an object that extends Leaflet's own GeoJSON layer, so its easy to add to a map using Leaflet's usual pattern:

    var d3Layer = new L.GeoJSON.d3({...insert geojson here...});
    var map = new L.Map("map").addLayer(d3Layer);
    
**L.GeoJSON.d3.async** allows you to create a layer that references a geojson data service, such as a WFS provided by Geoserver.

    var asyncD3Layer = new L.GeoJSON.d3.async("http:/url/for/geoserver/wfs");
    var map = new L.Map("map").addLayer(asyncD3Layer)
    
## example application
check out `/dist/index.html`

## still working...
- there is definitely a better way to handle adding / removing data from the map using (D3's update patterns)[http://bl.ocks.org/mbostock/3808218]
- is this a good way to handle unique-value symbology?
- probably "async" layer should be branded and focused for what it is: a connector to a Geoserver WFS, although it would work right now for any GeoJSON data service that accepts a bbox query paramter
