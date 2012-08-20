//
//  MLGoogleMapAPI.h
//  MLGoogleAPI_ForwardGeocoder
//
//  Created by ml on 9/24/11.
//  Copyright (c) 2011 ml. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLGoogleMapGeocoding.h"
#import "MLGoogleMapDirections.h"

typedef void (^MLGoogleMapAPIBlock)(NSMutableArray *mlGoogleApiResult, NSError *error);

@interface MLGoogleMapAPI : NSObject{
 
@private
    NSMutableData       *_jsonData;
    NSURLConnection     *_connectionInProgress;

}

@property (nonatomic,copy) MLGoogleMapAPIBlock mlGoogleMapAPIBlock;
@property (nonatomic, retain) NSString *language;
@property (nonatomic, retain) NSString *region;


- (void) reverseGeocoding:(CLLocation *) location block:(MLGoogleMapAPIBlock)block;
- (void) reverseGeocodingFor2DCoordinate:(CLLocationCoordinate2D) coordinate block:(MLGoogleMapAPIBlock)block;
- (void) forwardGeocoding:(NSString *) address block:(MLGoogleMapAPIBlock)block;
- (void) getDerections:(MLGoogleMapGeocoding *)fromLocation toLocation:(MLGoogleMapGeocoding *)toLocation block:(MLGoogleMapAPIBlock)block;

@end


