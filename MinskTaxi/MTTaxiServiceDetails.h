//
//  MTTaxiServiceDetails.h
//  MinskTaxi
//
//  Created by ml on 10/10/11.
//  Copyright 2011 ml. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaxiService.h"

@interface MTTaxiServiceDetails : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,retain) TaxiService *taxiService;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIProgressView *rating;
@property (retain, nonatomic) IBOutlet UITextView *describtions;
@property (retain, nonatomic) IBOutlet UITableView *phoneTable;
@property (retain, nonatomic) IBOutlet UITableView *tarifsTable;

@end
