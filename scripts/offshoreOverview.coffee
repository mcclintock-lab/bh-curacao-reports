ReportTab = require 'reportTab'
templates = require '../templates/templates.js'

_partials = require '../node_modules/seasketch-reporting-api/templates/templates.js'
partials = []
for key, val of _partials
  partials[key.replace('node_modules/seasketch-reporting-api/', '')] = val

d3 = window.d3

class OffshoreOverviewTab extends ReportTab
  name: 'Overview'
  className: 'offshoreOverview'
  template: templates.offshoreOverview

  dependencies:[ 
    'SizeToolbox'

  ]
  render: () ->
    zone_names = ["Klein Curacao","Eastpoint","Fuik Bay to Seaquarium",
                  "Seaquarium to Boka Sami","Boka Sami to Kaap Sint Marie",
                  "Kaap Sint Marie to Santa Cruz", "Santa Cruz to Westpunt","North Shore"]

    # create random data for visualization
    size = @recordSet('SizeToolbox', 'Size').toArray()[0]
    size = Number.parseFloat(size.SIZE_SQKM).toFixed(1)


    sketchClassName = @sketchClass.getAttributes.name
    
    min_dim = @recordSet('SizeToolbox', 'MinDimension').toArray()[0]
    
    min_dim_name = min_dim.NAME
    min_dim_size = Number.parseFloat(min_dim.MIN_DIM).toFixed(1)
    
    isCollection = @model.isCollection()

    # setup context object with data and render the template from it
    context =
      sketch: @model.forTemplate()
      sketchClass: @sketchClass.forTemplate()
      attributes: @model.getAttributes()
      admin: @project.isAdmin window.user

      isCollection: isCollection
      size: size

    
    @$el.html @template.render(context, templates)
    @enableLayerTogglers()

  getWatersSizes: (zone_sizes, zone_total, meets_thresh) =>
    waters_data = []
    meets_thresh_val = "small-red-x"
    if meets_thresh
      meets_thresh_val = "small-green-check"


    zdata = {"NAME":"Coastal Zones (within 200m)", "PERC": zone_total, "THRESH": 30, "MEETS_THRESH": meets_thresh_val, "SORT_ORDER":0}
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

    ztot = 29634242.242
    for d in data
      if d.NAME != "National Waters" and d.NAME != "EEZ"
        tot+= parseFloat(d.AREA)

    perc = (parseFloat((tot/ztot)*100.0)).toFixed(1)
    return perc


      
module.exports = OffshoreOverviewTab