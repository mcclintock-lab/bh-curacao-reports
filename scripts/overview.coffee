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
    @cleanupDataAndSetThresholds(zone_sizes)
    zone_tot = @getZoneTotal(zone_sizes)
    meets_zone_thresh = (zone_tot > 30.0)

    zone_data = _.sortBy zone_sizes, (row) -> row.SORT_SPOT

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
      zone_tot: zone_tot
      meets_zone_thresh: meets_zone_thresh
    
    @$el.html @template.render(context, templates)
    @enableLayerTogglers()

  getZoneTotal: (data) =>
    tot = 0.0
    ztot = 82708521.5277
    for d in data
      if d.NAME != "National Waters" and d.NAME != "EEZ"
        tot+= parseFloat(d.AREA)

    perc = (parseFloat((tot/ztot)*100.0)).toFixed(1)
    return perc

  cleanupDataAndSetThresholds: (data) =>
    
    for d in data
      d.PERC = parseFloat(d.PERC).toFixed(1)
      if d.NAME == "National Waters"
        d.THRESH = 30
        d.SORT__SPOT = 10
      else if d.NAME == "EEZ"
        d.THRESH = 30
        d.SORT_SPOT = 9
      else 
        zone_parts = d.NAME.split(" ")
        if d.NAME == "Zone 1" || d.NAME == "Zone 8"
          d.THRESH = 0
        else
          d.THRESH = 15
        d.SORT_SPOT = parseInt(zone_parts[1])
      
      if d.THRESH == 0
        d.MEETS_THRESH = "small-gray-question"
      else if d.PERC > d.THRESH
        d.MEETS_THRESH = "small-green-check"
      else
        d.MEETS_THRESH = "small-red-x"


      console.log("meets: ", d.MEETS_THRESH)
      
module.exports = OverviewTab