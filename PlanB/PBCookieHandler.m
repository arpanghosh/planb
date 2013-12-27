//
//  PBCookieHandler.m
//  PBCookieHandler
//
//  Created by Arpan Ghosh on 12/8/13.
//  Copyright (c) 2013 Plan B. All rights reserved.
//

#import "PBCookieHandler.h"


@interface PBCookieHandler()

@property (weak, nonatomic) NSMutableDictionary *regionWhitelist;

@end


@implementation PBCookieHandler


-(instancetype)initWithBeaconRegionWhiteList:(NSMutableDictionary *)regionWhiteList{
    self = [super init];
    if (self){
        _regionWhitelist = regionWhiteList;
    }
    return self;
}


//Do we need this callback?
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region{
    if ([self isOurRegion:region.identifier]){
        NSLog(@"Started monitoring for our region : %@", region.identifier);
    }
}


-(void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    if ([self isOurRegion:region.identifier]){
        [manager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
        NSLog(@"Entered region %@ and started ranging", region.identifier);
    }
}


-(void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    if ([self isOurRegion:region.identifier]){
        [manager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
        NSLog(@"Exited region %@ and stopped ranging", region.identifier);
    }
}


- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    if ([self isOurRegion:region.identifier]){
        NSLog(@"Did determine state for region %@", region.identifier);
        switch (state) {
            case CLRegionStateInside:
                NSLog(@"Inside");
                break;
            case CLRegionStateOutside:
                NSLog(@"Outside");
                break;
            case CLRegionStateUnknown:
                NSLog(@"Unknown");
                break;
        }
    }
}


- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons
                inRegion:(CLBeaconRegion *)region{
    
    for (CLBeacon *beacon in beacons){
        NSLog(@"\n\n\nBeacon in region : %@\nUUID : %@\nMajor : %@\nMinor : %@\nAccuracy : %f\nRssi : %ld\n\n\n",
              region.identifier,
              beacon.proximityUUID.UUIDString,
              [beacon.major stringValue],
              [beacon.minor stringValue],
              beacon.accuracy,
              (long)beacon.rssi);
        
        switch (beacon.proximity) {
            case CLProximityUnknown:
                NSLog(@"Proximity unknown");
                break;
            case CLProximityFar:
                NSLog(@"Proximity far");
                break;
            case CLProximityNear:
                NSLog(@"Proximity near");
                break;
            case CLProximityImmediate:
                NSLog(@"Proximity Immediate");
                break;
            default:
                break;
        }
    }
}


//Do we need to stop monitoring a region ever?
- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    if ([self isOurRegion:region.identifier]){
        NSLog(@"Error monitoring region %@.\n%@", region.identifier,
              [error localizedDescription]);
        [manager stopMonitoringForRegion:region];
    }
}


//What kind of error results in this callback and do we need to stop ranging because of it?
- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error{
    if ([self isOurRegion:region.identifier]){
        NSLog(@"Error ranging beacon region %@.\n%@", region.identifier,
              [error localizedDescription]);
        [manager stopRangingBeaconsInRegion:region];
    }
}


- (void)locationManager:(CLLocationManager *)manager
    didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status != kCLAuthorizationStatusAuthorized) {
        NSLog(@"User has revoked/not yet granted access to use location services");
        [self stopRangingAllOurRegionsBelongingTo:manager];
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    switch (error.code) {
        case kCLErrorDenied: //Access to the location service was denied by the user.
        case kCLErrorRegionMonitoringDenied: //Access to the region monitoring service was denied by the user.
        case kCLErrorRangingUnavailable: //Airplane mode or if Bluetooth or location services are disabled
            NSLog(@"Error code : %ld\nError : %@", (long)error.code, [error localizedDescription]);
            //Keep monitoring the Beacon regions, but stop the ranging if it is occurring.
            [self stopRangingAllOurRegionsBelongingTo:manager];
            break;
       
        case kCLErrorRangingFailure: //A general ranging error occurred.
            NSLog(@"Error code : %ld\nError : %@", (long)error.code, [error localizedDescription]);
            //Keep monitoring the Beacon regions, but stop the ranging if it is occurring.
            [self stopRangingAllOurRegionsBelongingTo:manager];
            break;
            
        //Non-permission-revocation or non-capability-disablement related errors.
        case kCLErrorRegionMonitoringFailure: //app has exceeded the maximum number of regions that it can monitor simultaneously.
        case kCLErrorRegionMonitoringSetupDelayed: //Core Location could not initialize the region monitoring feature immediately.
        case kCLErrorRegionMonitoringResponseDelayed: //Core Location will deliver events but they may be delayed
        default:
            NSLog(@"Error code : %ld\nError : %@", (long)error.code, [error localizedDescription]);
            break;
    }
}


-(BOOL)isOurRegion:(NSString *)regionIdentifier{
    return ([self.regionWhitelist valueForKey:regionIdentifier] != nil);
}


-(void)stopRangingAllOurRegionsBelongingTo: (CLLocationManager *)manager{
    for (CLBeaconRegion *beaconRegion in [manager rangedRegions]){
        if ([self isOurRegion:beaconRegion.identifier]){
            [manager stopRangingBeaconsInRegion:beaconRegion];
        }
    }
}


-(void)stopMonitoringAllOurRegionsBelongingTo: (CLLocationManager *)manager{
    for (CLBeaconRegion *region in [manager monitoredRegions]){
        if ([self isOurRegion:region.identifier]){
            [manager stopMonitoringForRegion:region];
        }
    }
}

@end



