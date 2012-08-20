//
//  TaxiServicesModelController.h
//  MinskTaxi
//
//  Created by ml on 11/25/11.
//  Copyright (c) 2011 ml. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalculableTaxiService.h"
#import "MLGoogleMapDirections.h"

@interface TaxiServicesModelController : NSObject{
    
@private
    NSManagedObjectContext *_context;
}


@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,readonly,retain, getter = getAllRatesForTrip) NSMutableArray *calculatedTrips;
@property (nonatomic,readonly,retain, getter = getCurrentTrip) CalculableTaxiService *currentTrip; 
@property (nonatomic) NSInteger selectedTaxiIndex; //default - 0; 


- (void) fetchCurrentTaxiRatesFromServer;
- (void) calculateAllTaxiServices:(MLGoogleMapDirections *) direction;
- (void) calculateTaxiServices:(double) distance;

@end
