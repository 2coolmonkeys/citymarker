
//
//  CitySDKNode.m
//  CityMarker
//
//  Created by Chris van Aart on 01/09/2013.
//  Copyright (c) 2013 2CoolMonkeys. All rights reserved.
//

#import "CitySDKNode.h"

@implementation CitySDKNode

@synthesize coordinate, cdk_id, nodeValues, layer;

- (CitySDKNode *) initWithJSON:(NSDictionary *) jsonObject
{
    self = [super init];
    if (self) {
        NSDictionary *geom = [jsonObject objectForKey:@"geom"];
        NSArray *coordinates = [geom objectForKey:@"coordinates"];
        NSString *Xcoord = [coordinates  objectAtIndex:0];
        NSString *Ycoord = [coordinates  objectAtIndex:1];
        double xx = [Xcoord doubleValue];
        double yy = [Ycoord doubleValue];
        coordinate.latitude =yy; 
        coordinate.longitude = xx;
     
        self.cdk_id = [self getString:jsonObject name:@"cdk_id"];
        self.layer = [self getString:jsonObject name:@"layer"];
        NSDictionary *layers = [jsonObject objectForKey:@"layers"];
        NSDictionary *layerdata = [layers objectForKey:layer];
        NSDictionary *data = [layerdata objectForKey:@"data"];
        if (data){
            nodeValues = [[NSMutableDictionary alloc] initWithDictionary:data];
        }
    }
    return self;
}

-(id)init{
    if((self=[super init])){
        nodeValues = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString *)getString:(NSDictionary *)dict name:(NSString *)name{
    NSString *result=@"";
    if ([dict objectForKey:name]!=nil) {
        result = [dict objectForKey:name];
    }
    return result;
}

#pragma mark - old school memory management

-(void)dealloc{
    self.nodeValues = nil;
    self.cdk_id  = nil;
    self.layer = nil;
    [super dealloc];
}

@end
