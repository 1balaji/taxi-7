//
//  MLGoogleMapDirections.m
//  MLGoogleAPI_ForwardGeocoder
//
//  Created by ml on 9/24/11.
//  Copyright (c) 2011 ml. All rights reserved.
//

#import "MLGoogleMapDirections.h"

@implementation MLGoogleMapDirections_Step

@synthesize  distance, duration, end_location, start_location, travel_mode, html_instructions,points;

-(void) dealloc{
    
    [super dealloc];
}

-(id) initWithLocations:(CLLocation *)newLocation fromLocation:(CLLocation *) oldLocation{
    
    self = [super init];
    
    if (self){
        start_location = oldLocation.coordinate;
        end_location = newLocation.coordinate;
        self.distance = (int)[newLocation distanceFromLocation:oldLocation];
    }
    
    return self;
}

-(id) initWithDictionary:(NSDictionary *) dictionary{
    
    self = [super init];
    
    if (self){
        
        self.distance = [[[dictionary objectForKey:@"distance"] objectForKey:@"value"] intValue];
        self.duration = [[[dictionary objectForKey:@"duration"] objectForKey:@"value"] intValue];
        end_location.latitude = [[[dictionary objectForKey:@"end_location"] objectForKey:@"lat"] doubleValue];
        end_location.longitude = [[[dictionary objectForKey:@"end_location"] objectForKey:@"lng"] doubleValue];  
        start_location.latitude = [[[dictionary objectForKey:@"start_location"] objectForKey:@"lat"] doubleValue];
        start_location.longitude = [[[dictionary objectForKey:@"start_location"] objectForKey:@"lng"] doubleValue];  
        self.html_instructions =[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"html_instructions"]];
        self.travel_mode =[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"travel_mode"]];
        self.points =  [[dictionary objectForKey:@"polyline"] objectForKey:@"points"];
    }
    
    return self;
}

@end

@implementation MLGoogleMapDirections_Leg

@synthesize  distance, duration, end_address, start_address, end_location, start_location, steps;

-(void) dealloc{
    
    [steps release];
    [super dealloc];

}

-(id) init{
    
    self = [super init];
    
    if (self){
        
        self.end_address =[NSString stringWithFormat:@"end_address"];
        self.start_address =[NSString stringWithFormat:@"start_address"];
        steps = [[NSMutableArray alloc] init];
        
    }
    
    return self;
}


-(id) initWithDictionary:(NSDictionary *) dictionary{
    
    self = [super init];
    
    if (self){
        
        self.distance = [[[dictionary objectForKey:@"distance"] objectForKey:@"value"] intValue];
        self.duration = [[[dictionary objectForKey:@"duration"] objectForKey:@"value"] intValue];
        self.end_address =[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"end_address"]];
        self.start_address =[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"start_address"]];
        end_location.latitude = [[[dictionary objectForKey:@"end_location"] objectForKey:@"lat"] doubleValue];
        end_location.longitude = [[[dictionary objectForKey:@"end_location"] objectForKey:@"lng"] doubleValue];  
        start_location.latitude = [[[dictionary objectForKey:@"start_location"] objectForKey:@"lat"] doubleValue];
        start_location.longitude = [[[dictionary objectForKey:@"start_location"] objectForKey:@"lng"] doubleValue];  

        steps = [[NSMutableArray alloc] init];
        
        for (NSDictionary *step in [dictionary objectForKey:@"steps"]){
            
            MLGoogleMapDirections_Step *newstep = [[MLGoogleMapDirections_Step alloc] initWithDictionary: step];
            [steps addObject:newstep];
            [newstep release];
        }
        
    }
    
    return self;
}

@end


@implementation MLGoogleMapDirections

@synthesize bounds,legs,summary,warnings,waypoint_order;

-(void) dealloc{

    [legs release];
    [super dealloc];
}

-(id) init{
    
    self = [super init];
    
    if (self){
        self.legs =  [[[MLGoogleMapDirections_Leg alloc] init] autorelease];
        self.summary = [NSString stringWithFormat:@"traced route"];
    }
    
    return self;
    
}

-(id) initWithDictionary:(NSDictionary *) dictionary{
    
    self = [super init];
    
    if (self){
        bounds.northeast.latitude = [[[[dictionary objectForKey:@"bounds"] objectForKey:@"northeast"] objectForKey:@"lat"] doubleValue];
        bounds.northeast.longitude =[[[[dictionary objectForKey:@"bounds"] objectForKey:@"northeast"] objectForKey:@"lng"] doubleValue];
        bounds.southwest.latitude = [[[[dictionary objectForKey:@"bounds"] objectForKey:@"southwest"] objectForKey:@"lat"] doubleValue];
        bounds.southwest.longitude =[[[[dictionary objectForKey:@"bounds"] objectForKey:@"southwest"] objectForKey:@"lng"] doubleValue];
        self.legs =  [[[MLGoogleMapDirections_Leg alloc] initWithDictionary:[[dictionary objectForKey:@"legs"] objectAtIndex:0]] autorelease];
        self.summary = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"summary"]];
        self.warnings = [NSArray arrayWithArray:[dictionary objectForKey:@"warnings"]];
        self.waypoint_order = [NSArray arrayWithArray:[dictionary objectForKey:@"waypoint_order"]];
    }
    
    return self;
    
}

-(NSMutableArray *)decodePolyline: (NSString *)encodedPonts {
    NSMutableString  *encoded = [NSMutableString stringWithString:encodedPonts]; 
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[[NSNumber alloc] initWithFloat:lat * 1e-5] autorelease];
		NSNumber *longitude = [[[NSNumber alloc] initWithFloat:lng * 1e-5] autorelease];;
		CLLocation *loc = [[[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]] autorelease];
		[array addObject:loc];
	}
	
	return array;
}

-(MKPolyline*) getPolyline{
    
    NSMutableArray *points = [[[NSMutableArray alloc] init] autorelease];
    
    for (MLGoogleMapDirections_Step *step in legs.steps){
        if (step.points){
            [points addObjectsFromArray:[self decodePolyline:step.points]];
        }
        else{

            [points addObject:[[[CLLocation alloc] initWithLatitude:step.end_location.latitude longitude:step.end_location.longitude] autorelease]];
        }
    }
    CLLocationCoordinate2D coords[[points count]];
    
    for(int i = 0; i < points.count; i++) {
		CLLocation* location = [points objectAtIndex:i];
        coords[i] = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        
	}

    return [MKPolyline polylineWithCoordinates:coords count:[points count]];
}


@end
