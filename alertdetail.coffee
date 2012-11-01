colorMap = ["#2e99c4", "#9fc2e2", "#fdf9cd", "#fc93ba", "#d62028"]
priorityColors = ['#32CD32', '#84E184', '#C2F0C2']

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
