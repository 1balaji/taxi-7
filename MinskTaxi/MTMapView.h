//
//  MTMapView.h
//  MinskTaxi
//
//  Created by ml on 9/25/11.
//  Copyright (c) 2011 ml. All rights reserved.
//
// Looks like GOD class. todo: refactor

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MLGoogleMapAPI.h"
#import "CustomPlacemark.h"
#import "TaxiServicesModelController.h"

@interface MTMapView : UIViewController <MKMapViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>{
    
@private
    TaxiServicesModelController *taxiServicesModelController;
    
    MLGoogleMapDirections *direction;
    MLGoogleMapDirections *tracedRoute;
    MKPolyline            *routePolyline;
    MKPolyline            *tracedRoutePolyline;
    NSMutableArray        *showedAnnotation;
    NSMutableArray        *showedRouteAnnotations;
    CustomPlacemark       *pin;
    
    MLGoogleMapGeocoding  *locationFrom;
    MLGoogleMapGeocoding  *locationTo;
    MLGoogleMapAPI        *mlGoogleMapApi;
    CLLocationManager *locationManager;
    
    BOOL isSetRegionForMap;
    
    UIView      *searchRouteView;
    UISegmentedControl *taxiServiceSelector;
    UILabel *taxometerKm;
    UILabel *taxometerPrice;
    UIToolbar *selectViewTypeToolbar;
    UITextField *routeEndField;
    UIToolbar   *priceViewToolBar;
    NSMutableArray *viewArray;
    
    double taxometerKmValue;
    
}

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (retain, nonatomic) IBOutlet MKMapView *taxiMap;
@property (retain, nonatomic) IBOutlet UISearchBar *searchAddress;
@property (retain, nonatomic) IBOutlet UILabel *taxiServiceName;
@property (retain, nonatomic) IBOutlet UILabel *distanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *calcPriceLabel;
@property (retain, nonatomic) IBOutlet UISegmentedControl *viewTypeButton;
@property (nonatomic, retain) IBOutlet UITextField *routeStartField;
@property (nonatomic, retain) IBOutlet UITextField *routeEndField;
@property (nonatomic, retain) IBOutlet UIView *traceView;
@property (nonatomic, retain) IBOutlet UIView *priceView;
@property (nonatomic, retain) IBOutlet UIView *searchRouteView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *taxiServiceSelector;
@property (nonatomic, retain) IBOutlet UILabel *taxometerKm;
@property (nonatomic, retain) IBOutlet UILabel *taxometerPrice;
@property (nonatomic, retain) IBOutlet UIToolbar *selectViewTypeToolbar;
@property (retain, nonatomic) IBOutlet UIButton *optionsButton;
@property (retain, nonatomic) IBOutlet UIToolbar *optionsToolbar;
@property (retain, nonatomic) IBOutlet UIButton *currentLocationButton;

@property (retain, nonatomic) MLGoogleMapDirections *direction;
@property (retain, nonatomic) MLGoogleMapDirections *tracedRoute;

@property (retain, nonatomic) MLGoogleMapGeocoding  *locationFrom;
@property (retain, nonatomic) MLGoogleMapGeocoding  *locationTo;


- (IBAction)switchToFromPoints:(id)sender;
- (IBAction)returnSelectRoute:(id)sender;
- (IBAction)clearRouteButton:(id)sender;
- (IBAction)changeViewType:(id)sender;
- (IBAction)showUserLocation:(id)sender;
- (IBAction)clickGoButton:(id)sender;
- (IBAction)cancelTrace:(id)sender;
- (IBAction)finishTrace:(id)sender;
- (IBAction)callTaxi:(id)sender;
- (IBAction)infoAboutTaxi:(id)sender;
- (IBAction)selectTaxiService:(id)sender;
- (IBAction)putPin:(id)sender;
- (IBAction)moreOptions:(id)sender;
- (IBAction)showAllTaxiService:(id)sender;

- (void) setIngoingPoint:(id)sender;
- (void) setOutgoingPoint:(id)sender;

- (void) updateRoute;   
- (void) updateRoutePrice;
- (void) showView:(UIView *) view;
- (void) applicationDidBecomeActive;
- (void) setFrameForCurrentPositionButton;

@end
