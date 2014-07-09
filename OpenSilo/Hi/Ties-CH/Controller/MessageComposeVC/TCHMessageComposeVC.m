//
//  TCHMessageComposeVC.m
//  Ties-CH
//
//  Created by  on 6/3/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import "TCHMessageComposeVC.h"
#import "VLBCameraView.h"

@interface TCHMessageComposeVC () <UITextViewDelegate, VLBCameraViewDelegate>

@property (nonatomic, weak) IBOutlet VLBCameraView* cameraView;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UILabel *textViewPlaceHolder;

-(IBAction)onClickClose:(id)sender;
-(IBAction)takePicture:(id)sender;


@end

@implementation TCHMessageComposeVC

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
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.cameraView startCameraSession];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(IBAction)onHoldCamera:(id)sender {
    if (_textView.text.length == 0) {
        [appDelegate.window makeToast:@"Please Type Message" backgroundColor:[UIColor redColor]];
    } else {
        [self.cameraView startShowingPreview];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark UITextView delegate 

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *value = @"";
    if ([text isEqualToString:@""]) {
        if (textView.text.length > 0) {
            value = [textView.text substringToIndex:textView.text.length - 1];
        }
    } else if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
        
    } else {
        value = [textView.text stringByAppendingString:text];
    }
    
    if ([value isEqualToString:@""]) {
        _textViewPlaceHolder.hidden = NO;
    } else {
        _textViewPlaceHolder.hidden = YES;
    }
    
    return YES;
}

#pragma mark -
#pragma mark Action Events

-(IBAction)onClickClose:(id)sender {
    [self dismiss];
}

-(IBAction)takePicture:(id)sender {
    [self.view endEditing:YES];
    if (_textView.text.length > 0) {
        [self.cameraView takePicture];
    }
}

-(void)dismiss {
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]){
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self dismissModalViewControllerAnimated:YES];
#pragma clang diagnostic pop
    }
}

#pragma mark -
#pragma mark VLBCameraView

-(void)cameraView:(VLBCameraView*)cameraView didFinishTakingPicture:(UIImage *)image withInfo:(NSDictionary*)info meta:(NSDictionary *)meta {
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //[appDelegate showLoading];
        
        if (_isReplyMode) {
            [self replyMessageWithImage:image];
        } else {
            [self sendMessageWithImage:image];
        }
    });
}

-(void)cameraView:(VLBCameraView *)cameraView didErrorOnTakePicture:(NSError *)error {
    //[appDelegate.window makeToast:[error description] backgroundColor:[UIColor redColor]];
}

-(void)cameraView:(VLBCameraView *)cameraView willRekatePicture:(UIImage *)image {
    
}

#pragma mark -
#pragma mark Web service call

-(void)sendMessageWithImage:(UIImage *)image {
    
    NSDictionary *profileDict = [[NSUserDefaults standardUserDefaults] objectForKey:UserProfile];
    NSString *uuid = [profileDict objectForKey:@"uuid"];
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    NSDictionary *parameters = @{
                                 @"uuid" : uuid,
                                 @"receiver" : _receiver,
                                 @"content": _textView.text.length > 0 ? _textView.text : @"",
                                 @"width":[NSString stringWithFormat:@"%i", (int)width],
                                 @"height":[NSString stringWithFormat:@"%i", (int)height]
                                 };
    
    NSString *fileName = [NSString stringWithFormat:@"ID_%@.jpg",[profileDict objectForKey:@"id"]];
    
    AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
    client.responseSerializer = [AFJSONResponseSerializer serializer];
    [client POST:[NSString stringWithFormat:@"%@r/message/send?",API_HOME] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if(image){
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.5) name:@"pic" fileName:fileName mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[[responseObject objectForKey:@"ack"] lowercaseString] isEqualToString:@"success"]) {
            
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
            [appDelegate.window makeToast:MessageSentSuccessfully backgroundColor:GreenColor];
            
        } else {
                        
            [appDelegate.window makeToast:ServerDBError backgroundColor:[UIColor redColor]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [appDelegate.window makeToast:ServerConnection backgroundColor:[UIColor redColor]];
        [appDelegate stopLoading];
    }];
    
//    [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
}

-(void)replyMessageWithImage:(UIImage *)image {
    NSDictionary *profileDict = [[NSUserDefaults standardUserDefaults] objectForKey:UserProfile];
    NSString *uuid = [profileDict objectForKey:@"uuid"];
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    NSDictionary *parameters = @{
                                 @"uuid" : uuid,
                                 @"messageId" : _messageId,
                                 @"content": _textView.text.length > 0 ? _textView.text : @"",
                                 @"width":[NSString stringWithFormat:@"%i", (int)width],
                                 @"height":[NSString stringWithFormat:@"%i", (int)height]
                                 };
    
   NSString *fileName = [NSString stringWithFormat:@"ID_%@.jpg",[profileDict objectForKey:@"id"]];
    
    AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
    client.responseSerializer = [AFJSONResponseSerializer serializer];
    [client POST:[NSString stringWithFormat:@"%@r/message/reply?",API_HOME] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if(image){
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.5) name:@"pic" fileName:fileName mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
//        if ([[[responseObject objectForKey:@"ack"] lowercaseString] isEqualToString:@"success"]) {
//            
//            [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
//            [appDelegate.window makeToast:MessageSentSuccessfully backgroundColor:GreenColor];
//            
//        } else {
//            
//            [appDelegate.window makeToast:ServerDBError backgroundColor:[UIColor redColor]];
//        }
//        [appDelegate stopLoading];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [appDelegate.window makeToast:ServerConnection backgroundColor:[UIColor redColor]];
//        [appDelegate stopLoading];
    }];
    
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
