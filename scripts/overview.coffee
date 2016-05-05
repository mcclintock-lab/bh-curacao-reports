ReportTab = require 'reportTab'
templates = require '../templates/templates.js'
d3 = window.d3

class OverviewTab extends ReportTab
  name: 'Overview'
  className: 'overview'
  template: templates.overview
  dependencies:[ 
    'SizeToolbox'
  ]
  render: () ->


    # create random data for visualization
    size = @recordSet('SizeToolbox', 'Size').toArray()[0]
    size = Number.parseFloat(size.SIZE_SQKM).toFixed(1)

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
      min_dim_name: min_dim_name
      min_dim_size: min_dim_size
    
    @$el.html @template.render(context, templates)




module.exports = OverviewTab