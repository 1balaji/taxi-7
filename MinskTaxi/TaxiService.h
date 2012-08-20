//
//  TaxiService.h
//  MinskTaxi
//
//  Created by admin on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CalculableTaxiService, Phone, Tarif;

@interface TaxiService : NSManagedObject

@property (nonatomic, retain) NSString * descriptions;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * taxiServiceId;
@property (nonatomic, retain) NSSet *phones;
@property (nonatomic, retain) NSSet *tarifs;
@property (nonatomic, retain) CalculableTaxiService *calculableTaxiService;
@end

@interface TaxiService (CoreDataGeneratedAccessors)

- (void)addPhonesObject:(Phone *)value;
- (void)removePhonesObject:(Phone *)value;
- (void)addPhones:(NSSet *)values;
- (void)removePhones:(NSSet *)values;
- (void)addTarifsObject:(Tarif *)value;
- (void)removeTarifsObject:(Tarif *)value;
- (void)addTarifs:(NSSet *)values;
- (void)removeTarifs:(NSSet *)values;
@end
