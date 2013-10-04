//
//  MarkerAnnotation.h
//  CityMarker
//
//  Created by Chris van Aart on 28/08/2013.
//  Copyright (c) 2013 2CoolMonkeys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MarkerAnnotation : NSObject<MKAnnotation>

@property (nonatomic,retain) NSString *name, *latin_name;
@property (nonatomic,retain) NSString *address;
@property (nonatomic,readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic,retain) NSNumber *theid;
@property (nonatomic,readwrite) bool isNew, isReport;

- (id)initWithName:(NSString*)name coordinate:(CLLocationCoordinate2D)coordinate;

@end
