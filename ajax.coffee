window.doAJAX = ->
  xmlhttp = new XMLHttpRequest()
  xmlhttp.onreadystatechange = ->
    if xmlhttp.readyState == 4 and xmlhttp.status == 200
      document.getElementById("ajaxDiv").innerHTML = xmlhttp.responseText
  xmlhttp.open(
    "GET"
    "query.php?flow_id=1"
    true
  )
  xmlhttp.send()
