OffshoreOverviewTab = require './offshoreOverview.coffee'
OffshoreEnvironmentTab = require './offshoreEnvironment.coffee'

window.app.registerReport (report) ->
  report.tabs [OffshoreOverviewTab, OffshoreEnvironmentTab]


window.app.registerReport (report) ->
  # path must be relative to dist/
  report.stylesheets ['./report.css']


