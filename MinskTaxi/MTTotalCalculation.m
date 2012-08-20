//
//  MTTotalCalculation.m
//  MinskTaxi
//
//  Created by ml on 10/10/11.
//  Copyright 2011 ml. All rights reserved.
//

#import "MTTotalCalculation.h"
#import "SHK.h"

@implementation MTTotalCalculation

@synthesize calculableTaxiService = _calculableTaxiService , googleCalculatedTaxiService = _googleCalculatedTaxiService;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

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

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.title = NSLocalizedString(@"Total", @"");

    
    UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",@"") style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    self.navigationItem.backBarButtonItem = backButton;
    self.navigationController.toolbar.hidden = NO;
  
   // self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)] autorelease];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (void) dealloc{
    
    [_googleCalculatedTaxiService release];
    [_calculableTaxiService release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - IBActions
- (IBAction)paid:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)share:(id)sender {
    
    NSString *text = [NSString stringWithFormat:@"@MinskTaxi test!"];
  	
	SHKItem *item = [SHKItem text:text];
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	
	[actionSheet showFromToolbar:self.navigationController.toolbar];

}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return @"Калькуляция";
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
        //need to refactor
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Расстояние";    
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",_calculableTaxiService.tripDistance];
                break;
            case 1:
                cell.textLabel.text = @"Стоимость";    
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",_calculableTaxiService.tripPrice];
                break;

            default:
                break;
        }
    
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    
}

- (void) setCalculableTaxiService:(CalculableTaxiService *)calculableTaxiServiceIn{
    
    [_calculableTaxiService release];
    _calculableTaxiService = [calculableTaxiServiceIn retain];
    
}

- (void) setGoogleCalculatedTaxiService:(CalculableTaxiService *)googleCalculatedTaxiServiceIn{

    [_googleCalculatedTaxiService release];
    _googleCalculatedTaxiService = [googleCalculatedTaxiServiceIn retain];
    
}

@end
