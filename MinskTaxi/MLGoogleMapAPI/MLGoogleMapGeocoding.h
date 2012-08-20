//
//  MLGoogleMapGeocoding.h
//  MLGoogleAPI_ForwardGeocoder
//
//  Created by ml on 9/24/11.
//  Copyright (c) 2011 ml. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef struct { 
	CLLocationCoordinate2D northeast;
	CLLocationCoordinate2D southwest;
} MLGoogleLocationCoordinateRegion;


//
@interface MLGoogle_Geometry : NSObject
    
    @property (nonatomic) MLGoogleLocationCoordinateRegion bounds;
    @property (nonatomic) CLLocationCoordinate2D location;
    @property (nonatomic) MLGoogleLocationCoordinateRegion viewport;
    @property (nonatomic, retain) NSString *location_type;

    -(id) initWithDictionary:(NSDictionary *) dictionary;

@end

//
@interface MLGoogleMap_address_components : NSObject

    @property (nonatomic, retain) NSString *long_name;
    @property (nonatomic, retain) NSString *short_name;
    @property (nonatomic, retain) NSArray  *types;

    -(id) initWithDictionary:(NSDictionary *) dictionary;
    
@end

// Main class for key "result"
@interface MLGoogleMapGeocoding : NSObject 
    
    @property (nonatomic, retain) NSMutableArray    *address_components;
    @property (nonatomic, retain) NSString          *formatted_address;
    @property (nonatomic, retain) MLGoogle_Geometry *geometry;
    @property (nonatomic) BOOL                      partial_match;
    @property (nonatomic, retain) NSArray           *types;
    @property (nonatomic) NSInteger                 type;// 0 - default. Any Point; 1 - current location; ...


    -(id) initWithDictionary:(NSDictionary *) dictionary;

    -(MLGoogleMap_address_components *)getAddressOfType:(NSString *) addressType;
    -(MLGoogleMap_address_components *)getRoute;
    -(MLGoogleMap_address_components *)getStreet;
    -(NSString *)description;

@end
