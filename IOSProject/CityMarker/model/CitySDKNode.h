//
//  CitySDKNode.h
//  CityMarker
//
//  Created by Chris van Aart on 01/09/2013.
//  Copyright (c) 2013 2CoolMonkeys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CitySDKNode : NSObject

@property (nonatomic,readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic,retain) NSMutableDictionary *nodeValues;
@property (nonatomic,retain) NSString *cdk_id , *layer;

- (CitySDKNode *) initWithJSON:(NSDictionary *) jsonObject;

@end
