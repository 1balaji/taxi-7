//
//  MTTaxiServicesList.m
//  MinskTaxi
//
//  Created by ml on 10/10/11.
//  Copyright 2011 ml. All rights reserved.
//

#import "MTTaxiServicesList.h"
#import "MTTaxiServiceDetails.h"
#import "TaxiService.h"
#import <QuartzCore/QuartzCore.h>

@implementation MTTaxiServicesList
@synthesize scrollView;
@synthesize table;
@synthesize managedObjectContext;

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

    self.table.layer.borderWidth = 1;
	self.table.layer.borderColor = [UIColor whiteColor].CGColor;
	self.table.layer.cornerRadius = 10;
    
    self.navigationController.navigationBarHidden = NO;
    UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",@"") style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    self.navigationItem.backBarButtonItem = backButton;

    self.navigationItem.title = NSLocalizedString(@"TaxiServises", nil);
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"TaxiService" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    NSError *error = nil;
    taxiServicesList = [[managedObjectContext executeFetchRequest:request error:&error] retain];
    
    
    self.table.frame = CGRectMake(table.frame.origin.x, table.frame.origin.y, table.frame.size.width, 44 * [taxiServicesList count]);
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, table.frame.origin.y + table.frame.size.height);
    self.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0 , 80.0 , 0.0);
    
}

- (void)viewDidUnload
{
    [self setTable:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions
- (void) goBack{
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [taxiServicesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[[taxiServicesList objectAtIndex:indexPath.row] name]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[(TaxiService *)[taxiServicesList objectAtIndex:indexPath.row] descriptions]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTTaxiServiceDetails *detailViewController = [[MTTaxiServiceDetails alloc] init];
    detailViewController.taxiService = [taxiServicesList objectAtIndex:[indexPath row]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (void)dealloc {
    [managedObjectContext release];
    [taxiServicesList release];
    [table release];
    [scrollView release];
    [super dealloc];
}
@end
