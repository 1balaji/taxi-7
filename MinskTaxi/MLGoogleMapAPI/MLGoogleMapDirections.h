//
//  MLGoogleMapDirections.h
//  MLGoogleAPI_ForwardGeocoder
//
//  Created by ml on 9/24/11.
//  Copyright (c) 2011 ml. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLGoogleMapGeocoding.h"
#import <MapKit/MapKit.h>

@interface MLGoogleMapDirections_Step : NSObject

    @property (nonatomic) NSInteger distance;
    @property (nonatomic) NSInteger duration;
    @property (nonatomic) CLLocationCoordinate2D end_location;
    @property (nonatomic) CLLocationCoordinate2D start_location;
    @property (nonatomic, retain) NSString *html_instructions;
    @property (nonatomic, retain) NSString *travel_mode;
    @property (nonatomic, retain) NSString *points;

    -(id) initWithDictionary:(NSDictionary *) dictionary;
    -(id) initWithLocations:(CLLocation *)newLocation fromLocation:(CLLocation *) oldLocation;


@end

@interface MLGoogleMapDirections_Leg : NSObject

    @property (nonatomic) NSInteger distance;
    @property (nonatomic) NSInteger duration;
    @property (nonatomic, retain) NSString *end_address;
    @property (nonatomic, retain) NSString *start_address;
    @property (nonatomic) CLLocationCoordinate2D end_location;
    @property (nonatomic) CLLocationCoordinate2D start_location;
    @property (nonatomic, retain)  NSMutableArray *steps;

    -(id) initWithDictionary:(NSDictionary *) dictionary;

@end

@interface MLGoogleMapDirections : NSObject

    @property (nonatomic) MLGoogleLocationCoordinateRegion  bounds;
    @property (nonatomic, retain) MLGoogleMapDirections_Leg *legs;
    @property (nonatomic, retain) NSString *summary;
    @property (nonatomic, retain) NSArray  *warnings;
    @property (nonatomic, retain) NSArray  *waypoint_order;

    -(id) initWithDictionary:(NSDictionary *) dictionary;

    -(NSMutableArray *)decodePolyline: (NSString *)encodedPonts;
    -(MKPolyline*) getPolyline;


@end
