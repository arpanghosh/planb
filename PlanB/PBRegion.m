//
//  PBRegion.m
//  PBRegion
//
//  Created by Arpan Ghosh on 12/8/13.
//  Copyright (c) 2013 Plan B. All rights reserved.
//

#import "PBRegion.h"

#define VALUE_NOT_SPECIFIED -1


@implementation PBRegion


-(instancetype)init{
    self = [super init];
    if (self){
        _major = VALUE_NOT_SPECIFIED;
        _minor = VALUE_NOT_SPECIFIED;
        _type = BeaconBasedRegionTypeUndefined;
    }
    return self;
}


-(instancetype)initWithUUID:(NSString *)UUID andIdentifier:(NSString *)identifier{
    self = [self init];
    if (self) {
        _UUID = [[NSUUID alloc] initWithUUIDString:UUID];
        _type = BeaconBasedRegionTypePlanB;
        _identifier = identifier;
    }
    return self;
}


-(instancetype)initWithUUID:(NSString *)UUID andMajor:(UInt16)major
    andIdentifier:(NSString *)identifier{
    self = [self init];
    if (self) {
        _UUID = [[NSUUID alloc] initWithUUIDString:UUID];
        _major = major;
        _type = BeaconBasedRegionTypeOrganization;
        _identifier = identifier;
    }
    return self;
}


-(instancetype)initWithUUID:(NSString *)UUID andMajor:(UInt16)major
         andMinor:(UInt16)minor andIdentifier:(NSString *)identifier{
    self = [self init];
    if (self) {
        _UUID = [[NSUUID alloc] initWithUUIDString:UUID];
        _major = major;
        _minor = minor;
        _type = BeaconBasedRegionTypeIndividual;
        _identifier = identifier;
    }
    return self;
}


-(CLBeaconRegion *)generateCLBeaconRegion{
    CLBeaconRegion *newRegion;
    switch (self.type) {
        case BeaconBasedRegionTypePlanB:
            newRegion = [[CLBeaconRegion alloc]
                         initWithProximityUUID:self.UUID
                         identifier:self.identifier];
            newRegion.notifyEntryStateOnDisplay = YES;
            break;
        case BeaconBasedRegionTypeOrganization:
            newRegion = [[CLBeaconRegion alloc]
                         initWithProximityUUID:self.UUID
                         major:self.major
                         identifier:self.identifier];
            newRegion.notifyEntryStateOnDisplay = YES;
            break;
        case BeaconBasedRegionTypeIndividual:
            newRegion = [[CLBeaconRegion alloc]
                         initWithProximityUUID:self.UUID
                         major:self.major
                         minor:self.minor
                         identifier:self.identifier];
            newRegion.notifyEntryStateOnDisplay = YES;
            break;
        default:
            break;
    }
    return newRegion;
}

@end
