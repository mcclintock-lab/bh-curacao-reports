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
    'BiomassToolbox'
  ]
  render: () ->


    # create random data for visualization
    habitats = @recordSet('Habitat', 'Habitats').toArray()
    herb_bio = @recordSet('BiomassToolbox', 'HerbivoreBiomass').toArray()[0]
    all_herb_vals = herb_bio.ALL_VALS

    fish_bio = @recordSet('BiomassToolbox', 'FishBiomass').toArray()[0]
    #all_fish_vals = @getAllValues fish_bio

    @roundVals herb_bio
    @roundVals fish_bio

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
      herb: herb_bio
      fish: fish_bio
    
    @$el.html @template.render(context, templates)
    @enableLayerTogglers()

  getAllValues: (all_str) =>

    try
      all_fish_vals = fish_bio.ALL_VALS.split(",")
    catch e
      all_fish_vals.MEAN="Unknown"
      all_fish_vals.MIN ="Unknown"
      
      all_fish_vals.MAX = "Unknown"
  roundVals: (d) =>    
    d.MEAN = parseFloat(d.MEAN).toFixed(1)
    d.MAX = parseFloat(d.MAX).toFixed(1)
    d.MIN = parseFloat(d.MIN).toFixed(1)


  roundData: (data) =>
    for d in data
      if d.AREA_SQKM < 0.1 and d.AREA_SQKM > 0.00001
        d.AREA_SQKM = "< 0.1 "
      else
        d.AREA_SQKM = parseFloat(d.AREA_SQKM).toFixed(1)
module.exports = EnvironmentTab