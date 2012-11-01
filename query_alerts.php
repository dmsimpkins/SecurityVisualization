
<?php

$con = mysql_connect('localhost','netflowuser');

if (!$con)
   {
   die('Could not connect: ' . mysql_error());
   }

mysql_select_db('netflow', $con);

if ($_GET['ip'])
  {
	$sql = 'SELECT COUNT(*) '
    . 'FROM `alerts` '
	. 'WHERE SRC_IP="' . $_GET['ip'] . '" OR DST_IP="' . $_GET['ip'] . '"';
  }
else if ($_GET['alert_id'])
  {
	$sql = 'SELECT * '
    . 'FROM `alerts` '
    . 'WHERE ALERT_ID=' . $_GET['alert_id'];
  }
else
  {
	$sql = 'SELECT * '
    . 'FROM `alerts` '
    . 'ORDER BY `alerts`.`PRIORITY` ASC, `alerts`.`AGE` DESC '
    . 'LIMIT ' . $_GET['first'] . ' , ' . $_GET['count'];
  }

$result = mysql_query($sql);

if (!$result)
   {
   die('Invalid query.');
   }

if ($_GET['ip'])
  {
	$row = mysql_fetch_array($result);
	echo $row['COUNT(*)'];
	die();
  }

echo '{';
echo '"items" : [';

$row = mysql_fetch_array($result);

while ($row)
   {
   echo '{';
   echo '"alert_id" : "' . $row['ALERT_ID'] . '",';
   echo '"date_time" : "' . $row['DATE_TIME'] . '",';
   echo '"age" : "' . $row['AGE'] . '",';
   echo '"priority" : "' . $row['PRIORITY'] . '",';
   echo '"src_ip" : "' . $row['SRC_IP'] . '",';
   echo '"src_ip_class" : "' . $row['SRC_IP_CLASS'] . '",';
   echo '"src_ip_type" : "' . $row['SRC_IP_TYPE'] . '",';
   echo '"src_port" : "' . $row['SRC_PORT'] . '",';
   echo '"dst_ip" : "' . $row['DST_IP'] . '",';
   echo '"dst_ip_class" : "' . $row['DST_IP_CLASS'] . '",';
   echo '"dst_ip_type" : "' . $row['DST_IP_TYPE'] . '",';
   echo '"dst_port" : "' . $row['DST_PORT'] . '",';
   echo '"details" : "' . $row['DETAILS'] . '",';
   echo '"protocol" : "' . $row['PROTOCOL'] . '",';
   echo '"ttl" : "' . $row['TTL'] . '",';
   echo '"id" : "' . $row['ID'] . '",';
   echo '"iplen" : "' . $row['IPLEN'] . '",';
   echo '"dgmlen" : "' . $row['DGMLEN'] . '",';
   echo '"flags" : "' . $row['FLAGS'] . '",';
   echo '"seq" : "' . $row['SEQ'] . '"';
   echo '}';

   if ($row = mysql_fetch_array($result))
	 {
	   echo ',';
	 }
   }

echo ']';
echo '}';

?>
