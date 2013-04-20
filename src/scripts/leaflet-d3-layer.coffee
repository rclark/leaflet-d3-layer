root = @

L.GeoJSON.d3 = L.GeoJSON.extend
  initialize: (geojson, options) ->
    @geojson = geojson  # This will fail if you don't pass a FeatureCollection
    # unlike L.GeoJSON layer, this won't work unless GeoJSON is passed up-front
    
    # Make sure there's an options object
    options = options or {}
    
    # set a layerId
    options.layerId = options.layerId or "leaflet-d3-layer-#{Math.floor(Math.random()*101)}"
    options.onEachFeature = (geojson, layer) ->
      # Do stuff with each feature. Layer is a Leaflet wrapper around geojson
      # Maybe you can style individual features here based on properties?
            
    # Initiate the layer similar to the GeoJSON initilization function to utilize its perks
    L.setOptions @, options
    @._layers = {}

  updateData: (map) ->
    g = @_g
    svg = @_svg

    # Check for TopoJSON
    if @geojson.type is "Topology"
      # Convert to GeoJSON
      @geojson = root.topojson.feature @geojson, @geojson.objects.features

    # Create path elements for each feature using D3's data join (http://bost.ocks.org/mike/join/)
    #   path elements are empty, will later be initialized by adding the d attribute
    #   this seems to create a path element for every feature
    paths = g.selectAll "path"

    # Do the D3-style "Data-Join"
    join = paths.data @geojson.features, (d) ->
      # This function returns a feature's unique ID
      return d.id

    # Add path elements for any new features
    feature = join.enter().append "path"

    # Remove any features that are no longer on the map
    join.exit().remove()

    # Put in an attribute that might be used for styling
    if @options.styler?
      styler = @options.styler
      feature.attr "styler", (d) ->
        return d.properties[styler]

    # Use Leaflet to project from geographic to pixel coordinates
    project = (d3pnt) ->
      geoPnt = new L.LatLng d3pnt[1], d3pnt[0]
      pixelPnt = map.latLngToLayerPoint geoPnt
      return [ pixelPnt.x, pixelPnt.y ]

    # Create a d3.geo.path (https://github.com/mbostock/d3/wiki/Geo-Paths#wiki-path)
    #   doesn't appear to have any data bound to it at this point
    path = d3.geo.path().projection project

    # Find the bounds of the geojson collection
    bounds = d3.geo.bounds @geojson

    # Function to define the appropriate size for the svg element
    #   and plug data into the path elements
    reset = () ->
      # Setup a buffer so you don't truncate any symbols
      bufferPixels = 15

      bottomLeft = project bounds[0]
      topRight = project bounds[1]

      svg.attr "width", topRight[0] - bottomLeft[0] + 2*bufferPixels
      svg.attr "height", bottomLeft[1] - topRight[1] + 2*bufferPixels
      svg.style "margin-left", "#{bottomLeft[0] - bufferPixels}px"
      svg.style "margin-top", "#{topRight[1] - bufferPixels}px"
      g.attr "transform", "translate(#{-bottomLeft[0] + bufferPixels},#{-topRight[1] + bufferPixels})"

      # Here is where we "initialize the path data by setting the d attribute" (http://bost.ocks.org/mike/leaflet/)
      feature.attr "d", path

    # Bind that reset function to a Leaflet map event (resize svg whenever the map is zoomed)
    map.on "viewreset", reset

    # Then call it to get things started
    reset()

    # Bind the reset function to something in broader scope so it can later be unbound
    #   from the viewreset event
    @resetFunction = reset

  onAdd: (map) ->
    # From Leaflet API docs:
    # Should contain code that creates DOM elements for the overlay, adds 
    #   them to map panes where they should belong and puts listeners on 
    #   relevant map events. Called on map.addLayer(layer).
    
    # Put an SVG element into Leaflet's .leaflet-overlay-pane
    overlayPane = map.getPanes().overlayPane
    d3Selector = d3.select overlayPane
    @_svg = svg = d3Selector.append "svg"
    svg.attr "class", "leaflet-d3-layer"
    svg.attr "id", @options.layerId
    
    # Put a group element within that
    @_g = g = svg.append "g"
    g.attr "class", "leaflet-zoom-hide leaflet-d3-group"

    @updateData map
    
  onRemove: (map) ->
    # From Leaflet API docs:
    # Should contain all clean up code that removes the overlay's elements 
    #   from the DOM and removes listeners previously added in onAdd. 
    #   Called on map.removeLayer(layer).
    @_svg.remove()
    map.off "viewreset", @resetFunction        
    
L.GeoJSON.d3.async = L.GeoJSON.d3.extend
  initialize: (geojsonUrl, options) ->
    @geojsonUrl = geojsonUrl  
    options = options or {}
    
    # Give this layer a unique ID based on its url
    options.layerId = options.layerId or geojsonUrl.replace /[^A-Za-z0-9]/g, "-"
    
    # Initialize via parent function
    L.GeoJSON.d3.prototype.initialize.call @, null, options
    
  getData: (map) ->    
    # Find the map's bounding box
    mapBounds = map.getBounds().toBBoxString()
    url = "#{@geojsonUrl}&bbox=#{mapBounds}"
    
    # Request some JSON
    thisLayer = @
    d3.json url, (geojson) ->
      # Purge the DOM if we've already initialized
      #L.GeoJSON.d3.prototype.onRemove.call(thisLayer, map) if thisLayer._svg?
      
      # Use parent functions to do put points back on the map
      #thisLayer.geojson = geojson
      #L.GeoJSON.d3.prototype.onAdd.call thisLayer, map

      thisLayer.geojson = geojson
      if thisLayer._svg?
        L.GeoJSON.d3.prototype.updateData.call thisLayer, map
      else
        L.GeoJSON.d3.prototype.onAdd.call thisLayer, map

  onAdd: (map) ->
    # Setup listener to make new requests when the view changes
    thisLayer = @
    @newData = newData = (e) ->
      L.GeoJSON.d3.async.prototype.getData.call thisLayer, e.target
   
    map.on "moveend", newData
    
    # Then go ahead and getData for the first time
    @getData map
    
  onRemove: (map) ->
    L.GeoJSON.d3.prototype.onRemove.call @, map
    map.off "moveend", @newData
    