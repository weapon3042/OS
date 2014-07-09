//
// 	VLBCameraView.m
//  VLBCameraView
//
//  Created by Markos Charatzas on 25/06/2013.
//  Copyright (c) 2013 www.verylargebox.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "VLBCameraView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "VLBMacros.h"
#import "DDLog.h"

typedef void(^VLBCaptureStillImageBlock)(CMSampleBufferRef imageDataSampleBuffer, NSError *error);
typedef void(^VLBCameraViewInit)(VLBCameraView *cameraView);

VLBCameraViewMeta const VLBCameraViewMetaCrop = @"VLBCameraViewMetaCrop";
VLBCameraViewMeta const VLBCameraViewMetaOriginalImage = @"VLBCameraViewMetaOriginalImage";

@interface VLBCameraView ()
@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property(nonatomic, strong) AVCaptureConnection *stillImageConnection;
@property(nonatomic, weak) IBOutlet UIImageView* preview;

- (void)retakePicture:(UITapGestureRecognizer*) tapToRetakeGesture;
@end

VLBCameraViewInit const VLBCameraViewInitBlock = ^(VLBCameraView *cameraView){
    cameraView.session = [AVCaptureSession new];
    [cameraView.session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    cameraView.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:cameraView.session];
	cameraView.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	cameraView.videoPreviewLayer.frame = cameraView.layer.bounds;
    
    cameraView.flashView = [[UIView alloc] initWithFrame:cameraView.preview.bounds];
    cameraView.flashView.backgroundColor = [UIColor whiteColor];
    cameraView.flashView.alpha = 0.0f;
    [cameraView.videoPreviewLayer addSublayer:cameraView.flashView.layer];
};

@implementation VLBCameraView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    VLB_IF_NOT_SELF_RETURN_NIL();
    VLB_LOAD_VIEW()
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    VLB_IF_NOT_SELF_RETURN_NIL();
    VLB_LOAD_VIEW()
    
    
    return self;
}

-(VLBCaptureStillImageBlock) didFinishTakingPicture:(AVCaptureSession*) session preview:(UIImageView*) preview
{
    __weak VLBCameraView *wself = self;
    
    return ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
    {
        [session stopRunning];
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [wself cameraView:wself didErrorOnTakePicture:error];
            });
            
            return;
        }
        
        NSData* imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                                                                    imageDataSampleBuffer,
                                                                    kCMAttachmentMode_ShouldPropagate);
        NSDictionary *info = (__bridge NSDictionary*)attachments;
        
        if(wself.writeToCameraRoll)
        {
            [wself.delegate cameraView:wself willRriteToCameraRollWithMetadata:info];
            
            ALAssetsLibrary *library = [ALAssetsLibrary new];
            [library writeImageDataToSavedPhotosAlbum:imageData
                                             metadata:info
                                      completionBlock:^(NSURL *assetURL, NSError *error) {
                                          NSLog(@"%@", error);
                                      }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           preview.image = image;
                           
                           [wself cameraView:wself didFinishTakingPicture:image withInfo:info meta:nil];
                           
                           CFRelease(attachments);
                       });
    };
}

-(void)awakeFromNib
{
    //    NSError *error = nil;
    //
    //    AVCaptureDevice *device;
    //
    //    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //    for(AVCaptureDevice *someDevice in devices)
    //    {
    //        if([someDevice position] == AVCaptureDevicePositionFront)
    //            device = someDevice;
    //    }
    //
    //    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
    //		NSError *error;
    //		if ([device lockForConfiguration:&error]) {
    //			device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    //			[device unlockForConfiguration];
    //        }
    //    }
    //
    //    if([device isFlashModeSupported:AVCaptureFlashModeAuto]){
    //		if ([device lockForConfiguration:&error]) {
    //            device.flashMode = AVCaptureFlashModeAuto;
    //			[device unlockForConfiguration];
    //        }
    //    }
    //
    //	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    //
    //    if(error){
    //        [NSException raise:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
    //                    format:[error localizedDescription], nil];
    //    }
    //
    //    [self.session addInput:deviceInput];
    //
    //	self.stillImageOutput = [AVCaptureStillImageOutput new];
    //    [self.session addOutput:self.stillImageOutput];
    //
    //	[self.layer addSublayer:self.videoPreviewLayer];
    //
    //    [self.session startRunning];
    //
    //    self.stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    //    [self cameraView:self didCreateCaptureConnection:self.stillImageConnection];
    //    self.hidden = YES;
}

-(void) startCameraSession
{
    VLBCameraViewInitBlock(self);
    
    NSError *error = nil;
    
    AVCaptureDevice *device;
    
    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice *someDevice in devices)
    {
        if([someDevice position] == AVCaptureDevicePositionFront)
            device = someDevice;
    }
    
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
			[device unlockForConfiguration];
        }
    }
    
    if([device isFlashModeSupported:AVCaptureFlashModeAuto]){
		if ([device lockForConfiguration:&error]) {
            device.flashMode = AVCaptureFlashModeAuto;
			[device unlockForConfiguration];
        }
    }
    
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if(error){
        [NSException raise:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
                    format:[error localizedDescription], nil];
    }
	
    [self.session addInput:deviceInput];
	
	self.stillImageOutput = [AVCaptureStillImageOutput new];
    [self.session addOutput:self.stillImageOutput];
    
	[self.layer addSublayer:self.videoPreviewLayer];
    
    if (!self.session.isRunning) {
        [self.session startRunning];
    }
    self.stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [self cameraView:self didCreateCaptureConnection:self.stillImageConnection];
    self.hidden = YES;
    
}

- (void) startShowingPreview
{
    self.hidden = NO;
}

-(void)cameraView:(VLBCameraView*)cameraView didCreateCaptureConnection:(AVCaptureConnection*)captureConnection
{
    captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    if(self.callbackOnDidCreateCaptureConnection){
        [self.delegate cameraView:cameraView didCreateCaptureConnection:captureConnection];
    }
}

-(void)cameraView:(VLBCameraView *)cameraView didFinishTakingPicture:(UIImage *)image withInfo:(NSDictionary *)info meta:(NSDictionary *)meta
{
    //point is in range 0..1
    CGPoint point = [self.videoPreviewLayer captureDevicePointOfInterestForPoint:CGPointZero];
    
    //point is calculated with camera in landscape but crop is in portrait
    CGRect crop = CGRectMake(image.size.height - (image.size.height * (1.0f - point.x)),
                             CGPointZero.y,
                             image.size.width,
                             image.size.height * (1.0f - point.x));
    
//    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], crop);
//    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:image.imageOrientation]; //preserve camera orientation
//    CGImageRelease(imageRef);
        
    [self.delegate cameraView:cameraView
       didFinishTakingPicture:[self fixrotation:image]
                     withInfo:info meta:@{VLBCameraViewMetaCrop:[NSValue valueWithCGRect:crop],
                                          VLBCameraViewMetaOriginalImage:image}];
}

- (UIImage *)fixrotation:(UIImage *)image{
    
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}


-(void)cameraView:(VLBCameraView *)cameraView didErrorOnTakePicture:(NSError *)error{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    [self.delegate cameraView:cameraView didErrorOnTakePicture:error];
}

- (void)takePicture
{
    [UIView animateWithDuration:0.4f
                     animations:^{ self.flashView.alpha = 1.0f; }
                     completion:^(BOOL finished){ self.flashView.alpha = 0.0f; }
     ];
    
    VLBCaptureStillImageBlock didFinishTakingPicture = [self didFinishTakingPicture:self.session
                                                                            preview:self.preview];
    
    // set the appropriate pixel format / image type output setting depending on if we'll need an uncompressed image for
    // the possiblity of drawing the red square over top or if we're just writing a jpeg to the camera roll which is the trival case
    [self.stillImageOutput setOutputSettings:@{AVVideoCodecKey:AVVideoCodecJPEG}];
	[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:self.stillImageConnection
                                                       completionHandler:didFinishTakingPicture];
    
    //test
    if(self.allowPictureRetake){
        UITapGestureRecognizer *tapToRetakeGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(retakePicture:)];
        [self.preview addGestureRecognizer:tapToRetakeGesture];
    }
}

- (void)retakePicture {
    [self.delegate cameraView:self willRetakePicture:self.preview.image];
    
    self.preview.image = nil;
    [self.session startRunning];
}

- (void)retakePicture:(UITapGestureRecognizer*) tapToRetakeGesture
{
    [self retakePicture];
}

@end
