//
//  TCHUpdateProfileVC.m
//  Ties-CH
//
//  Created by  on 6/3/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import "TCHUpdateProfileVC.h"
#import "VLBCameraView.h"
#import "TCHMainViewController.h"

#import "TCHProfileSelection.h"
#import "TCHAccountSettings.h"

@interface TCHUpdateProfileVC () <VLBCameraViewDelegate>

@property (nonatomic, weak) IBOutlet VLBCameraView* cameraView;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;

-(IBAction)onClickClose:(id)sender;
-(IBAction)takePicture:(id)sender;

@end

@implementation TCHUpdateProfileVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

#pragma mark -
#pragma mark Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL isProfileConfigure = [[NSUserDefaults standardUserDefaults] boolForKey:IsProfileConfigure];
    
    if (!isProfileConfigure) { //If profile settings not updated on server
        _closeButton.hidden = YES;
        
        UIViewController *viewController = [[UIViewController alloc] initWithNibName:@"TCHProfileSelection" bundle:[NSBundle mainBundle]];
        TCHProfileSelection *tchProfileSelection = (TCHProfileSelection *)viewController.view;
        [tchProfileSelection loadView];
        [self.view addSubview:tchProfileSelection];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.cameraView startCameraSession];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Action Events

-(void)dismiss {
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]){
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self dismissModalViewControllerAnimated:NO];
#pragma clang diagnostic pop
    }
}

-(IBAction)onClickClose:(id)sender {
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]){
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self dismissModalViewControllerAnimated:YES];
#pragma clang diagnostic pop
    }
}

-(IBAction)onHoldCamera:(id)sender {
    [self.cameraView startShowingPreview];
}

-(void)startCamera {
    [self.cameraView startCameraSession];
}

-(void)openAppPreferences {
    UIViewController *viewController = [[UIViewController alloc] initWithNibName:@"TCHAccountSettings" bundle:[NSBundle mainBundle]];
    TCHAccountSettings *tchAccountSettings = (TCHAccountSettings *)viewController.view;
    tchAccountSettings.fromProfileScreen = YES;
    [tchAccountSettings loadView];
    [self.view addSubview:tchAccountSettings];
}

-(void)saveCaptureImage:(UIImage *)image {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *imagePath = [SelfProfileImageName pathInDocumentDirectory];
    
    if([fileManager fileExistsAtPath:imagePath]) {
        [fileManager removeItemAtPath:imagePath error:nil];
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:imagePath atomically:YES];
}

#pragma mark -
#pragma mark VLBCameraView

-(void)cameraView:(VLBCameraView*)cameraView didFinishTakingPicture:(UIImage *)image withInfo:(NSDictionary*)info meta:(NSDictionary *)meta {
    
    [self saveCaptureImage:image];
    
    if ([_closeButton isHidden]) { // When User profile settings not set
        [self performSelector:@selector(openAppPreferences) withObject:nil afterDelay:1.0];
        
    } else {    // If user profile details already saved then update only profile pic
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [appDelegate showLoading];
            [self submitInfoOnServer];
        });
    }
}

-(void)cameraView:(VLBCameraView *)cameraView didErrorOnTakePicture:(NSError *)error {
    [appDelegate.window makeToast:[error description] backgroundColor:[UIColor redColor]];
}

-(void)cameraView:(VLBCameraView *)cameraView willRekatePicture:(UIImage *)image {
    
}

-(IBAction)takePicture:(id)sender {
    [self.cameraView takePicture];
}

#pragma mark -
#pragma mark Web service call

-(void)submitInfoOnServer {
    NSDictionary *profileDict = [[NSUserDefaults standardUserDefaults] objectForKey:UserProfile];
    
    NSString *lat = [NSString stringWithFormat:@"%0.6f",appDelegate.bestEffortAtLocation.coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%0.6f",appDelegate.bestEffortAtLocation.coordinate.longitude];
    NSString *genderCode = [[[NSUserDefaults standardUserDefaults] objectForKey:TCHGenderCode] isEqualToString:TCHMale] ? @"M" : @"F";
    NSString *interestIn = [profileDict objectForKey:@"interestIn"];
    NSString *uuid = [profileDict objectForKey:@"uuid"];
    
    NSString *imagePath = [SelfProfileImageName pathInDocumentDirectory];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    NSDictionary *parameters = @{@"uuid": uuid,
                                 @"lat": lat,
                                 @"lng" : lng,
                                 @"gender" : genderCode,
                                 @"interestIn" : interestIn,
                                 @"width":[NSString stringWithFormat:@"%i", (int)width ],
                                 @"height":[NSString stringWithFormat:@"%i", (int)height]};
    
    NSString *fileName = [NSString stringWithFormat:@"ID_%@.jpg",[profileDict objectForKey:@"id"]];
    
    AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
    client.responseSerializer = [AFJSONResponseSerializer serializer];
    [client POST:[NSString stringWithFormat:@"%@r/user/profile/edit?",API_HOME] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if(image){
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.5) name:@"pic" fileName:fileName mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[[responseObject objectForKey:@"ack"] lowercaseString] isEqualToString:@"success"]) {
            
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
            [appDelegate.window makeToast:ProfilePicUpdated backgroundColor:GreenColor];
            
        } else {
            [appDelegate.window makeToast:ServerDBError backgroundColor:[UIColor redColor]];
        }
        [appDelegate stopLoading];
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [appDelegate.window makeToast:ServerConnection backgroundColor:[UIColor redColor]];
        [appDelegate stopLoading];
    }];
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
