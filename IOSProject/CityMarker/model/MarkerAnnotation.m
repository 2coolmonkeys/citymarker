//
//  MarkerAnnotation.m
//  CityMarker
//
//  Created by Chris van Aart on 28/08/2013.
//  Copyright (c) 2013 2CoolMonkeys. All rights reserved.
//

#import "MarkerAnnotation.h"

@implementation MarkerAnnotation


@synthesize name = _name, latin_name = _latin_name;
@synthesize address = _address;
@synthesize coordinate = _coordinate,theid = _theid, isNew;

- (id)initWithName:(NSString*)name coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        if (!name){
            self.name = @"Boom";
        } else {
            self.name = name;
        }
        _coordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    if (isNew){
        return @"Nieuwe melding";
    }
    return  self.name ;
}

- (NSString *)subtitle {
    return [NSString stringWithFormat:@"%f, %f", _coordinate.latitude, _coordinate.longitude];
}

#pragma mark - old school memory management

-(void)dealloc{
    self.name = nil;
    self.address = nil;
    [super dealloc];
}


@end
