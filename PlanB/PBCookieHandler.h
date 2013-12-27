//
//  PBCookieHandler.h
//  PBCookieHandler
//
//  Created by Arpan Ghosh on 12/8/13.
//  Copyright (c) 2013 Plan B. All rights reserved.
//


#import "PBCookieMonster.h"
#import "PBRegion.h"

@interface PBCookieHandler : NSObject <CLLocationManagerDelegate>

-(instancetype)initWithBeaconRegionWhiteList:(NSMutableDictionary *)regionWhiteList;

@end
