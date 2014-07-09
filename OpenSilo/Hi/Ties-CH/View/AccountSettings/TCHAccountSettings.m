//
//  TCHAccountSettings.m
//  Ties-CH
//
//  Created by  on 6/4/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import "TCHAccountSettings.h"
#import "TCHUpdateProfileVC.h"
#import "TCHAppDelegate.h"
#import "TCHPrivacyViewCOntroller.h"
#import "GSIndeterminateProgressView.h"
#import "ASProgressPopUpView.h"

@interface TCHAccountSettings ()<ASProgressPopUpViewDataSource> {
    NSInteger gender;
    GSIndeterminateProgressView *_progressView;
    
}
@property (weak, nonatomic) IBOutlet ASProgressPopUpView *ASprogressView;
@property (nonatomic, weak) IBOutlet UIImageView *navigationBar;
@property (nonatomic, weak) IBOutlet UIImageView *imgGender;
@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (nonatomic, weak) IBOutlet UIButton *friendsButton;
@property (nonatomic, weak) IBOutlet NKColorSwitch *locationSwitch;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;

-(IBAction)onClickGender:(id)sender;
-(IBAction)valueCpohange:(id)sender;

-(IBAction)onClickSave:(id)sender;
-(IBAction)onClickProfile:(id)sender;

@end

@implementation TCHAccountSettings
@synthesize fromProfileScreen;

-(void)loadView {
    
    if([CLLocationManager locationServicesEnabled]){

        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            _locationSwitch.on = FALSE;
        } else {
            _locationSwitch.on = TRUE;
        }
    } else {
        _locationSwitch.on = FALSE;
    }
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:TCHAccGender]) {
        gender = [[NSUserDefaults standardUserDefaults] integerForKey:TCHAccGender];
        _imgGender.image = [UIImage imageNamed:[NSString stringWithFormat:@"setting_gender_%ld",(long)gender]];
    }
    
    if (self.fromProfileScreen) {
        _cameraButton.hidden = YES;
        _friendsButton.hidden = YES;
    }
    
    self.ASprogressView.popUpViewCornerRadius = 12.0;
    self.ASprogressView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:28];
    self.ASprogressView.popUpViewAnimatedColors = @[ThemeColor, ThemeColor, ThemeColor];

    [self.ASprogressView showPopUpViewAnimated:YES];
    self.ASprogressView.hidden = YES;


}

-(void)reloadLoadedView {
    [super reloadLoadedView];
}

#pragma mark -
#pragma mark Action Events

-(IBAction)onClickFriendsList:(id)sender {
    TCHMainViewController *viewController = (TCHMainViewController *)[self rootViewController];
    [viewController setCurrentPage:kFavoriteFriendsList];
}

-(IBAction)onClickProfile:(id)sender {
    TCHMainViewController *viewController = (TCHMainViewController *)[self rootViewController];
    [viewController presentTCHUpdateProfileVC];
}

-(IBAction)onClickGender:(id)sender {
    UIButton *button = (UIButton *)sender;
    gender = button.tag;
    [[NSUserDefaults standardUserDefaults] setInteger:gender forKey:TCHAccGender];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _imgGender.image = [UIImage imageNamed:[NSString stringWithFormat:@"setting_gender_%ld",(long)gender]];
}

-(IBAction)valueChange:(id)sender {
    if ([_locationSwitch isOn]) {
        
        if([CLLocationManager locationServicesEnabled]){

            if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
                [appDelegate.window makeToast:@"Please enable location services\n Settings -> Privacy -> Location Services" backgroundColor:RedColor];

                _locationSwitch.on = FALSE;
            }
        }
    }
}
- (IBAction)onClickPrivacy:(id)sender {
    
    TCHMainViewController *viewController = (TCHMainViewController *)[self rootViewController];
    
    TCHPrivacyViewController *controller = [[TCHPrivacyViewController alloc] initWithNibName:@"TCHPrivacyViewController" bundle:[NSBundle mainBundle]];
    
    [viewController presentViewController:controller animated:YES completion:nil];
    
}

-(IBAction)onClickSave:(id)sender {

    self.ASprogressView.hidden = NO;
    [self progress];
    
    if (self.fromProfileScreen) {
        [self performSelector:@selector(registerUser) withObject:nil afterDelay:0.2];
    } else {
        [self performSelector:@selector(updateAccountInfo) withObject:nil afterDelay:0.2];
    }
}

#pragma mark -
#pragma mark Web service call

-(void)registerUser {
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:TCHUserName];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:DeviceToken];
    NSString *lat = [NSString stringWithFormat:@"%0.6f",appDelegate.bestEffortAtLocation.coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%0.6f",appDelegate.bestEffortAtLocation.coordinate.longitude];
    NSString *genderCode = [[[NSUserDefaults standardUserDefaults] objectForKey:TCHGenderCode] isEqualToString:TCHMale] ? @"M" : @"F";
    NSString *interestIn = [appDelegate codeForGender:gender];
    
    NSString *fileName = @"TCHFileName.jpg";
    NSString *imagePath = [SelfProfileImageName pathInDocumentDirectory];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    NSDictionary *parameters = @{@"name": name,
                                 @"lat": lat,
                                 @"lng" : lng,
                                 @"gender" : genderCode,
                                 @"interestIn" : interestIn,
                                 @"width":[NSString stringWithFormat:@"%i", (int)width],
                                 @"height":[NSString stringWithFormat:@"%i", (int)height],
                                 @"deviceToken":token};
    
    AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
    client.responseSerializer = [AFJSONResponseSerializer serializer];
    [client POST:[NSString stringWithFormat:@"%@r/user/signin?",API_HOME] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if(image){
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1) name:@"pic" fileName:fileName mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[[responseObject objectForKey:@"ack"] lowercaseString] isEqualToString:@"success"]) {
            
            self.fromProfileScreen = NO;
            
            NSMutableDictionary *dict = [[responseObject objectForKey:@"object"] mutableCopy];
            [dict handleNullValues];
            [[NSUserDefaults standardUserDefaults] setObject:dict forKey:UserProfile];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsProfileConfigure];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self.ASprogressView.hidden = YES;
            
            TCHUpdateProfileVC *viewController = (TCHUpdateProfileVC *)[self rootViewController];
            [viewController dismiss];
            
        } else {
            [appDelegate.window makeToast:ServerDBError backgroundColor:[UIColor redColor]];
        }
        self.ASprogressView.hidden = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [appDelegate.window makeToast:ServerConnection backgroundColor:[UIColor redColor]];
        self.ASprogressView.hidden = YES;
    }];
}

-(void)updateAccountInfo {
    NSDictionary *profileDict = [[NSUserDefaults standardUserDefaults] objectForKey:UserProfile];
    NSString *uuid = [profileDict objectForKey:@"uuid"];
    NSString *lat = [NSString stringWithFormat:@"%0.6f",appDelegate.bestEffortAtLocation.coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%0.6f",appDelegate.bestEffortAtLocation.coordinate.longitude];

    NSString *tchAccGender = [NSString stringWithFormat:@"%ld",(long)[[NSUserDefaults standardUserDefaults] integerForKey:TCHAccGender]];
    NSString *genderCode = [tchAccGender isEqualToString:TCHMale] ? @"M" : [tchAccGender isEqualToString:TCHFemale] ? @"F" : @"";
    NSString *interestIn = [appDelegate codeForGender:gender];
    
    NSDictionary *parameters = @{@"uuid": uuid,
                                 @"lat": lat,
                                 @"lng" : lng,
                                 @"gender" : genderCode,
                                 @"interestIn" : interestIn};
    
    AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
    client.responseSerializer = [AFJSONResponseSerializer serializer];
    [client POST:[NSString stringWithFormat:@"%@r/user/profile/edit?",API_HOME] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
        }  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[[responseObject objectForKey:@"ack"] lowercaseString] isEqualToString:@"success"]) {
            
            NSMutableDictionary *dict = [[responseObject objectForKey:@"object"] mutableCopy];
            [dict handleNullValues];
            [[NSUserDefaults standardUserDefaults] setObject:dict forKey:UserProfile];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsProfileConfigure];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //TCHMainViewController *viewController = [[TCHMainViewController alloc]init];
            //appDelegate.window.rootViewController = viewController;
            TCHMainViewController *viewController = (TCHMainViewController *)[appDelegate.navigationController.viewControllers lastObject];
            [viewController reloadLoadedGirlList];
            [viewController setCurrentPage:kGirlsListingView];
            
        } else {
            [appDelegate.window makeToast:ServerDBError backgroundColor:[UIColor redColor]];
        }
        self.ASprogressView.hidden = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [appDelegate.window makeToast:ServerConnection backgroundColor:[UIColor redColor]];
        self.ASprogressView.hidden = YES;
    }];
}

- (UIViewController*)rootViewController {
    
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}


- (void)progress
{
    
    float progress = self.ASprogressView.progress;
    if (progress < 1.0) {
        
        progress += 0.2;
        
        [self.ASprogressView setProgress:progress animated:YES];
        
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(progress)
                                       userInfo:nil
                                        repeats:NO];
    }
}

#pragma mark - ASProgressPopUpView dataSource

// <ASProgressPopUpViewDataSource> is entirely optional
// it allows you to supply custom NSStrings to ASProgressPopUpView
- (NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress
{
    NSString *s;
    if (progress < 0.2) {
        s = @"Just starting";
    } else if (progress > 0.4 && progress < 0.6) {
        s = @"About halfway";
    } else if (progress > 0.75 && progress < 1.0) {
        s = @"Nearly there";
    } else if (progress >= 1.0) {
        s = @"Complete";
    }
    return s;
}

// by default ASProgressPopUpView precalculates the largest popUpView size needed
// it then uses this size for all values and maintains a consistent size
// if you want the popUpView size to adapt as values change then return 'NO'
- (BOOL)progressViewShouldPreCalculatePopUpViewSize:(ASProgressPopUpView *)progressView;
{
    return NO;
}


@end
