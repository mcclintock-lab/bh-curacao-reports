ReportTab = require 'reportTab'
templates = require '../templates/templates.js'

_partials = require '../node_modules/seasketch-reporting-api/templates/templates.js'
partials = []
for key, val of _partials
  partials[key.replace('node_modules/seasketch-reporting-api/', '')] = val


d3 = window.d3

class EnvironmentTab extends ReportTab
  name: 'Environment'
  className: 'environment'
  template: templates.environment
  dependencies:[ 
    'Habitat'
  ]
  render: () ->


    # create random data for visualization
    habitats = @recordSet('Habitat', 'Habitats').toArray()
    
    isCollection = @model.isCollection()   
    @roundData habitats

    # setup context object with data and render the template from it
    context =
      sketch: @model.forTemplate()
      sketchClass: @sketchClass.forTemplate()
      attributes: @model.getAttributes()
      admin: @project.isAdmin window.user
      isCollection: isCollection
      habitats: habitats

    
    @$el.html @template.render(context, templates)
    @enableLayerTogglers()

  roundData: (data) =>
    for d in data
      if d.AREA_SQKM < 0.1 and d.AREA_SQKM > 0.00001
        d.AREA_SQKM = "< 0.1 "
      else
        d.AREA_SQKM = parseFloat(d.AREA_SQKM).toFixed(1)
module.exports = EnvironmentTab