//
//  CitySDKManager.m
//  CityMarker
//
//  Created by Chris van Aart on 28/08/2013.
//  Copyright (c) 2013 2CoolMonkeys. All rights reserved.
//

#import "CitySDKManager.h"
#import "CitySDKNode.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@implementation CitySDKManager

@synthesize nodes,mapcenter,currentAddress,userName,log;

#pragma - Singleton

static CitySDKManager *instance = nil;

+ (CitySDKManager *)getInstance {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[self alloc] init];
            
        }
    }
    return instance;
}

#pragma mark - init

- (id)init{
    if (self = [super init]){
        nodes = [[NSMutableArray alloc] init];
        log = [[NSMutableString alloc] init];
        self.userName = @"";
    }
    return self;
}

#pragma mark - get a list of nodes one or more layers from city SDK
/*
 Check http://citysdk.waag.org/data for available data
 Check http://citysdk.waag.org/api-read for parameters and return format
 */

-(void)getNodes{
    
    NSString *layers = @"2cm.dev.meldapp|2cm.bomen.iepen";
    NSString *getUrl = [NSString stringWithFormat:
                        @"http://api.citysdk.waag.org/admr.nl.amsterdam/nodes?layer=%@&geom&per_page=250&lat=%f8&lon=%f&radius=200",
                        [layers stringByAddingPercentEscapesUsingEncoding:
                         NSASCIIStringEncoding],
                        mapcenter.latitude,
                        mapcenter.longitude];
    [log appendFormat:@"get Nodes from: %@\n\n", getUrl];
    NSURL *url= [NSURL URLWithString:getUrl];
    NSData* data = [NSData dataWithContentsOfURL:url];
    if (data==nil) {
        return;
    }
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    
    NSArray* results = [json objectForKey:@"results"];
    
    [nodes removeAllObjects];
    
    for (NSDictionary *res in results){
        CitySDKNode *csn = [[CitySDKNode alloc] initWithJSON:res];
        [nodes addObject:csn];
    }
}

#pragma mark - get BAG Address

/*
 Check http://citysdk.waag.org/data for available data
 Check http://citysdk.waag.org/api-read for parameters and return format
 
 The layer: bag.vbo  contains the following data:
 category:	administrative.vbo
 description:	Addresses with real-estate functional units, contained within a building: apartments, shops, houses, industrial spaces, etc.Data from BAG, Dutch national building and address register.
 organization:	Waag Society
 maintainer:	citysdk@waag.org
 source:	 BAG, Kadaster
 http://nlextract.nl
 
 For information about BAG, see http://bag.vrom.nl/
 */

-(void)getBAGAddress{
    NSString *getUrl = [NSString stringWithFormat:@"http://api.citysdk.waag.org/nodes?layer=bag.vbo&geom&per_page=1&lat=%f8&lon=%f", mapcenter.latitude, mapcenter.longitude];
    
    [log appendFormat:@"findAddress: %@\n\n", getUrl];
    
    NSURL *url= [NSURL URLWithString:getUrl];
    NSData* data = [NSData dataWithContentsOfURL:url];
    if (data==nil) {
        return;
    }
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    
    NSArray* results = [json objectForKey:@"results"];
    if (results){
        for (NSDictionary *res in results){
            CitySDKNode *csn = [[CitySDKNode alloc] initWithJSON:res];
            currentAddress = [csn.nodeValues valueForKey:@"adres"];
        }
    }
}

#pragma mark - post a node via a proxy to city SDK.
/*
 check the PHP map of this project for an implementation of a citysdk proxy
 
 you need to provide your own citysdk proxy, follow the instructions:
 
 
 To use the CitySDK Mobility Write API, you need a valid user account. For now, we only provide write access to a couple of selected organisations and data owners, but this will change soon. In the meantime, if you have data you think CitySDK desperately needs, you can send an email to Citysdk Support: citysdk@waag.org
 see: http://citysdk.waag.org/api-write
 */

-(void)postNode:(CitySDKNode *)citySDKNode{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:citySDKNode.nodeValues                                                       options:0  error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  
    //add here your own citysdk proxy address
    NSString *citysdkproxyUrl = @"http://api.citysdk.nl/citysdkproxy.php";
    NSURL *url = [NSURL URLWithString:citysdkproxyUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPMethod:@"POST"];
    
    //add here your own layer name:
    NSString *layerName = @"2cm.dev.meldapp";
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"layer=%@",layerName];
    [postString appendFormat:@"&x=%f", citySDKNode.coordinate.latitude];
    [postString appendFormat:@"&y=%f", citySDKNode.coordinate.longitude];
    [postString appendString:@"&node="];
    [postString appendFormat:@"%@",[jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [log appendFormat:@"postNode: %@\n\n", postString];
    
    [postString release];
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (data!=nil){
        NSString* newStr = [[[NSString alloc] initWithData:data
                                                  encoding:NSUTF8StringEncoding] autorelease];
        [log appendFormat:@"postNodeResult: %@\n\n", newStr];
        self.proxyResponse = newStr;
    } else {
        self.proxyResponse = @"error uploading data";
    }
    
    if (error){
        self.proxyResponse =@"error uploading data";
    }
    
}

#pragma mark - old school memory management

-(void)dealloc{
    [super dealloc];
    self.currentAddress = nil;
    self.userName = nil;
    self.nodes = nil;
    self.log = nil;
}


@end
