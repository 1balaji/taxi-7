//
//  MTTotalCalculation.h
//  MinskTaxi
//
//  Created by ml on 10/10/11.
//  Copyright 2011 ml. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculableTaxiService.h"

@interface MTTotalCalculation : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,retain) CalculableTaxiService *calculableTaxiService;
@property (nonatomic,retain) CalculableTaxiService *googleCalculatedTaxiService;


- (IBAction)paid:(id)sender;
- (IBAction)share:(id)sender;

@end
