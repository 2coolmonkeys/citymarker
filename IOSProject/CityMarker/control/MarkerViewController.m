//
//  MarkerViewController.m
//  CityMarker
//
//  Created by Chris van Aart on 28/08/2013.
//  Copyright (c) 2013 2CoolMonkeys. All rights reserved.
//

#import "MarkerViewController.h"


@implementation MarkerViewController

@synthesize citySDKNode;

- (void)viewDidLoad
{
    [super viewDidLoad];
    markerTitle.text = @"Nieuwe melding";
    user.text = [CitySDKManager getInstance].userName;
    comments.layer.borderColor = [UIColor grayColor].CGColor;
    comments.layer.borderWidth = 1.0f;

}

-(void)viewWillAppear:(BOOL)animated{
    
    user.text = [CitySDKManager getInstance].userName;
    if (citySDKNode) {
        report.text = [citySDKNode.nodeValues objectForKey:@"latin_name"];
    }
    [user becomeFirstResponder];
}

-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:true completion:nil];
}


-(IBAction)save:(id)sender{
    
    [CitySDKManager getInstance].userName =user.text;
    saveBtn.enabled = false;
    backBtn.enabled = false;
    
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            CitySDKNode *_citySDKNode = [[CitySDKNode alloc] init];
            if (citySDKNode){
                _citySDKNode.coordinate = citySDKNode.coordinate;
            }
            [_citySDKNode.nodeValues setValue:user.text forKey:@"afzender"];
            [_citySDKNode.nodeValues setValue:report.text forKey:@"title"];
            [_citySDKNode.nodeValues setValue:comments.text forKey:@"description"];
            if (citySDKNode){
                [_citySDKNode.nodeValues setValue:citySDKNode.cdk_id forKey:@"cdk_id"];
            }
            [[CitySDKManager getInstance] postNode:_citySDKNode];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"resultaat"
                                                                  message:[CitySDKManager getInstance].proxyResponse
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                [message show];
                
                [self dismissViewControllerAnimated:true completion:nil];
                
                
            });
        });
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
	// Try to find next responder
	UIResponder* nextResponder = [self.view viewWithTag:nextTag];
	if ((nextResponder)) {
        // Found next responder, so set it.
		[nextResponder becomeFirstResponder];
	} else {
		// Not found, so remove keyboard.
		
	}
	return NO; // We do not want UITextField to insert line-breaks.
}

#pragma mark - old school memory management

-(void)dealloc{
    [super dealloc];
}

@end
