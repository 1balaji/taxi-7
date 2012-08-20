//
//  TaxiServicesModelController.m
//  MinskTaxi
//
//  Created by ml on 11/25/11.
//  Copyright (c) 2011 ml. All rights reserved.
//

#import "TaxiServicesModelController.h"
#import "AppDelegate.h"
#import "TaxiService.h"
#import "Lidenbrock.h"
#import "Tarif.h"


@interface TaxiServicesModelController (private)

- (void)_removeOldCalculatedTrips;


@end


@implementation TaxiServicesModelController

@synthesize managedObjectContext, currentTrip, selectedTaxiIndex, calculatedTrips;

-(id) init {
    
    self = [super init];
    if (self){
        selectedTaxiIndex = 0;
        
        NSURL *storeURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"MinskTaxi.sqlite"];

        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MinskTaxi" withExtension:@"momd"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil];
        _context = [[NSManagedObjectContext alloc] init];
        [_context setPersistentStoreCoordinator:coordinator];
        [managedObjectModel release];
        [coordinator release];
    }
    
    return self;
}


- (void)fetchCurrentTaxiRatesFromServer{
    
    dispatch_queue_t queue = dispatch_queue_create("com.ml.fetchDataFromServer", 0);

    dispatch_async(queue, ^{
      NSString *jsonUrl = [NSString stringWithFormat: @"http://192.168.1.35:8080/TaxiService/rest/services"];
//      NSString *jsonUrl = [NSString stringWithFormat: @"http://localhost:8080/TaxiService/rest/services"];
//        NSString *jsonUrl = [NSString stringWithFormat: @"http://192.168.1.44:8080/TaxiService/rest/services"];

        
        NSURL *url = [[[NSURL alloc] initWithString:[jsonUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] autorelease];
        
        //todo: catch errors
        NSError *_error = [[[NSError alloc] init] autorelease];  
        NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&_error];
        
        if (jsonString){
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"TaxiService" inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entityDescription];
            
            NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&_error];
            [fetchRequest release];
            
            
            for (NSManagedObject *managedObject in items) {
                [managedObjectContext deleteObject:managedObject];
               // NSLog(@"%@ object deleted",entityDescription);
            }
            
        [TaxiService entitiesFromJson: jsonString];
        
        if (![managedObjectContext save:&_error]) {  
            NSLog(@"Unresolved error %@, %@", _error, [_error userInfo]);
        }  
        
        }

    });

    dispatch_release(queue);
}

- (CalculableTaxiService *) getCurrentTrip{
    
    if (selectedTaxiIndex <= ([calculatedTrips count] - 1)) {
        return [calculatedTrips objectAtIndex:selectedTaxiIndex];
    }
    
    return nil;
}

- (void) calculateTaxiServices:(double) distance{
    
    [self _removeOldCalculatedTrips];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"TaxiService" inManagedObjectContext:_context];
    [fetchRequest setEntity:entityDescription];
    
    NSError *_error = [[[NSError alloc] init] autorelease];  
    NSArray *taxiServices = [_context executeFetchRequest:fetchRequest error:&_error];
    [fetchRequest release];
    
    for (TaxiService *taxi in taxiServices){
        CalculableTaxiService *calculatedTrip = [NSEntityDescription insertNewObjectForEntityForName:@"CalculableTaxiService" inManagedObjectContext:_context];
        calculatedTrip.taxiService = [taxi retain];
        calculatedTrip.tripDistance = [NSNumber numberWithFloat:(distance / 1000.00)];
        Tarif *tarif = [calculatedTrip.taxiService.tarifs anyObject];
        
        //to remove:
        tarif.bookingKmIncluded = [NSNumber numberWithFloat:3.0];
        //
        
        if ( [calculatedTrip.tripDistance floatValue] > [tarif.bookingKmIncluded floatValue])
            calculatedTrip.tripPrice = [NSNumber numberWithFloat:([tarif.bookingRate floatValue] + ([calculatedTrip.tripDistance floatValue] - [tarif.bookingKmIncluded floatValue])*[tarif.kmRate floatValue])];
        else
            calculatedTrip.tripPrice = tarif.bookingRate;
    }
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CalculableTaxiService" inManagedObjectContext:_context];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tripPrice" ascending:YES];
    [fetch setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetch setEntity:entity];
    
    NSArray *calculableTaxiService = [_context executeFetchRequest:fetch error:&_error];
    
    [calculatedTrips release];
    calculatedTrips = [[NSMutableArray alloc] init];
    [calculatedTrips addObjectsFromArray:calculableTaxiService];
    
    [sortDescriptor release];
    [fetch release];
    
}


- (void) calculateAllTaxiServices:(MLGoogleMapDirections *) direction{

    [self calculateTaxiServices:direction.legs.distance];
    
}

- (void)_removeOldCalculatedTrips{
   
    NSError *_error = [[[NSError alloc] init] autorelease];  
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CalculableTaxiService" inManagedObjectContext:_context];
    [fetch setEntity:entity];
    NSArray *calculableTaxiServices = [_context executeFetchRequest:fetch error:&_error];
    for (CalculableTaxiService *trip in calculableTaxiServices){
        [_context deleteObject:trip];
    }
    [fetch release];
    
}

-(void) dealloc{
    [currentTrip release];
    [calculatedTrips release];
    [managedObjectContext release];
    [super dealloc];
    
}

@end
