//
//  MLGoogleMapAPI.m
//  MLGoogleAPI_ForwardGeocoder
//
//  Created by ml on 9/24/11.
//  Copyright (c) 2011 ml. All rights reserved.
//


#define ShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = NO

#import "MLGoogleMapAPI.h"

@implementation MLGoogleMapAPI

@synthesize mlGoogleMapAPIBlock;
@synthesize language = _language,region = _region;

- (id) init{
    self = [super init];
    if (self){
        NSLocale *locale = [NSLocale currentLocale];
        _language = [[locale objectForKey: NSLocaleLanguageCode] retain];
        _region = [[locale objectForKey: NSLocaleCountryCode] retain];
    }
    return self;
}

-(void) dealloc{
    [_region release];
    [_language release];
    [super dealloc];
}

- (void) forwardGeocoding:(NSString *) address block:(MLGoogleMapAPIBlock)block{
 
    ShowNetworkActivityIndicator();   

    mlGoogleMapAPIBlock = [block copy];
    _jsonData = [[NSMutableData alloc] init];
    
    NSString *jsonUrl = [NSString stringWithFormat: @"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true&language=%@&region=%@",address,_language,_region];
    
    NSURL *url = [[[NSURL alloc] initWithString:[jsonUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] autorelease];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];

    _connectionInProgress = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
}

- (void) reverseGeocodingFor2DCoordinate:(CLLocationCoordinate2D) coordinate block:(MLGoogleMapAPIBlock)block{
    
    mlGoogleMapAPIBlock = [block copy];
    _jsonData = [[NSMutableData alloc] init];
    
    NSString *jsonUrl = [NSString stringWithFormat: @"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true&language=%@&region=%@",coordinate.latitude,coordinate.longitude,_language,_region];
    
    
    NSURL *url = [[[NSURL alloc] initWithString:[jsonUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] autorelease];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];
    
    _connectionInProgress = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
}


- (void) reverseGeocoding:(CLLocation *) location block:(MLGoogleMapAPIBlock)block{
    
    [self reverseGeocodingFor2DCoordinate:location.coordinate block:block];
}

- (void) getDerections:(MLGoogleMapGeocoding *)fromLocation toLocation:(MLGoogleMapGeocoding *)toLocation block:(MLGoogleMapAPIBlock)block{

    ShowNetworkActivityIndicator();   

    mlGoogleMapAPIBlock = [block copy];
    _jsonData = [[NSMutableData alloc] init];
    
    NSString *jsonUrl = [NSString stringWithFormat: @"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=true&language=%@&region=%@&alternatives=true&avoid=highways",fromLocation,toLocation,_language,_region];
        
    NSURL *url = [[[NSURL alloc] initWithString:[jsonUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] autorelease];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];
    
    _connectionInProgress = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];

}

#pragma mark -NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_jsonData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    NSString *jsonCheck = [[[NSString alloc] initWithData:_jsondata encoding:NSUTF8StringEncoding] autorelease];
//    NSLog(@"xmlCheck = %@", jsonCheck);
    
    HideNetworkActivityIndicator();   
    
    NSError *_error = [[NSError alloc] init];  
    NSDictionary *items = [NSJSONSerialization JSONObjectWithData:_jsonData options:NSJSONReadingMutableContainers error:&_error];
    
    NSMutableArray *mlGoogleApiResult = [[[NSMutableArray alloc] init] autorelease];
    
    //todo: optimize (?)
    if ([[items objectForKey:@"status"] isEqual:@"OK"]){
        if ([items objectForKey:@"results"]) {
            for (NSDictionary *resultDictionary in [items objectForKey:@"results"]){
                MLGoogleMapGeocoding *resultComponent = [[MLGoogleMapGeocoding alloc] initWithDictionary:resultDictionary];
                [mlGoogleApiResult addObject:resultComponent];
                [resultComponent release];
            }
        }
        else if ([items objectForKey:@"routes"]){
            for (NSDictionary *resultDictionary in [items objectForKey:@"routes"]){
                MLGoogleMapDirections *resultComponent = [[MLGoogleMapDirections alloc] initWithDictionary:resultDictionary];
                [mlGoogleApiResult addObject:resultComponent];
                [resultComponent release];
            }
        }
    }
    
    [_jsonData release];
    _jsonData = nil;
    [_connectionInProgress release];
    _connectionInProgress = nil;
    
    mlGoogleMapAPIBlock(mlGoogleApiResult, nil);
    [mlGoogleMapAPIBlock release];
    [_error release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    HideNetworkActivityIndicator();

    mlGoogleMapAPIBlock(nil, error);

    [_jsonData release];
    _jsonData = nil;
    [_connectionInProgress release];
    _connectionInProgress = nil;

}

- (void) setRegion:(NSString *)region{
    [_region release];
    _region = [region retain];
}

- (void) setLanguage:(NSString *)language{
    [_language release];
    _language = [language retain];
}

@end
