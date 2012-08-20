//
//  Tarif.h
//  MinskTaxi
//
//  Created by admin on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TaxiService;

@interface Tarif : NSManagedObject

@property (nonatomic, retain) NSNumber * bookingKmIncluded;
@property (nonatomic, retain) NSNumber * bookingRate;
@property (nonatomic, retain) NSString * descriptions;
@property (nonatomic, retain) NSNumber * kmRate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * timevalid;
@property (nonatomic, retain) TaxiService *taxiService;

@end
