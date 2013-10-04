![image](http://citysdk.waag.org/img/citysdk.png)

Citymarker
==========

IOS and PHP Project showing how to read and write data to the [CitySDK](http://citysdk.waag.org/) environment.

Examples and documentation can be found [here](http://citysdk.waag.org/).

The project is composed of two sub projects:

1. an IOS project: an app able to inspect tree (of type Ulmus) in Amsterdam
2. an PHP project: a proxy between the app and the CitySDK environment.


Architecture of the IOS project
= 

*Model*


The class **CitySDKManager** contains the following methods:

**getNodes**: get a list of nodes from one or more layer(s) from CitySDK.

Set your own layers here:

 `NSString *layers = @"2cm.dev.meldapp|2cm.bomen.iepen";
 `
  
  `NSString *getUrl = [NSString stringWithFormat:
                        @"http://api.citysdk.waag.org/admr.nl.amsterdam/nodes?layer=%@&geom&per_page=250&lat=%f8&lon=%f&radius=200",
                        [layers stringByAddingPercentEscapesUsingEncoding:
                         NSASCIIStringEncoding],
                        mapcenter.latitude,
                        mapcenter.longitude];
   `


**postNode**: post a node via a proxy to city SDK, see the PHP Project. You need to set citysdkproxyUrl with your own CitySDK proxy:

`
NSString *citysdkproxyUrl = @"http://api.citysdk.nl citysdkproxy.php";
`

**getBAGAddress**: returns an address in the Netherlands bases on geo X,Y. We use the layer: bag.vbo.  For information about BAG, see [http://bag.vrom.nl/](http://bag.vrom.nl/).
 
   `NSString *getUrl = [NSString stringWithFormat:@"http://api.citysdk.waag.org/nodes?layer=bag.vbo&geom&per_page=1&lat=%f8&lon=%f", mapcenter.latitude, mapcenter.longitude];
    `
 
The class **CitySDKNode** wraps around the JSON response of the CitySDK.

*View*

The class **MapViewController** show a map with available trees and reports

The class **MarkerViewController** enables users to fill in a simple form to send to the CitySDK.



Architecture of the PHP project
= 
**phpsettings.php**
The citysdk proxy settings

Please consult [http://citysdk.waag.org/api-write](http://citysdk.waag.org/api-write:):
To use the CitySDK Mobility Write API, you need a valid user account. For now, we only provide write access to a couple of selected organisations and data owners, but this will change soon. In the meantime, if you have data you think CitySDK desperately needs, you can send an email to Citysdk Support: citysdk@waag.org

You need to set:

`//which city sdk?`

`$endpoint = "https://api.citysdk.waag.org";`

`$username = "<your username>";`

`$password = "<your password>";`


**citysdkfunctions.php** contains the PHP class **CitySDKProxy** this one has the following functions:

**startSession()**: 	All Write API requests require authentication by means of a session key, a random string that provides temporary, secure access to the Write API. 


**destroySession()**: Session keys are valid for one minute only, but each request to the Write API will extend the validity with another minute. After one minute of inactivity, your session will time out and you will need to request a new session key to do new Write API requests.
	When done, you should release your session.
 

**createNode($lat, $lon, $id, $data)** creates a node to upload
	
	
**function createRequest($nodes)** creates a request

** uploadNodes($layer, $request)** 	Bulk API: writing/updating multiple nodes and node data at once

** deleteNodes($layer)** Delete the layer data of layer <layer> 
	

Contact
=

citysdk@waag.org


Read more
=



Check [this](http://citysdk.waag.org/data) for available data.

 Check [this](http://citysdk.waag.org/api-read) for reading data, parameters and return formats.
 
 Check  [this](http://citysdk.waag.org/api-write) for writing data, parameters and return formats.
