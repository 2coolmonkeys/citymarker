<?php
/* consult http://citysdk.waag.org/api-write for details about the protocol.
*/

require_once"phpsettings.php";



class CitySDKProxy{

	private $xauth_session_key = "";
	public $message = "";
	public $status = "fail";
	public $results = nil;

	function __construct() {
		date_default_timezone_set("Europe/Amsterdam");
	}
	
	/*
	All Write API requests require authentication by means of a session key, a random string that provides temporary, secure access to the Write API. 
	See http://citysdk.waag.org/api-write
	*/
	function startSession(){
		global $endpoint,$username,$password;
		$query = http_build_query(array("e"=>$username,"p"=>$password ));
		$sesson_url = $endpoint . "/get_session?$query";
		$ch = curl_init($sesson_url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET");
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
		$response = curl_exec($ch);
		if ($this->processResponse($response)){
			$this->xauth_session_key = $this->results[0];
			return (isSet($this->xauth_session_key));
				
		}
		return false;
	}
	/*
	Session keys are valid for one minute only, but each request to the Write API will extend the validity with another minute. After one minute of inactivity, your session will time out and you will need to request a new session key to do new Write API requests.
	When done, you should release your session.
	See http://citysdk.waag.org/api-write
	
	*/
	function destroySession(){
		global $xauth_session_key, $endpoint;
		$release_session_url = $endpoint . "/release_session";
		$ch = curl_init($release_session_url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET");
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
		
		$headers = array(
				'X-Auth: ' . $this->xauth_session_key,
		);
		curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
		$response = curl_exec($ch);
		return $this->processResponse($response);
	}

	/*
	Bulk API: writing/updating multiple nodes and node data at once
	*/

	function uploadNodes($layer, $request){
		global $endpoint;
		$upload_url = $endpoint . "/nodes/" . $layer;
		
		$bodydata = json_encode($request);
		$ch = curl_init($upload_url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
		curl_setopt($ch, CURLOPT_POSTFIELDS,$bodydata);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
		
		$headers = array(
				'Content-type: application/json',
				'X-Auth: ' . $this->xauth_session_key,
		);
		curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
		$response = curl_exec($ch);
		return $this->processResponse($response);
	}

	/*
	Delete the layer data of layer <layer> .
	*/
	function deleteNodes($layer){
		global $endpoint;
		$upload_url = $endpoint . "/layer/" . $layer;
		$bodydata = json_encode($request);
		$ch = curl_init($upload_url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "DELETE");
		$headers = array(
				'Content-type: application/json',
				'X-Auth: ' . $this->xauth_session_key,
		);
		curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
		$response = curl_exec($ch);	
		return $this->processResponse($response);
	}
	
	/*
	The Bulk API expects JSON in the following form:
	{
	  "create": {
	    "params": {
	      "create_type": "create",
	      "srid": 4326
	    }      
	  },
	  "nodes": [
	    {
	      "id": "ASD",
	      "name": "Amsterdam Centraal",
	      "modalities": ["rail"],
	      "geom" : {
	         "type": "Point",
	          "coordinates" : [
	            4.9002776,
	            52.378887
	          ]
	       },
	       "data" : {
	          "naam_lang": "Amsterdam Centraal",   
	          "code": "ASD"
	       }
	    },
	    {
	      "cdk_id": "n46419880",
	      "modalities": ["rail"],        
	      "data" : {
	        "naam_lang": "Amsterdam Centraal",   
	        "code": "ASD"
	      }       
	    }
	  ]
	}
	*/
	//create a node
	function createNode($lat, $lon, $id, $data){
		$geom = array();
		$geom["type"] = "Point";
		$geom["coordinates"] = array(floatval($lat), floatval($lon));
		$node = array("id" => $id, "name" => $id, "geom" => $geom, "data"=> $data);
		return $node;
	}

	//create a request
	function createRequest($nodes){
		$request = array();
		$request["create"] = array("params" => array("create_type"=>"create","srid"=>4326));
		$request["nodes"] = $nodes;
		return $request;
	}
	
	//process response of the citysdk
	function processResponse($response){
		global $status;
		$success = false;
		$response_json = json_decode($response);
		if (isSet($response_json->status)){
			$this->message = "";
			$this->status = $response_json->status;
			if ($this->status=="success"){
				$this->results = $response_json->results;
				return true;
			} else {
				$this->message = $response_json->results[0];
			}
		}
		return false;
	}
	
	function getDateTime(){
		$datetime = new DateTime();
		return $datetime->format('c');
	}
	
	function getUniqueID(){
		list($usec, $sec) = explode(" ", microtime());
		$id= ((float)$sec + (float)$usec);
		return str_ireplace(".", "", $id);
	}
}

?>