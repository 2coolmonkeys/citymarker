//
//  MarkerViewController.h
//  CityMarker
//
//  Created by Chris van Aart on 28/08/2013.
//  Copyright (c) 2013 2CoolMonkeys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CitySDKNode.h"
#import "CitySDKManager.h"

@interface MarkerViewController : UIViewController <MKMapViewDelegate,UITextFieldDelegate>{
    IBOutlet UILabel *markerTitle;
    IBOutlet UITextField *user, *report;
    IBOutlet UITextView *comments;
    IBOutlet UIButton *saveBtn, *backBtn;
}

@property(nonatomic,assign) CitySDKNode *citySDKNode;

@end
