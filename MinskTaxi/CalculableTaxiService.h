//
//  CalculableTaxiService.h
//  MinskTaxi
//
//  Created by admin on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TaxiService;

@interface CalculableTaxiService : NSManagedObject

@property (nonatomic, retain) NSString * pointA;
@property (nonatomic, retain) NSString * pointB;
@property (nonatomic, retain) NSDate * tripDate;
@property (nonatomic, retain) NSNumber * tripDistance;
@property (nonatomic, retain) NSNumber * tripPrice;
@property (nonatomic, retain) NSNumber * tripTime;
@property (nonatomic, retain) NSManagedObject *tripArchive;
@property (nonatomic, retain) TaxiService *taxiService;

@end
