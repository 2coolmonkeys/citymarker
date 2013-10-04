<?php
/* this script communicates with external apps.
apps needs a login to add / update data in the citySDK
*/
include "citysdkfunctions.php";

//create citysdk proxy
$citySDKProxy = new CitySDKProxy();

//replace with your own layername

$layer = "2cm.dev.meldapp";

$layer = $_POST["layer"];
$strnode = $_POST["node"];
$y = $_POST["y"];
$x = $_POST["x"];


$data = json_decode($strnode);
$node = $citySDKProxy->createNode($y, $x, time(), $data);

$nodes = array();
array_push($nodes, $node);
	
if (!$citySDKProxy->startSession()){
	echo "could not start session.";
}

$request =$citySDKProxy->createRequest($nodes);
$citySDKProxy->uploadNodes($layer, $request);

$result = json_decode($citySDKProxy->message);
var_dump($result);
$citySDKProxy->destroySession();

?>
