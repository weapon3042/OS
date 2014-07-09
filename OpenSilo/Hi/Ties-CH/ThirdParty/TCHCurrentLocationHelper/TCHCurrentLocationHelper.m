//
//  TCHCurrentLocationHelper.m
//  Ties-CH
//
//  Created by  on 6/5/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import "TCHCurrentLocationHelper.h"

@interface TCHCurrentLocationHelper ()
@property (nonatomic, strong) CurrentLocationCallBack callbackBlock;
@property (nonatomic, strong) CurrentLocationError callbackError;
@end


@implementation TCHCurrentLocationHelper

- (id)init:(CurrentLocationCallBack)callbackBlock failure:(CurrentLocationError)error{
    
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [self.locationManager startUpdatingLocation];
        self.callbackBlock = callbackBlock;
        self.callbackError = error;
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    // test the measurement to see if it is more accurate than the previous measurement
    if (self.bestEffortAtLocation == nil || self.bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        
        self.bestEffortAtLocation = newLocation;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:nil];
        }
    }
    self.callbackBlock(self.bestEffortAtLocation);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    }
}

- (void)stopUpdatingLocation:(NSString *)state {
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.callbackError(state);
}

@end

