                                                                    
                                                                     
                                             
###
CSE 8990 Data Visualization
Final Project Daniel Simpkins and Nate Phillips
  Based on a Project by Peter Curtis
###

h = 50 #The height of the full alert
w = 400 #The width of the full alert
margin = 15 #The margin for each of the elements within the full alert

toggle = 0 #This swaps between the thin view and the normal view
_sortBy = 'AGE'
_asc = 'ASC'

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

colorMap = ['#8dd4f0', '#9fc2e2', '#fdf9cd', '#fc93ba', '#d62028']

$('#pageup').attr('disabled', 'disabled')
$('#pageup50').attr('disabled', 'disabled')
$('#pagedown').removeAttr('disabled')
$('#pagedown50').removeAttr('disabled')

#$('#sortOrder').click ->
#  asc = $('#sortOrder').val()

#$('#sortByDrop').change ->
#  sortBy = $('#sortByDrop').val()
#colorMap = ["#2e99c4", "#9fc2e2", "#fdf9cd", "#fc93ba", "#d62028"]
priorityColors = ['#de2d26', '#fc9272', '#fee0d2']

window.setDetails = (alert_id) ->
  d3.json('query_alerts.php?alert_id=' + alert_id, (json) ->
    window.writeDetails(json.items[0])
  )

window.writeDetails = (alert) ->
  $('#detail').html(alert.details)
  $('#priority').html('Priority: ' + alert.priority)
    .css('background-color', priorityColors[alert.priority - 1])
    .css('width', '200px')
  $('#datetime').html('Datetime: ' + alert.date_time)

  source = alert.src_ip
  if alert.src_port != 0
    source += ':' + alert.src_port
  source += ' (' + alert.src_ip_class + ')'
  $('#source').html(source)
    .css('background-color', colorMap[alert.src_ip_type])
    .css('width', '400px')

  d3.text('query_alerts.php?ip=' + alert.src_ip, (count) ->
    $('#source_count').html('Number of alerts: ' + count)
  )

  destination = alert.dst_ip
  if alert.dst_port != 0
    destination += ':' + alert.dst_port
  destination += ' (' + alert.dst_ip_class + ')'
  $('#destination').html(destination)
    .css('background-color', colorMap[alert.dst_ip_type])
    .css('width', '400px')

  d3.text('query_alerts.php?ip=' + alert.dst_ip, (count) ->
    $('#destination_count').html('Number of alerts: ' + count)
  )

  extra = alert.protocol
  extra += ' TTL:' + alert.ttl
  extra += ' ID:' + alert.id
  extra += ' PacketSize:' + alert.dgmlen
  $('#extra').html(extra)

  optional = ''
  if alert.protocol == 'TCP'
    optional += ' Flags:' + alert.flags
    optional += ' Seq:' + alert.seq
    $('#optional').html(optional)

window.sort = ->
  _asc = $("input:radio[name='sortOrder']:checked").val()
  _sortBy = $("input:radio[name='sortByDrop']:checked").val()
  draw()

window.toggleView = ->
  toggle = -toggle + 1
  d3.selectAll('rect').remove()
  d3.selectAll('text').remove()
  draw()
  
window.scrollUp50 = ->
  first -= count * 50
  $('#pagedown').removeAttr('disabled')
  $('#pagedown50').removeAttr('disabled')
  if first < 0
    first = 0
  if first == 0
    $('#pageup').attr('disabled', 'disabled')
    $('#pageup50').attr('disabled', 'disabled')
  draw()

window.scrollUp = ->
  first -= count
  $('#pagedown').removeAttr('disabled')
  $('#pagedown50').removeAttr('disabled')
  if first < 0
    first = 0
  if first == 0
    $('#pageup').attr('disabled', 'disabled')
    $('#pageup50').attr('disabled', 'disabled')
  draw()

window.scrollDown = ->
  first += count
  $('#pageup').removeAttr('disabled')
  $('#pageup50').removeAttr('disabled')
  if first > 25743 - count
    first = 25743 - count
  if first == 25743 - count
    $('#pagedown').attr('disabled', 'disabled')
    $('#pagedown50').attr('disabled', 'disabled')  
  draw()

window.scrollDown50 = ->
  first += count * 50
  $('#pageup').removeAttr('disabled')
  $('#pageup50').removeAttr('disabled')
  if first > 25743 - count
    first = 25743 - count
  if first == 25743 - count
    $('#pagedown').attr('disabled', 'disabled')
    $('#pagedown50').attr('disabled', 'disabled')  
  draw()

#list = d3.select('svg')
 # .attr('width', w)
 # .attr('height', h * count)

draw = ->
  if toggle == 0
    viewheight = 460
    if window.innerHeight #Based on code from http://www.javascripter.net/faq/b$
      viewheight = window.innerHeight
    count = Math.floor( viewheight / ( h + 2 * slidermargin )) - 1
    list = d3.select('svg')
    .attr('width', w)
    .attr('height', h * count)
    d3.json('query_alerts.php?first=' + first + '&count=' + count + '&asc=' + _asc + '&sortBy=' + _sortBy , (data) ->
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
      b.on('mouseover', (d) ->
        #window.location = 'alertdetail.php?alert_id=' + d.alert_id
        window.setDetails(d.alert_id)
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
    #d3.json("histogram.json", (json) ->
    #  data = json.items
    #  barCount = data.length
    #  totalHeight = height * count
    #  barHeight = totalHeight / barCount
    #  barLength = 200

    #  list.selectAll('')
    #)
  else
    viewheight = 460
    if window.innerHeight #Based on code from http://www.javascripter.net/faq/b$
      viewheight = window.innerHeight
    count = Math.floor( viewheight / ( thinh + 2 * thinslidermargin )) - 1
    list = d3.select('svg')
    .attr('width', thinw)
    .attr('height', thinh * count)
    d3.json('query_alerts.php?first=' + first + '&count=' + count + '&asc='+_asc + '&sortBy=' + _sortBy , (data) ->
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
      b.on('mouseover', (d) ->
        #window.location = 'alertdetail.php?alert_id=' + d.alert_id
        window.setDetails(d.alert_id)
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
    #d3.json("histogram.json", (json) ->
    #  data = json.items
    #  barCount = data.length
    #  totalHeight = height * count
    #  barHeight = totalHeight / barCount
    #  barLength = 200

    #  list.selectAll('')
    #)


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
