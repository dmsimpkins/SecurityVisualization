<!DOCTYPE html>
<html>
  <head>
    <title>Alerts</title>
	<script type="text/javascript" src="jquery-1.7.1.min.js"></script>
	<script type="text/javascript" src="jquery.tipsy.js"></script>
	<link type="text/css" rel="stylesheet" href="tipsy.css" />
	<script type="text/javascript" src="d3.v2.js"></script>
	<link type="text/css" rel="stylesheet" href="alerts.css" />
  </head>
  <body>
    <h1>Snort Alerts</h1>
	<p>
	  <button id="pageup50" disabled="disabled" onclick="window.scrollUp50()">Page Up 50</button>
	  <button id="pageup" disabled="disabled" onclick="window.scrollUp()">Page Up</button>
	  <button id="pagedown" onclick="window.scrollDown()">Page Down</button>
	  <button id="pagedown50" onclick="window.scrollDown50()">Page Down 50</button>
	</p>
	<div id='leftFloater'>
		<div id='sortBy'>
			Sort by:
		   <form action=''>
		   	<select name = 'sortByDrop'>
		   		<option value="time">Time</option>
		   		<option value='srcip'>Src IP</option>
		   		<option value='dstip'>Dst IP</option>
		   		<option value='priority'>Priority</option>
		   	</select><br>
		   	<input type='radio' name='sortOrder' value='ascending' checked='checked'> Ascending<br>
		   	<input type='radio' name='sortOrder' value='descending'> Descending
		   </form>
		</div>
		<button id="toggleview" onclick="window.toggleView()">Toggle View</button>
	</div>
	<div>
	  <div class="sidediv"></div>
	  <svg></svg>
	  <div class="sidediv"></div>
	</div>
	<script type="text/javascript" src="alertslist.js"></script>
  </body>
</html>