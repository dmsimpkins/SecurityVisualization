// Generated by CoffeeScript 1.3.3
(function() {

  window.doAJAX = function() {
    var xmlhttp;
    xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function() {
      if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
        return document.getElementById("ajaxDiv").innerHTML = xmlhttp.responseText;
      }
    };
    xmlhttp.open("GET", "query.php?flow_id=1", true);
    return xmlhttp.send();
  };

}).call(this);