<!DOCTYPE html>
<html>
  <head>
    <title>Alert Details</title>
	<script type="text/javascript" src="jquery-1.7.1.min.js"></script>
	<script type="text/javascript" src="d3.v2.js"></script>
	<script type="text/javascript" src="alertdetail.js"></script>
  </head>
<?php
   if ($_GET['alert_id'])
   {
   echo '<body onload="window.setDetails(&quot;' . $_GET['alert_id'] . '&quot;)"><center>';
   }
   else
   {
   echo '<body><center>';
   }
?>
    <h1>Alert Details</h1>
	<h3 id="detail">&lt;Detail&gt;</h3>
	<p id="priority">Priority: X</p>
	<p id="datetime">Datetime: XX-XX:XX</p>
	<br>
	<h3>Source:</h3>
	<p id="source">X.X.X.X:XXX (type) (service)</p>
	<p id="source_count" style="font-size: 12px">Number of alerts: XXX</p>
	<br>
	<h3>Destination:</h3>
	<p id="destination">X.X.X.X:XXX (type) (service)</p>
	<p id="destination_count" style="font-size: 12px">Number of alerts: XXX</p>
	<br>
	<p id="extra">&lt;protocol&gt; TTL:XX ID:XX PacketSize:XX Flags:XXXXX Seq:XXXXX</p>
	<p id="optional"></p>
  </center></body>
</html>
