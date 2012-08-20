//
//  CustomPlacemark.m
//  MinskTaxi
//
//  Created by ml on 9/25/11.
//  Copyright (c) 2011 ml. All rights reserved.

#import "CustomPlacemark.h"


@implementation CustomPlacemark
@synthesize title, subtitle, coordinate, coordinateRegion, pinColor, type;

-(id)initWithRegion:(MKCoordinateRegion) coordRegion {
	self = [super init];
	
	if (self != nil) {
		coordinate = coordRegion.center;
		coordinateRegion = coordRegion;
	}
	
	return self;
}

- (void)dealloc {
	if(title != nil){
		[title release];
	}
	if(subtitle != nil){
		[subtitle release];
	}
	
	
	[super dealloc];
}
@end
