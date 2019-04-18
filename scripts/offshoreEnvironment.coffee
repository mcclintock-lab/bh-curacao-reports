ReportTab = require 'reportTab'
templates = require '../templates/templates.js'

_partials = require '../node_modules/seasketch-reporting-api/templates/templates.js'
partials = []
for key, val of _partials
  partials[key.replace('node_modules/seasketch-reporting-api/', '')] = val


d3 = window.d3

class OffshoreEnvironmentTab extends ReportTab
  name: 'Environment'
  className: 'offshoreEnvironment'
  template: templates.offshoreEnvironment
  dependencies:[ 
    'OffshoreHabitatToolbox'
  ]

  render: () ->
    offshore_habitats = @recordSet('OffshoreHabitatToolbox', 'Habitats').toArray()
    @roundData offshore_habitats
    for oh in offshore_habitats
      if oh.HAB_TYPE == "Seamount Peak"
        if parseFloat(oh.AREA_SQKM) > 0
          oh.AREA_SQKM = "Included"
          oh.PERC = "Included"
        else
          oh.AREA_SQKM = "Not Included"
          oh.PERC = "Not Included"
      
    offshore_habitats = _.sortBy offshore_habitats, (d) ->  d.HAB_TYPE == "Seamount Peak" ? 1 : d.HAB_TYPE

    isCollection = @model.isCollection()   
    d3IsPresent = window.d3 ? true  : false


    # setup context object with data and render the template from it
    context =
      sketch: @model.forTemplate()
      sketchClass: @sketchClass.forTemplate()
      attributes: @model.getAttributes()
      admin: @project.isAdmin window.user
      isCollection: isCollection

      offshore_habitats: offshore_habitats


    @$el.html @template.render(context, templates)
    @enableLayerTogglers()


  roundData: (data) =>
    for d in data
      if d.AREA_SQKM < 0.1 and d.AREA_SQKM > 0.00001
        d.AREA_SQKM = "< 0.1 "
      else
        d.AREA_SQKM = parseFloat(d.AREA_SQKM).toFixed(1)

module.exports = OffshoreEnvironmentTab