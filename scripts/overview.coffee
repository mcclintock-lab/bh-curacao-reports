ReportTab = require 'reportTab'
templates = require '../templates/templates.js'
d3 = window.d3

class OverviewTab extends ReportTab
  name: 'Overview'
  className: 'overview'
  template: templates.overview
  dependencies:[ 
    'Size'
  ]
  render: () ->

    # create random data for visualization
    size = @recordSet('Size', 'Size').toArray()[0]

    min_dim = @recordSet('Size', 'MinDimension').toArray()[0]
    console.log(min_dim)
    isCollection = @model.isCollection()

    # setup context object with data and render the template from it
    context =
      sketch: @model.forTemplate()
      sketchClass: @sketchClass.forTemplate()
      attributes: @model.getAttributes()
      admin: @project.isAdmin window.user
      isCollection: isCollection
      size: size
      min_dim: min_dim
    
    @$el.html @template.render(context, templates)




module.exports = OverviewTab