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
    all_herb_vals = @getAllValues herb_bio.ALL_VALS

    fish_bio = @recordSet('BiomassToolbox', 'FishBiomass').toArray()[0]
    all_fish_vals = @getAllValues fish_bio.ALL_VALS

    @roundVals herb_bio
    @roundVals fish_bio


    isCollection = @model.isCollection()   
    d3IsPresent = window.d3 ? true  : false
    @roundData habitats

    # setup context object with data and render the template from it
    context =
      sketch: @model.forTemplate()
      sketchClass: @sketchClass.forTemplate()
      attributes: @model.getAttributes()
      admin: @project.isAdmin window.user
      isCollection: isCollection
      habitats: habitats
      d3IsPresent: d3IsPresent
      herb: herb_bio
      fish: fish_bio
    
    @$el.html @template.render(context, templates)
    @enableLayerTogglers()

    @renderHistoValues(herb_bio.MEAN, all_herb_vals, ".herb_viz", "#47ae43")
    @renderHistoValues(fish_bio.MEAN, all_fish_vals, ".fish_viz", "steelblue")

  renderHistoValues: (mean, histo_vals, graph, color) =>
    if window.d3

      len = histo_vals.length
      max_histo_val = histo_vals[len-1]
      quantile_range = {"Q0":"very low", "Q20": "low","Q40": "mid","Q60": "high","Q80": "very high"}
      q_colors = ["#47ae43", "#6c0", "#ee0", "#eb4", "#ecbb89", "#eeaba0"]


      num_bins = 10
      bin_size = 10
      
      quantiles = []
      max_count_val = 0
      num_in_bins = Math.ceil(len/num_bins)
      incr = max_histo_val/num_bins
      

      for i in [0...num_bins]
        
        q_start = i*bin_size
        q_end = q_start+bin_size
        min = i*incr
        max = min+incr
        count=0

        #TODO: look for a more efficient way to do this
        for hv in histo_vals
          if hv >= min and hv < max
            count+=1


        max_count_val = Math.max(count, max_count_val)
        
        val = {
          start: q_start
          end: q_end
          bg: q_colors[Math.floor(i/2)]
          bin_count: count
          bin_min: min
          bin_max: max
        }
        
        quantiles.push(val)

    
      @$(graph).html('')
      el = @$(graph)[0]  

      # Histogram
      margin = 
        top: 40
        right: 20
        bottom: 40
        left: 45

      width = 400 - margin.left - margin.right
      height = 350 - margin.top - margin.bottom
      
      x = d3.scale.linear()
        .domain([0, max_histo_val])
        .range([0, width])

      y = d3.scale.linear()
        .range([height, 0])
        .domain([0, max_count_val])

      xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom")

      yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")


      svg = d3.select(@$(graph)[0]).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(#{margin.left}, #{margin.top})")

      svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0,#{height})")
        .call(xAxis)
      .append("text")
        .attr("x", width / 2)
        .attr("y", 0)
        .attr("dy", "3em")
        .style("text-anchor", "middle")
        .text("Biomass (g/m^2)")

      svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
      .append("text")
        .attr("y", -40)
        .attr("x", -80)
        .attr("transform", "rotate(-90)")
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("Number of Biomass Points")

      svg.selectAll(".bar")
          .data(quantiles)
        .enter().append("rect")
          .attr("class", "bar")
          .attr("x", (d, i) -> x(d.bin_min))
          .attr("width", (d) -> width/num_bins)
          .attr("y", (d) -> y(d.bin_count))
          .attr("height", (d) -> height - y(d.bin_count))
          .style 'fill', (d) -> color

      svg.selectAll(".score")
          .data([Math.round(mean)])
        .enter().append("text")
        .attr("class", "score")
        .attr("x", (d) -> (x((d)) - 8 )+ 'px')
        .attr("y", (d) -> (y(max_count_val) - 2) + 'px')
        .text("▼")

      svg.selectAll("scoreLine")
          .data([Math.round(mean)])
        .enter().append("line")
        .attr("class", "scoreLine")
        .attr("x1", (d) -> (x((d)) )+ 'px')
        .attr("y1", (d) -> (y(max_count_val)-2) + 'px')
        .attr("x2", (d) -> (x(d)+ 'px'))
        .attr("y2", (d) -> height + 'px')

      svg.selectAll(".scoreText")
          .data([Math.round(mean)])
        .enter().append("text")
        .attr("class", "scoreText")
        .attr("x", (d) -> (x(d) - 41 )+ 'px')
        .attr("y", (d) -> (y(max_count_val) - 22) + 'px')

        .text((d) -> "Sketch Mean: "+d)

      @$(graph).append '<div class="legends"></div>'
      
      '''
      for quantile in quantiles
        @$('.bio_viz .legends').append """
          <div class="legend"><span style="background-color:#{quantiles.bg};">&nbsp;</span>#{quantiles.range}</div>
        """
      '''
      @$(graph).append '<br style="clear:both;">'

  getAllValues: (all_str) =>

    all_vals = all_str.substring(1, all_str.length - 1)
    all_vals = all_vals.split(", ")
    sorted_vals = _.sortBy all_vals, (d) ->  parseFloat(d)
    return sorted_vals

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