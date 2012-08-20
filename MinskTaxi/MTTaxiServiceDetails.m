//
//  MTTaxiServiceDetails.m
//  MinskTaxi
//
//  Created by ml on 10/10/11.
//  Copyright 2011 ml. All rights reserved.
//

#import "MTTaxiServiceDetails.h"
#import "Phone.h"
#import "Tarif.h"
#import <QuartzCore/QuartzCore.h>

@implementation MTTaxiServiceDetails

@synthesize taxiService;
@synthesize scrollView;
@synthesize rating;
@synthesize describtions;
@synthesize phoneTable;
@synthesize tarifsTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.phoneTable.layer.borderWidth = 1;
	self.phoneTable.layer.borderColor = [UIColor whiteColor].CGColor;
	self.phoneTable.layer.cornerRadius = 10;
    
    self.tarifsTable.layer.borderWidth = 1;
	self.tarifsTable.layer.borderColor = [UIColor whiteColor].CGColor;
	self.tarifsTable.layer.cornerRadius = 10;
    
    self.describtions.layer.borderWidth = 1;
	self.describtions.layer.borderColor = [UIColor whiteColor].CGColor;
	self.describtions.layer.cornerRadius = 10;
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = taxiService.name;
    
    self.phoneTable.frame = CGRectMake(phoneTable.frame.origin.x, phoneTable.frame.origin.y, phoneTable.frame.size.width, 30 + 40 * [taxiService.phones count]);
    
    self.tarifsTable.frame = CGRectMake(tarifsTable.frame.origin.x, phoneTable.frame.origin.y + phoneTable.frame.size.height + 20, tarifsTable.frame.size.width, (30 + 40 * 3) * [taxiService.tarifs count]);
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, tarifsTable.frame.origin.y + tarifsTable.frame.size.height);
    self.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0 , 80.0 , 0.0);
    
    self.rating.progress = [taxiService.rating floatValue] / 100.0 ;
    self.describtions.text = [NSString stringWithFormat:@"%@",taxiService.descriptions];

}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setRating:nil];
    [self setDescribtions:nil];
    [self setPhoneTable:nil];
    [self setTarifsTable:nil];
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [scrollView release];
    [rating release];
    [describtions release];
    [phoneTable release];
    [tarifsTable release];
    [super dealloc];
}


#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    if (tableView.tag == 0)
        return NSLocalizedString(@"Phones", nil);
    else if (tableView.tag == 1)
        return ((Tarif*)[[taxiService.tarifs allObjects] objectAtIndex:section]).name;
    
    return nil;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == 0)
        return 1;
    else if (tableView.tag == 1)
        return [taxiService.tarifs count];
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 0)
        return [taxiService.phones count];
    else if (tableView.tag == 1)
        return 3;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (tableView.tag == 0){
        
        cell.textLabel.text = @"Velcom";    
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",((Phone *)[[taxiService.phones allObjects] objectAtIndex:indexPath.row]).phoneNumber];
       // [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    else if (tableView.tag == 1){
        //need to refactor
        
        switch (indexPath.row) {
            case 0:
            cell.textLabel.text = @"Бронирование";    
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",((Tarif *)[[taxiService.tarifs allObjects] objectAtIndex:indexPath.section]).bookingRate];
                break;
            case 1:
                cell.textLabel.text = @"Тариф за км";    
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",((Tarif *)[[taxiService.tarifs allObjects] objectAtIndex:indexPath.section]).kmRate];
                break;
            case 2:
                cell.textLabel.text = @"Включено км:";    
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",((Tarif *)[[taxiService.tarifs allObjects] objectAtIndex:indexPath.section]).bookingKmIncluded];
                break;
            default:
                break;
        }
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == 0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",((Phone *)[[taxiService.phones allObjects] objectAtIndex:indexPath.row]).phoneNumber]]];

    }
    
}


@end
