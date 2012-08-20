//
//  MTTaxiServicesList.h
//  MinskTaxi
//
//  Created by admin on 10/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTTaxiServicesList : UIViewController{
    
@private
    NSArray *taxiServicesList;
    
}

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UITableView *table;

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
