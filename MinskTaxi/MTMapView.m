//
//  MTMapView.m
//  MinskTaxi
//
//  Created by ml on 9/25/11.
//  Copyright (c) 2011 ml. All rights reserved.
//

#import "MTMapView.h"
#import "WildcardGestureRecognizer.h"
#import "MTTotalCalculation.h"
#import "MTTaxiServiceDetails.h"
#import "MTTaxiServicesList.h"
#import "Phone.h"
#import "LoggerClient.h"

@implementation MTMapView
@synthesize taxiServiceName;
@synthesize taxiServiceSelector,taxometerKm,taxometerPrice;
@synthesize selectViewTypeToolbar;
@synthesize optionsButton;
@synthesize optionsToolbar;
@synthesize currentLocationButton;
@synthesize traceView, searchRouteView, routeStartField, routeEndField;
@synthesize taxiMap,searchAddress,direction, tracedRoute,priceView,distanceLabel,calcPriceLabel,viewTypeButton;
@synthesize locationTo,locationFrom;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mlGoogleMapApi = [[MLGoogleMapAPI alloc] init];
        showedAnnotation = [[NSMutableArray alloc] init];
        showedRouteAnnotations = [[NSMutableArray alloc] init];
        routePolyline = [[MKPolyline alloc] init]; 
        locationFrom = [[MLGoogleMapGeocoding alloc] init];
        locationTo = [[MLGoogleMapGeocoding alloc] init];
        viewArray = [[NSMutableArray alloc] init];
        taxometerKmValue = 0.0;
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    taxiServicesModelController = [TaxiServicesModelController new];
    taxiServicesModelController.managedObjectContext = self.managedObjectContext;

    //add Click to map for hideKeyboard
    //code takes from: stackoverflow.com/questions/1049889/how-to-intercept-touches-events-on-a-mkmapview-or-uiwebview-objects
    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
          [searchAddress resignFirstResponder];
          [routeStartField resignFirstResponder];
          [routeEndField resignFirstResponder];
          [self setFrameForCurrentPositionButton];
          if (optionsButton.selected)[self moreOptions:optionsButton];
  };
    [taxiMap addGestureRecognizer:tapInterceptor];
    [tapInterceptor release];
    

    self.navigationItem.title = NSLocalizedString(@"TaxiMinsk", @"");
    
    UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",@"") style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    self.navigationItem.backBarButtonItem = backButton;
    self.navigationController.toolbar.hidden = NO;
    
    UILabel *endLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 7, 55, 23)] autorelease];
    endLabel.text = NSLocalizedString(@"RouteEnd", @"");
    endLabel.font = [UIFont systemFontOfSize:14];
    endLabel.textAlignment = UITextAlignmentRight;
    endLabel.textColor = [UIColor grayColor];
    routeEndField.leftViewMode = UITextFieldViewModeAlways;
    routeEndField.leftView = endLabel;
    routeEndField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    UILabel *startLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 7, 55, 23)] autorelease];
    startLabel.text = NSLocalizedString(@"RouteStart", @"");
    startLabel.font = [UIFont systemFontOfSize:14];
    startLabel.textAlignment = UITextAlignmentRight;
    startLabel.textColor = [UIColor grayColor];
    routeStartField.leftViewMode = UITextFieldViewModeAlways;
    routeStartField.leftView = startLabel;
    routeStartField.clearButtonMode = UITextFieldViewModeWhileEditing;

    routeStartField.font = [UIFont systemFontOfSize:14];
    routeEndField.font = [UIFont systemFontOfSize:14];
        
    optionsToolbar.frame = CGRectMake(0, self.view.frame.size.height, optionsToolbar.frame.size.width, optionsToolbar.frame.size.height);
    [self.view addSubview:optionsToolbar];
    
    [self.view addSubview:searchRouteView];
    [self.view addSubview:priceView];
    [self.view addSubview:traceView];
    
    [viewArray addObject:searchRouteView];
    [viewArray addObject:priceView];
    [viewArray addObject:traceView];
    [viewArray addObject:searchAddress];
    
    searchAddress.frame = CGRectMake(searchAddress.frame.origin.x, (searchAddress.frame.origin.y - searchAddress.frame.size.height) , searchAddress.frame.size.width, searchAddress.frame.size.height);
    [self showView:searchAddress];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name: UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)viewDidUnload
{
    [self setTaxiMap:nil];
    [self setSearchAddress:nil];
    [self setPriceView:nil];
    [self setDistanceLabel:nil];
    [self setCalcPriceLabel:nil];
    [self setViewTypeButton:nil];
    [self setSearchRouteView:nil];
    [self setRouteStartField:nil];
    [self setRouteEndField:nil];
    [self setTraceView:nil];
    [self setTaxiServiceSelector:nil];
    [self setTaxometerKm:nil];
    [self setTaxometerPrice:nil];
    [self setSelectViewTypeToolbar:nil];
    [self setOptionsButton:nil];
    [self setOptionsToolbar:nil];
    [self setTaxiServiceName:nil];
    [self setCurrentLocationButton:nil];
    [super viewDidUnload];

}

- (void) viewDidAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [taxiServicesModelController release];
    [managedObjectContext release];
    [viewArray release];
    [locationFrom release];
    [locationTo release];
    [mlGoogleMapApi release];
    [showedAnnotation release];
    [showedRouteAnnotations release];
    [direction release];
    [tracedRoute release];
    [taxiMap release];
    [searchAddress release];
    [priceView release];
    [distanceLabel release];
    [calcPriceLabel release];
    [viewTypeButton release];
    [searchRouteView release];
    [routeStartField release];
    [routeEndField release];
    [priceViewToolBar release];
    [traceView release];
    [taxiServiceSelector release];
    [taxometerKm release];
    [taxometerPrice release];
    [selectViewTypeToolbar release];
    [optionsButton release];
    [optionsToolbar release];
    [taxiServiceName release];
    [currentLocationButton release];
    [super dealloc];
}


- (void) showView:(UIView *) view{
    
    [UIView beginAnimations:@"show view" context:nil];
    [UIView setAnimationDuration:0.3];
    
    for (UIView *subView in viewArray){
        if (subView != view){
            if (subView.frame.origin.y == 0.0)
                subView.frame = CGRectMake(subView.frame.origin.x, (subView.frame.origin.y - subView.frame.size.height) , subView.frame.size.width, subView.frame.size.height);
        }
        else if (subView.frame.origin.y != 0.0){
            subView.frame = CGRectMake(subView.frame.origin.x, (subView.frame.origin.y + subView.frame.size.height) , subView.frame.size.width, subView.frame.size.height);  
        }
    }

    [UIView commitAnimations];
}


#pragma mark - IBAction Delegate
- (IBAction)returnSelectRoute:(id)sender {
    
    //switch view type
    [self showView:searchRouteView];
    [routeEndField becomeFirstResponder];

}

- (IBAction)clearRouteButton:(id)sender {
    routeEndField.text = nil;
    routeStartField.text = nil;
}

- (IBAction)changeViewType:(id)sender {

    //search mode
    if (((UISegmentedControl *)sender).selectedSegmentIndex == 0){
        [taxiMap removeOverlay:routePolyline];
        [taxiMap removeAnnotations:showedRouteAnnotations];
        [taxiMap addAnnotations:showedAnnotation];
        [self showView:searchAddress]; 
    }
    //route mode
    else{
        [taxiMap addOverlay:routePolyline];
        [taxiMap removeAnnotations:showedAnnotation];
        [taxiMap addAnnotations:showedRouteAnnotations];
        [self showView:searchRouteView];
        [searchRouteView setFrame:CGRectOffset([searchRouteView frame], 0, 0)]; 
        routeStartField.text = locationFrom.formatted_address ? [NSString stringWithFormat:@"%@",locationFrom.formatted_address]:nil;
        routeEndField.text = locationTo.formatted_address ? [NSString stringWithFormat:@"%@",locationTo.formatted_address] : nil;
        [routeEndField becomeFirstResponder];
    };
    
}

- (IBAction)showUserLocation:(id)sender {
    
    MKCoordinateRegion region = {{0.0f,0.0f},{0.0f,0.0f}};
    region.center = taxiMap.userLocation.location.coordinate;
    region.span.latitudeDelta = 0.01f;
    region.span.longitudeDelta = 0.01f;
    [taxiMap setRegion:region animated:YES];
}

- (IBAction)clickGoButton:(id)sender {
    
    [routeEndField resignFirstResponder];
    [routeStartField resignFirstResponder];

    [tracedRoute release];
    tracedRoute = [[MLGoogleMapDirections alloc] init];
    
    [UIView beginAnimations:@"startTrace" context:nil];
    [UIView setAnimationDuration:0.3];
    [self showView:traceView];
    taxiMap.frame = CGRectMake(taxiMap.frame.origin.x, taxiMap.frame.origin.y, taxiMap.frame.size.width,  taxiMap.frame.size.height + 44 );
    if (optionsButton.selected)[self moreOptions:optionsButton];
    [self setFrameForCurrentPositionButton];
    [selectViewTypeToolbar setHidden:YES];
    [UIView commitAnimations];

    taxometerKmValue = 0.0;
    [locationManager startUpdatingLocation];
    
}

- (IBAction)cancelTrace:(id)sender {

    taxometerKmValue = 0.0;
    [locationManager stopUpdatingLocation];
    [self showView:searchRouteView];
    taxiMap.frame = CGRectMake(taxiMap.frame.origin.x, taxiMap.frame.origin.y, taxiMap.frame.size.width,  taxiMap.frame.size.height - 44 );
    [selectViewTypeToolbar setHidden:NO];
    [routeEndField becomeFirstResponder];
    
    [taxiMap removeOverlay:tracedRoutePolyline];
    [tracedRoutePolyline release];
    [tracedRoute release];
    tracedRoute = nil;
    tracedRoutePolyline = nil;
    [self setFrameForCurrentPositionButton];

}

- (IBAction)finishTrace:(id)sender {

    [locationManager stopUpdatingLocation];
    MTTotalCalculation *totalCalculation = [[MTTotalCalculation alloc] init];
    totalCalculation.calculableTaxiService = [taxiServicesModelController getCurrentTrip];
    [self.navigationController pushViewController:totalCalculation animated:YES];
    [totalCalculation release];
    
    [taxiMap removeOverlay:tracedRoutePolyline];
    [tracedRoutePolyline release];
    [tracedRoute release];
    tracedRoute = nil;
    tracedRoutePolyline = nil;

 //   [self showView:searchRouteView];
    taxometerKmValue = 0.0;

}

- (IBAction)callTaxi:(id)sender {

    //add select cheapest number (oun Cell Operator)
    Phone *phone = [[taxiServicesModelController getCurrentTrip].taxiService.phones anyObject];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone.phoneNumber]]];

}

- (IBAction)infoAboutTaxi:(id)sender {
    
    MTTaxiServiceDetails *taxiServiceDetails = [[MTTaxiServiceDetails alloc] init];
    taxiServiceDetails.taxiService = [taxiServicesModelController getCurrentTrip].taxiService;
    [self.navigationController pushViewController:taxiServiceDetails animated:YES];
    [taxiServiceDetails release];
    
}

- (IBAction)selectTaxiService:(id)sender {
    
    if (((UISegmentedControl *)sender).selectedSegmentIndex == 3) {
        MTTaxiServicesList *taxiServicesList = [[MTTaxiServicesList alloc] init];
        [self.navigationController pushViewController:taxiServicesList animated:YES];
        [taxiServicesList release];
        ((UISegmentedControl *)sender).selectedSegmentIndex = UISegmentedControlNoSegment;
    }
    else{
        [taxiServicesModelController setSelectedTaxiIndex:((UISegmentedControl *)sender).selectedSegmentIndex];
        [self updateRoutePrice];
    }
    
        
}

- (IBAction)putPin:(id)sender {

   if (pin) [taxiMap removeAnnotation:pin];
    
    MKCoordinateRegion coordinate;
    coordinate.center =  taxiMap.centerCoordinate;
    coordinate.span.latitudeDelta = 0.1f;
    coordinate.span.longitudeDelta = 0.1f;
    pin = [[[CustomPlacemark alloc] initWithRegion:coordinate] autorelease];
    pin.subtitle = NSLocalizedString (@"Pin", @"");
    pin.title = NSLocalizedString (@"Pin", @"");
    pin.pinColor = MKPinAnnotationColorPurple;
    [taxiMap addAnnotation:pin];
 
    MLGoogleMapAPI *googleApi = [[MLGoogleMapAPI alloc] init];
    
    [googleApi reverseGeocodingFor2DCoordinate:taxiMap.centerCoordinate block:^(NSMutableArray *mlGoogleApiResult, NSError *error) {
        if ([mlGoogleApiResult count] > 0){
            MLGoogleMapGeocoding *result = [mlGoogleApiResult objectAtIndex:0];
            pin.subtitle = [NSString stringWithFormat:@"%@",[result formatted_address]];
        }
        else{
            pin.subtitle = [NSString stringWithFormat:@"Булавка, Минск, Беларусь"];
        }
    }];

    [googleApi release];
}

- (IBAction)moreOptions:(id)sender {
    
    if (!((UIButton *)sender).selected){
        [UIView transitionWithView:self.taxiMap duration:0.3 options:UIViewAnimationTransitionFlipFromRight animations:^{ [self.taxiMap setFrame:CGRectMake(taxiMap.frame.origin.x, taxiMap.frame.origin.y, taxiMap.frame.size.width, taxiMap.frame.size.height - 44)]; } completion:nil];
        [UIView transitionWithView:self.selectViewTypeToolbar duration:0.3 options:UIViewAnimationTransitionFlipFromRight animations:^{ [self.selectViewTypeToolbar setFrame:CGRectMake(selectViewTypeToolbar.frame.origin.x, selectViewTypeToolbar.frame.origin.y-44, selectViewTypeToolbar.frame.size.width, selectViewTypeToolbar.frame.size.height)]; } completion:nil];
        [UIView transitionWithView:self.optionsToolbar duration:0.3 options:UIViewAnimationTransitionFlipFromRight animations:^{ [self.optionsToolbar setFrame:CGRectMake(optionsToolbar.frame.origin.x, optionsToolbar.frame.origin.y-44, optionsToolbar.frame.size.width, optionsToolbar.frame.size.height)]; } completion:nil];
    }
    else
    {
        [UIView transitionWithView:self.taxiMap duration:0.3 options:UIViewAnimationTransitionFlipFromRight animations:^{ [self.taxiMap setFrame:CGRectMake(taxiMap.frame.origin.x, taxiMap.frame.origin.y, taxiMap.frame.size.width, taxiMap.frame.size.height + 44)]; } completion:nil];
        [UIView transitionWithView:self.selectViewTypeToolbar duration:0.3 options:UIViewAnimationTransitionFlipFromRight animations:^{ [self.selectViewTypeToolbar setFrame:CGRectMake(selectViewTypeToolbar.frame.origin.x, selectViewTypeToolbar.frame.origin.y+44, selectViewTypeToolbar.frame.size.width, selectViewTypeToolbar.frame.size.height)]; } completion:nil];
        [UIView transitionWithView:self.optionsToolbar duration:0.3 options:UIViewAnimationTransitionFlipFromRight animations:^{ [self.optionsToolbar setFrame:CGRectMake(optionsToolbar.frame.origin.x, optionsToolbar.frame.origin.y+44, optionsToolbar.frame.size.width, optionsToolbar.frame.size.height)]; } completion:nil];
    }
    
    ((UIButton *)sender).selected = !((UIButton *)sender).selected;
    [self setFrameForCurrentPositionButton];

}

- (IBAction)showAllTaxiService:(id)sender {
    
    MTTaxiServicesList *taxiServicesList = [[MTTaxiServicesList alloc] init];
    taxiServicesList.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:taxiServicesList animated:YES];
    [taxiServicesList release];

}

- (IBAction)switchToFromPoints:(id)sender {
   
    MLGoogleMapGeocoding *buffer = [locationTo retain];
    [locationTo release];
    locationTo = [locationFrom retain];
    [locationFrom release];
    locationFrom = [buffer retain];
    [buffer release];
    
    routeStartField.text = locationFrom.formatted_address ? [NSString stringWithFormat:@"%@",locationFrom.formatted_address] : nil;
    routeEndField.text = locationTo.formatted_address ? [NSString stringWithFormat:@"%@",locationTo.formatted_address] : nil;
    
}

- (void) updateRoutePrice{
    taxiServiceName.text = [NSString stringWithFormat:@"Служба: %@", [taxiServicesModelController getCurrentTrip].taxiService.name];
    distanceLabel.text = [NSString stringWithFormat:@"Расстояние: %0.2f км",[[taxiServicesModelController getCurrentTrip].tripDistance floatValue]];
    calcPriceLabel.text = [NSString stringWithFormat:@"Стоимость: %0.0f руб",[[taxiServicesModelController getCurrentTrip].tripPrice floatValue]];
}


-(void) updateRoute{
    
    if (direction == nil) return;
    
    if (![direction.legs.end_address isEqualToString:[NSString stringWithFormat:@"Минск, Беларусь"]]) {
       
        //show price 
        [taxiServiceSelector setSelectedSegmentIndex:0];
        [self selectTaxiService:taxiServiceSelector];
        
        //display on map:
        [taxiMap removeAnnotations:showedRouteAnnotations];
        [taxiMap removeOverlay:routePolyline];
        [showedRouteAnnotations removeAllObjects];
        
        MKCoordinateRegion region = {{0.0f,0.0f},{0.0f,0.0f}};
        region.center.latitude = (direction.bounds.northeast.latitude + direction.bounds.southwest.latitude) / 2;
        region.center.longitude = (direction.bounds.northeast.longitude + direction.bounds.southwest.longitude) / 2;
        region.span.latitudeDelta = (direction.bounds.northeast.latitude - direction.bounds.southwest.latitude) * 1.2; 
        region.span.longitudeDelta = (direction.bounds.northeast.longitude - direction.bounds.southwest.longitude) * 1.2; 
        [taxiMap setRegion:region animated:YES];
        
        [routePolyline release];
        routePolyline =[[direction getPolyline] retain];
        [taxiMap addOverlay:routePolyline];
        
        MKCoordinateRegion coordinate;
        coordinate.center.latitude =  direction.legs.start_location.latitude;
        coordinate.center.longitude = direction.legs.start_location.longitude;
        coordinate.span.latitudeDelta = 0.1f;
        coordinate.span.longitudeDelta = 0.1f;
        CustomPlacemark *placemarkStart = [[[CustomPlacemark alloc] initWithRegion:coordinate] autorelease];
        placemarkStart.title = NSLocalizedString (@"RouteStart",@"");
        placemarkStart.subtitle = [NSString stringWithFormat:@"%@",direction.legs.start_address];
        placemarkStart.pinColor = MKPinAnnotationColorGreen;
        placemarkStart.type = MTPinTypeStart;
        [showedRouteAnnotations addObject:placemarkStart];
        
        coordinate.center.latitude =  direction.legs.end_location.latitude;
        coordinate.center.longitude = direction.legs.end_location.longitude;
        coordinate.span.latitudeDelta = 0.1f;
        coordinate.span.longitudeDelta = 0.1f;
        CustomPlacemark *placemarkEnd = [[[CustomPlacemark alloc] initWithRegion:coordinate] autorelease];
        placemarkEnd.title = NSLocalizedString (@"RouteEnd",@"");
        placemarkEnd.subtitle = [NSString stringWithFormat:@"%@",direction.legs.end_address];
        placemarkEnd.type = MTPinTypeFinish;
        [showedRouteAnnotations addObject:placemarkEnd];
        
        [taxiMap addAnnotations:showedRouteAnnotations];
    }
    else{
        distanceLabel.text = nil;
        calcPriceLabel.text = NSLocalizedString (@"RouteNotFound", @"");
    }
    
    //switch view type
    [self showView:priceView];

}

- (void) setIngoingPoint:(id)sender{

    ((UIButton *)sender).backgroundColor = [UIColor redColor]; 
    
    [locationTo release];
    locationTo = [[MLGoogleMapGeocoding alloc] init];
    locationTo.geometry.location = [((MKPinAnnotationView*)[[sender superview] superview]).annotation coordinate];
    locationTo.formatted_address = [NSString stringWithFormat:@"%@",[((MKPinAnnotationView*)[[sender superview] superview]).annotation subtitle]];
    routeEndField.text = locationTo.formatted_address ? [NSString stringWithFormat:@"%@",locationTo.formatted_address] : nil;
    
    if (viewTypeButton.selectedSegmentIndex == 1) [self changeViewType:viewTypeButton];
        else viewTypeButton.selectedSegmentIndex = 1;
    
}

- (void) setOutgoingPoint:(id)sender{
    
    ((UIButton *)sender).backgroundColor = [UIColor redColor]; 
    
    [locationFrom release];
    locationFrom = [[MLGoogleMapGeocoding alloc] init];
    locationFrom.geometry.location = [((MKPinAnnotationView*)[[sender superview] superview]).annotation coordinate];
    locationFrom.formatted_address = [NSString stringWithFormat:@"%@",[((MKPinAnnotationView*)[[sender superview] superview]).annotation subtitle]];
    routeStartField.text = locationFrom.formatted_address ? [NSString stringWithFormat:@"%@",locationFrom.formatted_address] : nil;
    
    if (viewTypeButton.selectedSegmentIndex == 1) [self changeViewType:viewTypeButton];
        else viewTypeButton.selectedSegmentIndex = 1;
}

- (void) applicationDidBecomeActive{
    
    isSetRegionForMap = NO;
    
}

- (void) setFrameForCurrentPositionButton{
    
    [UIView transitionWithView:self.currentLocationButton duration:0.3 options:UIViewAnimationTransitionFlipFromRight animations:^{currentLocationButton.frame = CGRectMake(currentLocationButton.frame.origin.x, taxiMap.frame.origin.y + taxiMap.frame.size.height - currentLocationButton.frame.size.height - 10, currentLocationButton.frame.size.width, currentLocationButton.frame.size.height);} completion:nil];
        
}

#pragma mark mapView delegate functions
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay{
    
    MKPolylineView *polilineView = [[[MKPolylineView alloc] initWithPolyline:overlay] autorelease];
    polilineView.strokeColor = (overlay == tracedRoutePolyline) ? [UIColor redColor] : [UIColor grayColor];
    polilineView.lineWidth = 5.0; 
    
    return polilineView;
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    if (!isSetRegionForMap){
        MKCoordinateRegion region = {{0.0f,0.0f},{0.0f,0.0f}};
        region.center = mapView.userLocation.location.coordinate;
        region.span.latitudeDelta = 0.01f;
        region.span.longitudeDelta = 0.01f;
        [mapView setRegion:region animated:YES];
        isSetRegionForMap=YES;
        locationFrom.geometry.location = mapView.userLocation.coordinate;
        locationFrom.formatted_address = NSLocalizedString (@"Current Location",@""); 
        locationFrom.type = 1;
    }
    

    //todo: investigate how offen it will be called
    MLGoogleMapAPI *googleApi = [[MLGoogleMapAPI alloc] init];
    [googleApi reverseGeocodingFor2DCoordinate:mapView.userLocation.location.coordinate block:^(NSMutableArray *mlGoogleApiResult, NSError *error) {
        if ([mlGoogleApiResult count] > 0){
            MLGoogleMapGeocoding *result = [mlGoogleApiResult objectAtIndex:0];
            mapView.userLocation.subtitle = [NSString stringWithFormat:@"%@",[result formatted_address]];
        }
        else{
            mapView.userLocation.subtitle = nil;
        }
    }];
    
    [googleApi release];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
   
    MKAnnotationView *annPinView = nil;
    
    if ([annotation isKindOfClass:[CustomPlacemark class]]) {
        annPinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"] autorelease];
        annPinView.canShowCallout = YES;
                
        if (((CustomPlacemark *)annotation).type == 0) {
            UIButton *ingoing = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            UIButton *outgoing = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            ingoing.frame = CGRectMake(0, 0, 30, 30);
            outgoing.frame = CGRectMake(0, 0, 30, 30);
            [ingoing setTitle:[NSString stringWithFormat:@"В"] forState:UIControlStateNormal];
            [outgoing setTitle:[NSString stringWithFormat:@"Из"] forState:UIControlStateNormal];
            [outgoing addTarget:self action:@selector(setOutgoingPoint:) forControlEvents:UIControlEventTouchDown];
            [ingoing addTarget:self action:@selector(setIngoingPoint:) forControlEvents:UIControlEventTouchDown];
            annPinView.rightCalloutAccessoryView = ingoing;
            annPinView.leftCalloutAccessoryView = outgoing;
        }
            ((MKPinAnnotationView *)annPinView).pinColor = ((CustomPlacemark *)annotation).pinColor;
    } 
  
    return annPinView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews
{
    NSTimeInterval delayInterval = 0;
    
    for (MKAnnotationView *annView in annotationViews)
    {
        CGRect endFrame = annView.frame;
        
        annView.frame = CGRectOffset(endFrame, 0, -500);
        
        [UIView animateWithDuration:0.4
                              delay:delayInterval
                            options:UIViewAnimationOptionAllowUserInteraction 
                         animations:^{ annView.frame = endFrame; } 
                         completion:NULL];
        
        delayInterval += 0.0525;
    }
}

#pragma mark -UITextFieldDelegate 

/*find route*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    if (locationTo == nil)
    {
        locationTo = [[MLGoogleMapGeocoding alloc] init];
        locationTo.formatted_address = [NSString stringWithFormat:@"%@,Мinsk,Belarus",routeEndField.text];
    }
    
    if (![locationTo.formatted_address isEqual:routeEndField.text]){
        [locationTo release];
        locationTo = [[MLGoogleMapGeocoding alloc] init];
        locationTo.formatted_address = [NSString stringWithFormat:@"%@,Мinsk,Belarus",routeEndField.text];
    } 
    
    if (![locationFrom.formatted_address isEqual:routeStartField.text]){
        [locationFrom release];
        locationFrom = [[MLGoogleMapGeocoding alloc] init];
        locationFrom.formatted_address = [NSString stringWithFormat:@"%@,Мinsk,Belarus",routeStartField.text];
    }
    
    if (locationTo.type == 1) locationTo.geometry.location = taxiMap.userLocation.coordinate;
    if (locationFrom.type == 1) locationFrom.geometry.location = taxiMap.userLocation.coordinate;
    
    [mlGoogleMapApi getDerections:locationFrom toLocation:locationTo block:^(NSMutableArray *mlGoogleApiResult, NSError *error) {
        [direction release];
        direction = nil;
        for (MLGoogleMapDirections *route in mlGoogleApiResult){
            if (direction){
                if (route.legs.distance < direction.legs.distance) {
                    [direction release];
                    direction = [route retain];
                }
            }
            else // for first element in array
            {
                direction = [route retain];  
            }
        };
        [direction retain];
        [taxiServicesModelController calculateAllTaxiServices:direction];
        [self updateRoute];
    }];

    return YES;
}

#pragma mark -UISearchBar Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
    [mlGoogleMapApi forwardGeocoding:[NSString stringWithFormat:@"%@,Minsk,Belarus",searchBar.text] block:^(NSMutableArray *mlGoogleApiResult, NSError *error) {
        [taxiMap removeAnnotations:[NSArray arrayWithArray:showedAnnotation]];
        [showedAnnotation removeAllObjects];
        
        for (MLGoogleMapGeocoding *address in mlGoogleApiResult){     
            MKCoordinateRegion coordinate;
            coordinate.center.latitude =  address.geometry.location.latitude;
            coordinate.center.longitude = address.geometry.location.longitude;
            coordinate.span.latitudeDelta = 0.1f;
            coordinate.span.longitudeDelta = 0.1f;
            CustomPlacemark *placemark = [[[CustomPlacemark alloc] initWithRegion:coordinate] autorelease];
            placemark.subtitle = address.formatted_address; 
            placemark.title = ((MLGoogleMap_address_components *)[address.address_components objectAtIndex:0]).long_name;
            [showedAnnotation addObject:placemark];
        }
        
        MKCoordinateRegion region = {{0.0f,0.0f},{0.0f,0.0f}};
        region.center = ((MLGoogleMapGeocoding*)[mlGoogleApiResult lastObject]).geometry.location;
        region.span.latitudeDelta = 0.1f;
        region.span.longitudeDelta = 0.1f;
        [taxiMap setRegion:region animated:YES];
        [taxiMap addAnnotations:showedAnnotation];
        
        [locationTo release];
        locationTo = [[mlGoogleApiResult lastObject] retain];
    }];
    
}

#pragma mark -CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *) oldLocation
{
    taxometerKmValue += [newLocation distanceFromLocation:oldLocation];
    
    MLGoogleMapDirections_Step *step = [[MLGoogleMapDirections_Step alloc] initWithLocations:newLocation fromLocation:oldLocation];
    [tracedRoute.legs.steps addObject:step];
    [step release];
    tracedRoute.legs.distance = taxometerKmValue;
    
    [taxiMap removeOverlay:tracedRoutePolyline];
    [tracedRoutePolyline release];
    tracedRoutePolyline =[[tracedRoute getPolyline] retain];
    [taxiMap addOverlay:tracedRoutePolyline];
    
    [taxiServicesModelController calculateAllTaxiServices:tracedRoute];
    
    taxometerKm.text = [NSString stringWithFormat:@"Проехали: %0.2f км",(taxometerKmValue / 1000.00)];
    taxometerPrice.text = [NSString stringWithFormat:@"Стоимость поездки: %0.0f руб",[[taxiServicesModelController getCurrentTrip].tripPrice floatValue]];
    
}

@end
