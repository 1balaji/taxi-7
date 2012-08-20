//
//  MLGoogleMapGeocoding.m
//  MLGoogleAPI_ForwardGeocoder
//
//  Created by ml on 9/24/11.
//  Copyright (c) 2011 ml. All rights reserved.
//

#import "MLGoogleMapGeocoding.h"

@implementation MLGoogleMap_address_components

@synthesize long_name, short_name, types;


-(void)dealloc
{
	[long_name release];
	[short_name release];
	[types release];
	[super dealloc];
}

-(id) initWithDictionary:(NSDictionary *) dictionary{
    self = [super init];
    
    if(self){
    	long_name  = [[NSString alloc] initWithFormat:@"%@",[dictionary objectForKey:@"long_name"]];
        short_name = [[NSString alloc] initWithFormat:@"%@",[dictionary objectForKey:@"short_name"]];
        types      = [[NSArray alloc] initWithArray:[dictionary objectForKey:@"types"]];
    }
    
    return self;
}


@end

@implementation MLGoogle_Geometry

@synthesize bounds, location, viewport, location_type;

-(void)dealloc
{
	[location_type release];
	[super dealloc];
}

-(id) initWithDictionary:(NSDictionary *) dictionary{
    
    self = [super init];
    
    if(self){
        bounds.northeast.latitude = [[[[dictionary objectForKey:@"bounds"] objectForKey:@"northeast"] objectForKey:@"lat"] doubleValue];
        bounds.northeast.longitude =[[[[dictionary objectForKey:@"bounds"] objectForKey:@"northeast"] objectForKey:@"lng"] doubleValue];
        bounds.southwest.latitude = [[[[dictionary objectForKey:@"bounds"] objectForKey:@"southwest"] objectForKey:@"lat"] doubleValue];
        bounds.southwest.longitude =[[[[dictionary objectForKey:@"bounds"] objectForKey:@"southwest"] objectForKey:@"lng"] doubleValue];
        
        location.latitude = [[[dictionary objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
        location.longitude = [[[dictionary objectForKey:@"location"] objectForKey:@"lng"] doubleValue];  
        
        viewport.northeast.latitude=[[[[dictionary objectForKey:@"bounds"] objectForKey:@"northeast"] objectForKey:@"lat"] doubleValue];
        viewport.northeast.longitude = [[[[dictionary objectForKey:@"bounds"] objectForKey:@"northeast"] objectForKey:@"lng"] doubleValue];
        viewport.southwest.latitude = [[[[dictionary objectForKey:@"bounds"] objectForKey:@"southwest"] objectForKey:@"lat"] doubleValue];
        viewport.southwest.longitude = [[[[dictionary objectForKey:@"bounds"] objectForKey:@"southwest"] objectForKey:@"lng"] doubleValue];
        
        self.location_type = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"location_type"]];
    }
    
    return self;
}

@end

@implementation MLGoogleMapGeocoding


@synthesize address_components, formatted_address, geometry, partial_match, types, type;

-(void)dealloc
{
    [address_components release];
	[formatted_address release];
	[geometry release];
    [types release];
	[super dealloc];
}

-(id) init{
    
    self = [super init];

    if (self){
        
        address_components = [[NSMutableArray alloc] init];
        types = [[NSArray alloc] init];
        geometry =  [[MLGoogle_Geometry alloc] init];

    }
    
    return self;
}


-(id) initWithDictionary:(NSDictionary *) dictionary{
    
    self = [super init];
    
    if(self){
        
        formatted_address = [[NSString alloc] initWithFormat:@"%@",[dictionary objectForKey:@"formatted_address"]];
        partial_match = [dictionary objectForKey:@"partial_match"] ? YES: NO;
        
        address_components = [[NSMutableArray alloc] init];
        
        for (NSDictionary *addressDictionary in [dictionary objectForKey:@"address_components"]){
            MLGoogleMap_address_components *address = [[MLGoogleMap_address_components alloc] initWithDictionary: addressDictionary];
            [address_components addObject:address];
            [address release];
        }
        
        types = [[NSArray alloc] initWithArray:[dictionary objectForKey:@"types"]];
        geometry =  [[MLGoogle_Geometry alloc] initWithDictionary:[dictionary objectForKey:@"geometry"]];
    }
    return self;
    
}
-(MLGoogleMap_address_components *)getAddressOfType:(NSString *) addressType{
    
    MLGoogleMap_address_components *return_address_component = [[[MLGoogleMap_address_components alloc] init] autorelease];
    
    for (MLGoogleMap_address_components *address in address_components){
        if ([addressType isEqual:[address.types objectAtIndex:0]])
            return_address_component = address;
        
    }
    
    return return_address_component; 
    
}

-(MLGoogleMap_address_components *)getRoute{
    return [self getAddressOfType:@"route"];
}

-(MLGoogleMap_address_components *)getStreet{
    return [self getAddressOfType:@"street_address"];
}

-(NSString *)description{
    
    if (self.geometry.location.latitude && self.geometry.location.longitude)
        return [NSString stringWithFormat:@"%f,%f",self.geometry.location.latitude,self.geometry.location.longitude];
    
    return self.formatted_address;
}

@end
