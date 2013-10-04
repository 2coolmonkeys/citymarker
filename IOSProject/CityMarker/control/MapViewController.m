//
//  MapViewController.m
//  CityMarker
//
//  Created by Chris van Aart on 28/08/2013.
//  Copyright (c) 2013 2CoolMonkeys. All rights reserved.
//

#import "MapViewController.h"
#import "MarkerAnnotation.h"
#import "MarkerViewController.h"
#import "CitySDKManager.h"
#import "CitySDKNode.h"

@implementation MapViewController

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    init = false;
    
    //make buttonviews fancy
    btnView.layer.borderColor = [UIColor grayColor].CGColor;
    btnView.layer.borderWidth = 1.0f;
    
    popView.layer.borderColor = [UIColor grayColor].CGColor;
    popView.layer.borderWidth = 1.0f;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0;
    [mapView addGestureRecognizer:lpgr];
    [lpgr release];
    
    origiPopViewFrame = popView.frame;
    origCitySdkImageView = citySdkImageView.frame;
    citySdkImageView.hidden = true;
    [self hidePopup:0];
    motionManager = [[CMMotionManager alloc] init];
    [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        double p = motion.attitude.pitch;
        CGRect frame = topView.frame;
        frame.origin.x = 10;
        frame.origin.y = 30-(10*p);
        topView.frame = frame;
        
        CGRect frame2 = origCitySdkImageView;
        frame2.origin.y = menuView.frame.origin.y - (citySdkImageView.frame.size.height + 5  + 10*p);
        citySdkImageView.frame = frame2;
        citySdkImageView.hidden = false;
    }];
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!init){
        MKCoordinateRegion mapRegion;
        mapRegion.center.latitude = 52.372778;
        mapRegion.center.longitude = 4.900278;
        mapRegion.span.latitudeDelta = 0.002;
        mapRegion.span.longitudeDelta = 0.002;
        [mapView setRegion:mapRegion animated: YES];
        init = true;
    } else {
        [self refreshNodes];
    }
}

#pragma mark - handleLongPress

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    [self hidePopup:0.5];
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    
    newMarkerCoordinate = touchMapCoordinate;
    MarkerAnnotation *annot = [[MarkerAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    annot.isNew = true;
    [mapView addAnnotation:annot];
    [mapView selectAnnotation:annot animated:YES];
    
    for (id<MKAnnotation> currentAnnotation in mapView.annotations) {
        if ([currentAnnotation isEqual:annot]) {
            [mapView selectAnnotation:currentAnnotation animated:FALSE];
        }
    }
}

#pragma mark - MKAnnotationView logic

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[MarkerAnnotation class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        if ([annotation isKindOfClass:[MarkerAnnotation class]]){
            MarkerAnnotation *tl = (MarkerAnnotation *)annotation;
            // Button logic
            UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
            button.frame = CGRectMake(0, 0, 23, 23);
            [button addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = [tl.theid integerValue];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorGreen;
            if (tl.isNew){
                annotationView.pinColor = MKPinAnnotationColorRed;
                annotationView.draggable      = YES;
                button.tag = -1;
            }
            if (tl.isReport){
                annotationView.pinColor = MKPinAnnotationColorRed;
            }
            annotationView.rightCalloutAccessoryView = button;
        }
        
        return annotationView;
    }
    
    return nil;
}

#pragma mark - Actions

-(IBAction)showInfo:(id)sender{
    [self hidePopup:0.5];
    
    UIButton *b = (UIButton *)sender;
    int tag = b.tag;
    
    MarkerViewController *markerViewController = [[MarkerViewController alloc] initWithNibName:@"MarkerViewController" bundle:nil];
    
    if (tag>=0){
        CitySDKNode *citySDKNode = [[CitySDKManager getInstance].nodes objectAtIndex:tag];
        //add you own layer here:
        if ([citySDKNode.layer isEqualToString:@"2cm.dev.meldapp"]){
            
            NSMutableString *msgContent  =[[NSMutableString alloc] init];
            for (NSString* key in citySDKNode.nodeValues) {
                NSString *value = [citySDKNode.nodeValues objectForKey:key];
                // do stuff
                [msgContent appendFormat:@"%@:%@\n", key,value];
                
            }
            
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:[citySDKNode.nodeValues objectForKey:@"title"]
                                                              message:msgContent
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
            
            return;
        }
        
        
        markerViewController.citySDKNode = citySDKNode;
    } else {
        CitySDKNode *newCitySDKNode = [[CitySDKNode alloc] init];
        newCitySDKNode.coordinate = newMarkerCoordinate;
        markerViewController.citySDKNode = newCitySDKNode;
        
    }
    [self presentViewController:markerViewController animated:true completion:^{}];
    [markerViewController release];
}


-(IBAction)zoomToUserLocation{
    [mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
    [self hidePopup:0.5];
    MKCoordinateRegion region;
    region.center = mapView.userLocation.coordinate;
    [CitySDKManager getInstance].mapcenter =mapView.userLocation.coordinate;
    
    MKCoordinateSpan span = mapView.region.span;
    if (span.latitudeDelta>0.001){
        span.latitudeDelta  = 0.001; 
        span.longitudeDelta = 0.001;
    }
    region.span = span;
    [self updateAddress];
    [mapView setRegion:region animated:YES];
}

-(IBAction)showCitySdk:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://citysdk.waag.org"]];
}


-(IBAction)pressInfo:(id)sender{
    if (   menuView.frame.origin.y == popView.frame.origin.y) {
        [self showPopup:0.5];
    } else {
        [self hidePopup:0.5];
    }
}

-(IBAction)toggleMap:(id)sender{
    [self hidePopup:0.5];
    
    
    switch (mapSelection.selectedSegmentIndex) {
        case 0:
            [mapView setMapType:MKMapTypeStandard];
            break;
        case 1:
            [mapView setMapType:MKMapTypeHybrid];
            break;
        case 2:
            [mapView setMapType:MKMapTypeSatellite];
            break;
            
        default:
            break;
    }
}

-(IBAction)placeCurrentLocationMarker{
    [self hidePopup:0.5];
    
    MarkerAnnotation *annot = [[MarkerAnnotation alloc] init];
    annot.coordinate = mapView.centerCoordinate;
    newMarkerCoordinate =  mapView.centerCoordinate;
    annot.isNew = true;
    [mapView addAnnotation:annot];
    [mapView selectAnnotation:annot animated:YES];
    
    
    for (id<MKAnnotation> currentAnnotation in mapView.annotations) {
        if ([currentAnnotation isEqual:annot]) {
            [mapView selectAnnotation:currentAnnotation animated:FALSE];
        }
    }
}

-(IBAction)shareLog:(id)sender{
    Class emailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if(emailClass != nil && [emailClass canSendMail])
	{
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.navigationBar.tintColor = [UIColor blackColor];
        picker.mailComposeDelegate = self;
        
        NSString *subject = @"CityMarker log";
        [picker setSubject:subject];
        picker.delegate = self;
        
        
        [picker setMessageBody:[CitySDKManager getInstance].log isHTML:NO];
        // [docData release];
        // [docxfactory release];
        
        [self presentViewController:picker animated:YES completion:nil];
        //  [picker release];
	} else {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Geen e-mail" message:@"Stel eerst een e-mail client in"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
		
	}
}

#pragma mark -

-(void)refreshNodes{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [[CitySDKManager getInstance] getNodes];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self processData];
        });
    });
}

-(void)updateAddress{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [[CitySDKManager getInstance] getBAGAddress];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            topTitle.text = [CitySDKManager getInstance].currentAddress;
            
        });
    });
}


-(void)processData{
    for (id<MKAnnotation> annotation in mapView.annotations) {
        [mapView removeAnnotation:annotation];
    }
    int i=0;
    MarkerAnnotation *annotation = nil;
    for (CitySDKNode  * node in [CitySDKManager getInstance].nodes) {
        //replace with your own layers:
        if ([node.layer isEqualToString:@"2cm.dev.meldapp"]){
            annotation = [[MarkerAnnotation alloc] initWithName:[node.nodeValues objectForKey:@"title"] coordinate:node.coordinate];
            annotation.isNew = false;
            annotation.isReport = true;
            annotation.theid = [NSNumber numberWithInt:i];
            
        }
        if ([node.layer isEqualToString:@"2cm.bomen.iepen"]){
            annotation = [[MarkerAnnotation alloc] initWithName:[node.nodeValues objectForKey:@"latin_name"] coordinate:node.coordinate];
            annotation.isNew = false;
            annotation.theid = [NSNumber numberWithInt:i];
        }
        i++;
        
        [mapView  addAnnotation:annotation];
    }
    
    if(annotation){
        [mapView selectAnnotation:annotation animated:FALSE];
    }
    
}

#pragma mark popup logic

-(void)hidePopup:(double)duration{
    [UIView animateWithDuration:duration animations:^{
        popView.frame = CGRectMake( menuView.frame.origin.x,  menuView.frame.origin.y, popView.frame.size.width,
                                   popView.frame.size.height);
    }];
}


-(void)showPopup:(double)duration{
    [UIView animateWithDuration:duration animations:^{
        popView.frame = CGRectMake( menuView.frame.origin.x,
                                   menuView.frame.origin.y-popView.frame.size.height,
                                   popView.frame.size.width,
                                   popView.frame.size.height);
        
    }];
}


#pragma mark - map logic

- (void)mapView:(MKMapView *)_mapView regionDidChangeAnimated:(BOOL)animated{
    [CitySDKManager getInstance].mapcenter = mapView.centerCoordinate;
    [self hidePopup:0.5];
    
    [self refreshNodes];
    [self updateAddress];
}

#pragma mark - messaging

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    
    if (result==MFMailComposeResultSent){
        [[CitySDKManager getInstance].log setString:@""];
    }
    [self dismissViewControllerAnimated:true completion:^{
    }];
}

#pragma mark - memory


- (void)dealloc {
	[motionManager release];
    [super dealloc];
}

@end
