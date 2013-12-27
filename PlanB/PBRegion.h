//
//  PBRegion.h
//  PBRegion
//
//  Created by Arpan Ghosh on 12/8/13.
//  Copyright (c) 2013 Plan B. All rights reserved.
//


typedef enum {
    BeaconBasedRegionTypeUndefined = 0,
    BeaconBasedRegionTypePlanB,
    BeaconBasedRegionTypeOrganization,
    BeaconBasedRegionTypeIndividual
} BeaconBasedRegionType;


@interface PBRegion : NSObject

@property (nonatomic, strong, readonly) NSUUID *UUID;
@property (nonatomic, readonly) UInt16 major;
@property (nonatomic, readonly) UInt16 minor;
@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, readonly) BeaconBasedRegionType type;


//Designated initializer
-(instancetype)initWithUUID:(NSString *)UUID andIdentifier:(NSString *)identifier;
-(instancetype)initWithUUID:(NSString *)UUID andMajor:(UInt16)major andIdentifier:(NSString *)identifier;
-(instancetype)initWithUUID:(NSString *)UUID andMajor:(UInt16)major andMinor:(UInt16)minor andIdentifier:(NSString *)identifier;

-(CLBeaconRegion *)generateCLBeaconRegion;

@end
