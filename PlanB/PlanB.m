//
//  PlanB.m
//  PlanB
//
//  Created by Arpan Ghosh on 12/8/13.
//  Copyright (c) 2013 Plan B. All rights reserved.
//

#import "PlanB.h"
#import "PBCookieHandler.h"
#import "PBRegion.h"


#define PLANB_GENERIC_REGION_UUID @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
#define PLANB_GENERIC_REGION_IDENTIFIER @"PLANB_REGION_IDENTIFIER_GENERIC"

#define PLANB_EVIL_REGION_IDENTIFIER @"PLANB_REGION_IDENTIFIER_EVIL"
#define PLANB_EVIL_REGION_UUID @"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"



@interface PlanB ()

@property (strong, nonatomic) CLLocationManager *beaconManager;
@property (strong, nonatomic) NSMutableDictionary *pbRegionWhitelist;
@property (strong, nonatomic) NSMutableDictionary *pbRegionBlacklist;

@property (strong, nonatomic) PBCookieHandler *pbCookieHandler;

@end


@implementation PlanB


+ (BOOL) deviceSupportsCookieCollection{
    BOOL isRangingAvailable = [CLLocationManager isRangingAvailable];
    NSLog(@"Ranging available on device? : %d", isRangingAvailable);
    BOOL isBeaconMonitoringAvailable
    = [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]];
    NSLog(@"Beacon monitoring available on device? : %d", isBeaconMonitoringAvailable);
    
    return (isBeaconMonitoringAvailable && isRangingAvailable);
}


+ (BOOL) cookieCollectionPossible{
    
    BOOL isBackgroundAppRefreshEnabled =
    ([UIApplication sharedApplication].backgroundRefreshStatus == UIBackgroundRefreshStatusAvailable) ? YES : NO;
    NSLog(@"Background refresh is enabled ? : %d", isBackgroundAppRefreshEnabled);
    // Need 2 modes. A separate one for when 'Background App Refresh' is disabled, which only performs
    // active ranging whenever the app is in the foreground.
    
    return ([PlanB deviceSupportsCookieCollection] && isBackgroundAppRefreshEnabled);
}



+ (instancetype)getPlanBInstance {
    static PlanB *sharedPlanB = nil;
    if ([PlanB cookieCollectionPossible]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedPlanB = [[self alloc] init];
        });
    }
    return sharedPlanB;
}


- (instancetype)init {
    if (self = [super init]) {
        _pbRegionWhitelist = [[NSMutableDictionary alloc] init];
        _pbRegionBlacklist = [[NSMutableDictionary alloc] init];
        _pbCookieHandler = [[PBCookieHandler alloc] initWithBeaconRegionWhiteList:_pbRegionWhitelist];
        _beaconManager = [[CLLocationManager alloc] init];
        _beaconManager.delegate = _pbCookieHandler;
        
        //Does specifying the activity type as 'fitness' instead of the default 'other' make a
        //difference for BLE monitoring and ranging?
        _beaconManager.activityType = CLActivityTypeFitness;
    }
    return self;
}


- (void) CRUDMonitoredBeaconRegions{
    
    NSLog(@"Starting CRUDMonitoredBeaconRegions");
    
    //Fetch region whitelist & blacklist from server & load into pbRegionWhitelist
    //& pbRegionBlacklist (CoreData)
    [self.pbRegionWhitelist setValue:[[PBRegion alloc] initWithUUID:PLANB_GENERIC_REGION_UUID
                                                  andIdentifier:PLANB_GENERIC_REGION_IDENTIFIER]
                            forKey:PLANB_GENERIC_REGION_IDENTIFIER];
    [self.pbRegionBlacklist setValue:[[PBRegion alloc] initWithUUID:PLANB_EVIL_REGION_UUID
                                                  andIdentifier:PLANB_EVIL_REGION_IDENTIFIER]
                            forKey:PLANB_EVIL_REGION_IDENTIFIER];
    
    [self reconcileCurrentlyMonitoredRegionsWithLatestWhitelistAndBlacklist];
    
}


- (void)reconcileCurrentlyMonitoredRegionsWithLatestWhitelistAndBlacklist{
    
    //Fetch list of regions currently being monitored by this app
    NSMutableDictionary* currentlyMonitoredRegions = [[NSMutableDictionary alloc] init];
    for (CLRegion *monitoredregion in self.beaconManager.monitoredRegions){
        [currentlyMonitoredRegions setValue:monitoredregion forKey:monitoredregion.identifier];
    }
    NSLog(@"Currently monitored regions\n%@", [self.beaconManager monitoredRegions]);
    NSLog(@"Currently ranging regions\n%@", [self.beaconManager rangedRegions]);
    
    // Start monitoring any new regions in the whitelist
    for (NSString *whitelistedRegionIdentifier in self.pbRegionWhitelist.allKeys){
        if (![currentlyMonitoredRegions valueForKey:whitelistedRegionIdentifier]){
            NSLog(@"Registering region for monitoring : %@", whitelistedRegionIdentifier);
            CLBeaconRegion *newWhitelistedRegionToMonitor =
            [[self.pbRegionWhitelist valueForKey:whitelistedRegionIdentifier] generateCLBeaconRegion];
            [self.beaconManager startMonitoringForRegion:newWhitelistedRegionToMonitor];
            //[self.beaconManager startRangingBeaconsInRegion:newWhitelistedRegionToMonitor];
        }
    }
    
    // Stop monitoring any regions in the blacklist
    for (NSString *blacklistedRegionIdentifier in self.pbRegionBlacklist.allKeys){
        CLRegion *blacklistedRegion = [currentlyMonitoredRegions
                                       valueForKey:blacklistedRegionIdentifier];
        if (blacklistedRegion){
            NSLog(@"Stopping monitoring of region : %@", blacklistedRegion);
            [self.beaconManager stopMonitoringForRegion:blacklistedRegion];
        }
    }
}

@end
