//
//  CitySDKManager.h
//  CityMarker
//
//  Created by Chris van Aart on 28/08/2013.
//  Copyright (c) 2013 2CoolMonkeys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CitySDKNode.h"

@interface CitySDKManager : NSObject

@property(nonatomic,retain) NSString *currentAddress, *userName, *proxyResponse;
@property(nonatomic,retain) NSMutableArray *nodes;
@property(nonatomic,readwrite) CLLocationCoordinate2D mapcenter;
@property(nonatomic,retain) NSMutableString *log;

//Singleton

+ (CitySDKManager *)getInstance;

//find street address based on x,y
-(void)getBAGAddress;

// load nodes from one or more layers directly from citysdk
-(void)getNodes;

// post a new node via the citysdkproxy
-(void)postNode:(CitySDKNode *)CitySDKNode;


@end
