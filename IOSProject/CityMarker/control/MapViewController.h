//
//  MapViewController.h
//  CityMarker
//
//  Created by Chris van Aart on 28/08/2013.
//  Copyright (c) 2013 2CoolMonkeys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import <CoreMotion/CoreMotion.h>
#import <MessageUI/MessageUI.h>

@interface MapViewController : UIViewController <MKMapViewDelegate, MBProgressHUDDelegate,MFMailComposeViewControllerDelegate,UINavigationControllerDelegate>{
    IBOutlet MKMapView *mapView;
    IBOutlet UILabel *topTitle;
    IBOutlet UIView *btnView,*popView, *menuView, *topView;
    IBOutlet UISegmentedControl *mapSelection;
    IBOutlet UIImageView *citySdkImageView;
    MBProgressHUD *HUD;
    
    bool init;
    CGRect origiPopViewFrame, origCitySdkImageView;
    CMMotionManager *motionManager;
    CLLocationCoordinate2D newMarkerCoordinate;
}

@end
