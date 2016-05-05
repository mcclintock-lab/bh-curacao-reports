OverviewTab = require './overivew.coffee'

window.app.registerReport (report) ->
  report.tabs [OverviewTab]
  # path must be relative to dist/
  report.stylesheets ['./report.css']
