//
//  TCHAppDelegate.m
//  Ties-CH
//
//  Created by  on 6/3/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import "TCHAppDelegate.h"

@implementation TCHAppDelegate
@synthesize window;
@synthesize navigationController;

@synthesize tchCurrentLocationHelper;
@synthesize bestEffortAtLocation;

@synthesize numOfUnreadMessages;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    appDelegate.numOfUnreadMessages = @"0";
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]!=nil) {
        NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
        if (badge > 0) {
            badge--;
            [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
        }
    }
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    
    [self startUpdatingLocation];
    
    return YES;
}

-(void)startUpdatingLocation {
    if (!self.tchCurrentLocationHelper) {
        
        self.tchCurrentLocationHelper = [[TCHCurrentLocationHelper alloc] init:^(CLLocation *currentLocation) {
            self.bestEffortAtLocation = currentLocation;
        } failure:^(NSString *strCurrentLocationError) {
            
        }];
    }
}

#pragma mark -
#pragma mark System methods

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:DeviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:DeviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}

#pragma mark -
#pragma mark Custom Methods

-(NSString *)codeForGender:(NSInteger)code {
    if (code == 1) {
        return TCHIntInMale;
    } else if (code == 2) {
        return TCHIntInFemale;
    } 
    return @"";
}

- (NSString *) distanceFromTargetLocation: (CLLocation *) location {
    CGFloat distance = [location distanceFromLocation:self.bestEffortAtLocation] / 1000;

    NSString *appender = @" mile";

    NSString *disStr = [NSString stringWithFormat:@"%0.1f",distance];
    disStr = [disStr stringByReplacingOccurrencesOfString:@".0" withString:@""];
    if ([disStr intValue] <= 0.0) {
        disStr = @"0.1";
    }
    if ([disStr intValue] > 1.0) {
        appender = [appender stringByAppendingString:@"s"];
    }
    return [disStr stringByAppendingString:appender];
}

-(NSString *)dateTimeDifference:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm MM/dd/yyyy"];
    
    NSDate *startDate = [dateFormatter dateFromString:dateString];
    NSDate *endDate = [NSDate date];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    
    NSUInteger unitFlags = NSMonthCalendarUnit | kCFCalendarUnitWeek | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags
                                                fromDate:startDate
                                                  toDate:endDate options:0];
    
    NSInteger number = 0;
    NSString *text = @"";
    NSInteger month = [components month];
    number = month;
    if (month == 0) {
        NSInteger week = [components week];
        number = week;
        if (week == 0) {
            NSInteger day = [components day];
            number = day;
            if (day == 0) {
                NSInteger hour = [components hour];
                number = hour;
                if (hour == 0) {
                    NSInteger minute = [components minute];
                    number = minute;
                    if (minute == 0) {
                        NSInteger second = [components second];
                        number = second;
                        if (second == 0) {
                            return @"just now";
                        } else {
                            text = @"seconds";
                        }
                    } else {
                        text = @"minutes";
                    }
                } else {
                    text = @"hours";
                }
            } else {
                if (day == 1) {
                    return @"Yesterday";
                }
                text = @"days";
            }
        } else {
            text = @"weeks";
        }
    } else {
        text = @"months";
    }
    return [NSString stringWithFormat:@"%d %@ ago",number,text];
}


//utc to local
-(NSString *)convertDateTimeFromTimeFormat:(NSString *)fromDateTimeFormat toDateTimeFormat:(NSString *)toDateTimeFormat forDateTime:(NSString *)forDateTime {
    
    NSDateFormatter *dateFromatter = [[NSDateFormatter alloc] init];
    
    [dateFromatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    [dateFromatter setDateFormat:fromDateTimeFormat];
    
    NSDate *date = [dateFromatter dateFromString:forDateTime];
    
    [dateFromatter setDateFormat:toDateTimeFormat];
    
    [dateFromatter setTimeZone:[NSTimeZone localTimeZone]];
    
    if (date) {
        
        return [dateFromatter stringFromDate:date];
        
    }
    
    return @"";
    
}


//local to utc
-(NSString *)convertWithUTCDateTimeFromTimeFormat:(NSString *)fromDateTimeFormat toDateTimeFormat:(NSString *)toDateTimeFormat forDateTime:(NSString *)forDateTime {
    
    NSDateFormatter *dateFromatter = [[NSDateFormatter alloc] init];
    
    [dateFromatter setDateFormat:fromDateTimeFormat];
    
    [dateFromatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDate *date = [dateFromatter dateFromString:forDateTime];
    
    [dateFromatter setDateFormat:toDateTimeFormat];
    
    [dateFromatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    if (date) {
        
        return [dateFromatter stringFromDate:date];
        
    }
    
    return @"";
    
}

#pragma mark -
#pragma mark ProgressView

-(BOOL)isLoading {
    if (process)
        return YES;
    else
        return NO;
}

-(void)showLoading {
    if (process)
        return;
    process = [[NSLoading alloc] initWithFrame:self.window.bounds];
    [process showInView:self.window];
}

-(void)stopLoading {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (process) {
		[process hide];
		process= nil;
	}
}

#pragma mark -
#pragma mark Image Editing

- (UIImage *)previewImage:(UIImage *)sourceImage {
    UIImage *_previewImage = nil;
    
    if(_previewImage == nil && sourceImage != nil) {
        if(sourceImage.size.height > 100 || sourceImage.size.width > 100) {
            CGFloat aspect = sourceImage.size.height/sourceImage.size.width;
            CGSize size;
            if(aspect >= 1.0) { //square or portrait
                size = CGSizeMake(100/aspect,100);
            } else { // landscape
                size = CGSizeMake(100,100/aspect);
            }
            _previewImage = [self scaledImage:sourceImage toSize:size withQuality:kCGInterpolationLow];
        } else {
            _previewImage = sourceImage;
        }
    }
    return  _previewImage;
}


- (UIImage *)scaledImage:(UIImage *)source toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality {
    
    CGImageRef cgImage  = [self newScaledImage:source.CGImage withOrientation:source.imageOrientation toSize:size withQuality:quality];
    UIImage * result = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return result;
}


- (CGImageRef)newScaledImage:(CGImageRef)source withOrientation:(UIImageOrientation)orientation toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality {
    
    CGSize srcSize = size;
    CGFloat rotation = 0.0;
    
    switch(orientation)
    {
        case UIImageOrientationUp: {
            rotation = 0;
        } break;
        case UIImageOrientationDown: {
            rotation = M_PI;
        } break;
        case UIImageOrientationLeft:{
            rotation = M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        case UIImageOrientationRight: {
            rotation = -M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        default:
            break;
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size.width,
                                                 size.height,
                                                 8, //CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 kCGImageAlphaNoneSkipFirst//CGImageGetBitmapInfo(source)
                                                 );
    
    CGContextSetInterpolationQuality(context, quality);
    CGContextTranslateCTM(context,  size.width/2,  size.height/2);
    CGContextRotateCTM(context,rotation);
    
    CGContextDrawImage(context, CGRectMake(-srcSize.width/2 ,
                                           -srcSize.height/2,
                                           srcSize.width,
                                           srcSize.height),
                       source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return resultRef;
}

#pragma mark -
#pragma mark System Methods

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    [UIApplication sharedApplication].applicationIconBadgeNumber = [appDelegate.numOfUnreadMessages intValue];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

@end
