//
//  Phone.h
//  MinskTaxi
//
//  Created by admin on 11/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TaxiService;

@interface Phone : NSManagedObject

@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) TaxiService *taxiService;

@end
