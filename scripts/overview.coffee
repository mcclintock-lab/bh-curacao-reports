ReportTab = require 'reportTab'
templates = require '../templates/templates.js'

_partials = require '../node_modules/seasketch-reporting-api/templates/templates.js'
partials = []
for key, val of _partials
  partials[key.replace('node_modules/seasketch-reporting-api/', '')] = val


d3 = window.d3

class OverviewTab extends ReportTab
  name: 'Overview'
  className: 'overview'
  template: templates.overview
  dependencies:[ 
    'SizeToolbox'
    'DiveAndFishingValue'
    'CoastalZoneSize'
  ]
  render: () ->

    # create random data for visualization
    size = @recordSet('SizeToolbox', 'Size').toArray()[0]
    size = Number.parseFloat(size.SIZE_SQKM).toFixed(1)

    min_dim = @recordSet('SizeToolbox', 'MinDimension').toArray()[0]
    
    min_dim_name = min_dim.NAME
    min_dim_size = Number.parseFloat(min_dim.MIN_DIM).toFixed(1)
    
    isCollection = @model.isCollection()

    dfv = @recordSet('DiveAndFishingValue', 'FishingValue').toArray()[0]
    ddv = @recordSet('DiveAndFishingValue', 'DiveValue').toArray()[0]
    
    if dfv
      if dfv.PERCENT < 0.01
        displaced_fishing_value = "< 0.01"
      else
        displaced_fishing_value = parseFloat(dfv.PERCENT).toFixed(2)
    else
      displaced_fishing_value = "unknown"

    if ddv
      if ddv.PERCENT < 0.01
        displaced_dive_value = "< 0.01"
      else
        displaced_dive_value = parseFloat(ddv.PERCENT).toFixed(2)
    else
      displaced_dive_value = "unknown"

    zone_sizes = @recordSet('CoastalZoneSize', 'ZoneSize').toArray()
    

    zone_tot = @getZoneTotal(zone_sizes)
    meets_zone_thresh = (zone_tot > 30.0)
    waters_sizes = @getWatersSizes(zone_sizes, zone_tot, meets_zone_thresh)
    zone_sizes = @cleanupDataAndSetThresholds(zone_sizes)

    zone_data = _.sortBy zone_sizes, (row) -> row.NAME
    waters_data = _.sortBy waters_sizes, (row) -> row.SORT_ORDER

    # setup context object with data and render the template from it
    context =
      sketch: @model.forTemplate()
      sketchClass: @sketchClass.forTemplate()
      attributes: @model.getAttributes()
      admin: @project.isAdmin window.user
      isCollection: isCollection
      size: size
      min_dim_name: min_dim_name
      min_dim_size: min_dim_size
      displaced_fishing_value: displaced_fishing_value
      displaced_dive_value: displaced_dive_value
      zone_sizes: zone_data
      waters_data: waters_data
    
    @$el.html @template.render(context, templates)
    @enableLayerTogglers()

  getWatersSizes: (zone_sizes, zone_total, meets_thresh) =>
    waters_data = []
    meets_thresh_val = "small-red-x"
    if meets_thresh
      meets_thresh_val = "small-green-check"


    zdata = {"NAME":"Coastal Zones (within 1 km)", "PERC": zone_total, "THRESH": 30, "MEETS_THRESH": meets_thresh_val, "SORT_ORDER":0}
    waters_data.push(zdata)
    nat_waters = "National Waters" 
    eez = "EEZ"
    for d in zone_sizes
      d.PERC = parseFloat(d.PERC).toFixed(1)
      if d.NAME == nat_waters|| d.NAME == eez
        if d.NAME == nat_waters
          d.SORT_ORDER = 1
          d.NAME = "National Waters (within 12 Nautical Miles)"
        else
          d.SORT_ORDER = 2

        d.THRESH = 30
        if d.PERC > d.THRESH
          d.MEETS_THRESH = "small-green-check"
        else
          d.MEETS_THRESH = "small-red-x"
        waters_data.push(d)


    return waters_data

  getZoneTotal: (data) =>
    tot = 0.0
    ztot = 82708521.5277
    for d in data
      if d.NAME != "National Waters" and d.NAME != "EEZ"
        tot+= parseFloat(d.AREA)

    perc = (parseFloat((tot/ztot)*100.0)).toFixed(1)
    return perc


  cleanupDataAndSetThresholds: (data) =>
    zone_data = []
    for d in data
      d.PERC = parseFloat(d.PERC).toFixed(1)
      if d.NAME == "National Waters (within 12 Nautical Miles)"
        d.THRESH = 30
      else if d.NAME == "EEZ"
        d.THRESH = 30
      else 
        zone_parts = d.NAME.split(" ")
        if d.NAME == "Zone 1" || d.NAME == "Zone 8"
          d.THRESH = 0
        else
          d.THRESH = 15
        zone_data.push(d)
      
      if d.THRESH == 0
        d.MEETS_THRESH = "small-gray-question"
      else if d.PERC > d.THRESH
        d.MEETS_THRESH = "small-green-check"
      else
        d.MEETS_THRESH = "small-red-x"


    return zone_data
      
module.exports = OverviewTab