                                                                    
                                                                     
                                             
###
CSE 8990 Data Visualization
Final Project Daniel Simpkins and Nate Phillips
  Based on a Project by Peter Curtis
###

h = 50 #The height of the full alert
w = 400 #The width of the full alert
margin = 15 #The margin for each of the elements within the full alert

toggle = 0 #This swaps between the thin view and the normal view

agewidth = 50 #The width of the age display
sliderwidth = 3 #The thickness of the slider
slidermargin = 5 #The margin between the slider and the top/bottom
ipmargin = 7 #The margin between the sender/destination IP boxes

first = 0

#This code selects the appropriate number of alerts for the page size
viewheight = 460
if window.innerHeight #Based on code from http://www.javascripter.net/faq/b$
  viewheight = window.innerHeight
count = Math.floor( viewheight / ( h + 2 * slidermargin ))


thinh = 20
thinw = 75
thinmargin = 3
thinagewidth = 30
thinsliderwidth = 3
thinslidermargin = 2
thinipmargin = 3

colorMap = ['#2e99c4', '#9fc2e2', '#fdf9cd', '#fc93ba', '#d62028']

window.toggleView = ->
  toggle = -toggle + 1
  d3.selectAll('rect').remove()
  d3.selectAll('text').remove()
  draw()
  
window.scrollUp = ->
  first -= count
  if first < 0
    first = 0
  if first == 0
    $('#pageup').attr('disabled', 'disabled')
  draw()

window.scrollDown = ->
  first += count
  $('#pageup').removeAttr('disabled')
  draw()

#list = d3.select('svg')
 # .attr('width', w)
 # .attr('height', h * count)

draw = ->
  if toggle == 0
    list = d3.select('svg')
    .attr('width', w)
    .attr('height', h * count)
    viewheight = 460
    if window.innerHeight #Based on code from http://www.javascripter.net/faq/b$
      viewheight = window.innerHeight
    count = Math.floor( viewheight / ( h + 2 * slidermargin )) - 1
    d3.json('query_alerts.php?first=' + first + '&count=' + count, (data) ->
      data = data.items

      b = list.selectAll('.background')
        .data(data, (d) -> d.alert_id)
      b.enter().append('rect')
        .attr('class', 'background')
        .attr('x', 0)
        .attr('y', (d, i) -> i * h)
        .attr('width', w)
        .attr('height', h)
      b.exit().remove()
      b.on('click', (d) ->
        window.location = 'alertdetail.php?alert_id=' + d.alert_id
      )

      a = list.selectAll('.ageleft')
        .data(data, (d) -> d.alert_id)
      a.enter().append('rect')
        .attr('class', 'ageleft')
        .attr('x', margin)
        .attr('y', (d, i) -> i * h + margin)
        .attr('width', (d) -> d.age * agewidth)
        .attr('height', h - margin * 2)
      a.exit().remove()

      a = list.selectAll('.ageright')
        .data(data, (d) -> d.alert_id)
      a.enter().append('rect')
        .attr('class', 'ageright')
        .attr('x', (d) -> margin + d.age * agewidth)
        .attr('y', (d, i) -> i * h + margin)
        .attr('width', (d) -> (1 - d.age) * agewidth)
        .attr('height', h - margin * 2)
        .style('fill', (d) ->
          d3.interpolateRgb('black', '#eee')(d.age).toString())
      a.exit().remove()

      s = list.selectAll('.slider')
        .data(data, (d) -> d.alert_id)
      s.enter().append('rect')
        .attr('class', 'slider')
        .attr('x', (d) -> margin + d.age * agewidth - sliderwidth / 2.0)
        .attr('y', (d, i) -> i * h + margin - slidermargin)
        .attr('width', sliderwidth)
        .attr('height', h - margin * 2 + slidermargin * 2)
      s.exit().remove()

      $('.slider').tipsy(
        gravity: 'n'
        title: ->
          d = @__data__
          d.date_time
      )

      s = list.selectAll('.source')
        .data(data, (d) -> d.alert_id)
      s.enter().append('rect')
        .attr('class', 'source')
        .attr('x', margin * 3 + agewidth)
        .attr('y', (d, i) -> h * i + margin)
        .attr('width', h - margin * 2)
        .attr('height', h - margin * 2)
        .style('fill', (d) -> colorMap[d.src_ip_type])
      s.exit().remove()
      s.on('mouseover', (d) ->
        window.highlightSource(d.src_ip)
      )
      s.on('mouseout', ->
        $('.source').css('stroke', 'black').css('stroke-width', 1)
      )

      $('.source').tipsy(
        gravity: 'n'
        title: ->
          d = @__data__
          str = d.src_ip
          if d.src_port != 0
            str += ':' + d.src_port
          str += ' (' + d.src_ip_class + ')'
      )

      d = list.selectAll('.destination')
        .data(data, (d) -> d.alert_id)
      d.enter().append('rect')
        .attr('class', 'destination')
        .attr('x', margin + agewidth + h + ipmargin)
        .attr('y', (d, i) -> h * i + margin)
        .attr('width', h - margin * 2)
        .attr('height', h - margin * 2)
        .style('fill', (d) -> colorMap[d.dst_ip_type])
      d.exit().remove()
      d.on('mouseover', (d) ->
        window.highlightDestination(d.dst_ip)
      )
      d.on('mouseout', ->
        $('.destination').css('stroke', 'black').css('stroke-width', 1)
      )


      $('.destination').tipsy(
        gravity: 'n'
        title: ->
          d = @__data__
          str = d.dst_ip
          if d.dst_port != 0
            str += ':' + d.dst_port
          str += ' (' + d.dst_ip_class + ')'
      )

      d = list.selectAll('.details')
        .data(data, (d) -> d.alert_id)
      d.enter().append('text')
        .attr('class', 'details')
        .attr('x', margin + agewidth + h * 2 + ipmargin)
        .attr('y', (d, i) -> h * (i + 0.5) + 8)
        .attr('width', 300)
        .attr('dy', -3)
        .text((d) -> d.details)
      d.exit().remove()
    )
    d3.json("query_histogram", (json) ->
      data = json.items
      barCount = data.length
      totalHeight = height * count
      barHeight = totalHeight / barCount
      barLength = 200

      list.selectAll('')
    )
  else
    list = d3.select('svg')
    .attr('width', thinw)
    .attr('height', thinh * count)
    viewheight = 460
    if window.innerHeight #Based on code from http://www.javascripter.net/faq/b$
      viewheight = window.innerHeight
    count = Math.floor( viewheight / ( thinh + 2 * thinslidermargin )) - 1
    d3.json('query_alerts.php?first=' + first + '&count=' + count, (data) ->
      data = data.items

      b = list.selectAll('.background') #This controls the blue background
        .data(data, (d) -> d.alert_id)
      b.enter().append('rect')
        .attr('class', 'background')
        .attr('x', 0)
        .attr('y', (d, i) -> i * thinh)
        .attr('width', thinw)
        .attr('height', thinh)
      b.exit().remove()
      b.on('click', (d) ->
        window.location = 'alertdetail.php?alert_id=' + d.alert_id
      )

      a = list.selectAll('.ageleft')
        .data(data, (d) -> d.alert_id)
      a.enter().append('rect')
        .attr('class', 'ageleft')
        .attr('x', thinmargin)
        .attr('y', (d, i) -> i * thinh + thinmargin)
        .attr('width', (d) -> d.age * thinagewidth)
        .attr('height', thinh - thinmargin * 2)
      a.exit().remove()

      a = list.selectAll('.ageright')
        .data(data, (d) -> d.alert_id)
      a.enter().append('rect')
        .attr('class', 'ageright')
        .attr('x', (d) -> thinmargin + d.age * thinagewidth)
        .attr('y', (d, i) -> i * thinh + thinmargin)
        .attr('width', (d) -> (1 - d.age) * thinagewidth)
        .attr('height', thinh - thinmargin * 2)
        .style('fill', (d) ->
          d3.interpolateRgb('black', '#eee')(d.age).toString())
      a.exit().remove()

      s = list.selectAll('.slider')
        .data(data, (d) -> d.alert_id)
      s.enter().append('rect')
        .attr('class', 'slider')
        .attr('x', (d) -> thinmargin + d.age * thinagewidth - thinsliderwidth / 2.0)
        .attr('y', (d, i) -> i * thinh + thinmargin - thinslidermargin)
        .attr('width', thinsliderwidth)
        .attr('height', thinh - thinmargin * 2 + thinslidermargin * 2)
      s.exit().remove()

      $('.slider').tipsy(
        gravity: 'n'
        title: ->
          d = @__data__
          d.date_time
      )

      s = list.selectAll('.source') #This controls the source ip rectangle
        .data(data, (d) -> d.alert_id)
      s.enter().append('rect')
        .attr('class', 'source')
        .attr('x', thinmargin * 3 + thinagewidth)
        .attr('y', (d, i) -> thinh * i + thinmargin)
        .attr('width', thinh - thinmargin * 2)
        .attr('height', thinh - thinmargin * 2)
        .style('fill', (d) -> colorMap[d.src_ip_type])
      s.exit().remove()
      s.on('mouseover', (d) ->
        window.highlightSource(d.src_ip)
      )
      s.on('mouseout', ->
        $('.source').css('stroke', 'black').css('stroke-width', 1)
      )

      $('.source').tipsy(
        gravity: 'n'
        title: ->
          d = @__data__
          str = d.src_ip
          if d.src_port != 0
            str += ':' + d.src_port
          str += ' (' + d.src_ip_class + ')'
      )

      d = list.selectAll('.destination') #This controls the dest ip rectangle
        .data(data, (d) -> d.alert_id)
      d.enter().append('rect')
        .attr('class', 'destination')
        .attr('x', thinmargin + thinagewidth + thinh + thinipmargin)
        .attr('y', (d, i) -> thinh * i + thinmargin)
        .attr('width', thinh - thinmargin * 2)
        .attr('height', thinh - thinmargin * 2)
        .style('fill', (d) -> colorMap[d.dst_ip_type])
      d.exit().remove()
      d.on('mouseover', (d) ->
        window.highlightDestination(d.dst_ip)
      )
      d.on('mouseout', ->
        $('.destination').css('stroke', 'black').css('stroke-width', 1)
      )


      $('.destination').tipsy(
        gravity: 'n'
        title: ->
          d = @__data__
          str = d.dst_ip
          if d.dst_port != 0
            str += ':' + d.dst_port
          str += ' (' + d.dst_ip_class + ')'
      )

      d = list.selectAll('.details')
        .data(data, (d) -> d.alert_id)
      d.exit().remove()
    )
    d3.json("query_histogram", (json) ->
      data = json.items
      barCount = data.length
      totalHeight = height * count
      barHeight = totalHeight / barCount
      barLength = 200

      list.selectAll('')
    )


window.highlightSource = (ip) ->
  $('.source').css('stroke', ->
    d = @__data__
    if d.src_ip == ip
      return 'red'
    else
      return 'black'
  )
  $('.source').css('stroke-width', ->
    d = @__data__
    if d.src_ip == ip
      return 3
    else
      return 1
  )

window.highlightDestination = (ip) ->
  $('.destination').css('stroke', ->
    d = @__data__
    if d.dst_ip == ip
      return 'red'
    else
      return 'black'
  )
  $('.destination').css('stroke-width', ->
    d = @__data__
    if d.dst_ip == ip
      return 3
    else
      return 1
  )

draw()

