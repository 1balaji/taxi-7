//
//  CustomPlacemark.h
//  MinskTaxi
//
//  Created by ml on 9/25/11.
//  Copyright (c) 2011 ml. All rights reserved.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    MTPinTypeDefault  = 0,
    MTPinTypeStart    = 1,
    MTPinTypeFinish   = 2,
} MTPinType;


@interface CustomPlacemark : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	MKCoordinateRegion coordinateRegion;
	NSString *title;
	NSString *subtitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) MKCoordinateRegion coordinateRegion;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) MKPinAnnotationColor pinColor;
@property (nonatomic) MTPinType type;

-(id)initWithRegion:(MKCoordinateRegion) coordRegion;
@end
