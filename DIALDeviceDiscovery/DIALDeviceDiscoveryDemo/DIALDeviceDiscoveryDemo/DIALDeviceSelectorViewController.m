//
//  TVSelectorViewController.m
//  TVCompanion
//
//  Created by Rajiv Ramdhany on 12/12/2014.
//  Copyright (c) 2014 BBC RD. All rights reserved.
//

#import "AppDelegate.h"
#import "DIALDeviceSelectorViewController.h"
#import "DIALDeviceViewConstants.h"
#import <SimpleLogger/SimpleLogger.h>


//------------------------------------------------------------------------------
#pragma mark - DIALDeviceSelectorViewController (Interface Extension)
//------------------------------------------------------------------------------

@interface DIALDeviceSelectorViewController()
{
    
}


@end


//------------------------------------------------------------------------------
#pragma mark - DIALDeviceSelectorViewController implementation
//------------------------------------------------------------------------------

@implementation DIALDeviceSelectorViewController
{
    NSArray                 *deviceList;
    NSMutableArray          *revisedDeviceList;
    DIALDevice              *selectedDIALDevice;
   /** A reference to our super-framework's delegate: the main configurator component */
    AppDelegate     *syncKitDelegate;
}


@synthesize tvDiscoveryComponent = _tvDiscoveryComponent;
@synthesize devicesTableView = _devicesTableView;
@synthesize parentView = _parentView;
@synthesize titleString = _titleString;
@synthesize segueIdentifier = _segueIdentifier;



//------------------------------------------------------------------------------
#pragma mark - Init, lifecycle methods
//------------------------------------------------------------------------------

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//------------------------------------------------------------------------------
#pragma mark - Setters and Getters
//------------------------------------------------------------------------------

- (void) setTitleString:(NSString *)str
{
    self.titleString = [str copy];
    self.title = self.titleString;
}

//------------------------------------------------------------------------------
#pragma mark - UIViewController methods
//------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // get a reference to app's SyncKit Delegate object
    syncKitDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // get a refrerence to a DIAL device discoverer
    _tvDiscoveryComponent = syncKitDelegate.DIALSDiscoveryComponent;
    
    // discovered apps
    deviceList =  [_tvDiscoveryComponent getDiscoveredDIALDevices];
    
    _parentView = self.view;
    self.title = @"Select DIAL device";
   
    _devicesTableView = [[UITableView alloc] initWithFrame:CGRectMake(_parentView.frame.origin.x, _parentView.frame.origin.y, _parentView.frame.size.width, _parentView.frame.size.height) style:UITableViewStylePlain];
    // customise appearance
    
    
    _devicesTableView.delegate = self;
    _devicesTableView.dataSource = self;
    
    _devicesTableView.backgroundColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1.0];
    
    [self.view addSubview:_devicesTableView];
    
    revisedDeviceList = [[NSMutableArray alloc] init];
    [revisedDeviceList addObjectsFromArray:deviceList];
    
    // add dummy app
    //[revisedDeviceList addObject:[self createDummyApp]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableTapped:)];
    [self.devicesTableView addGestureRecognizer:tap];
    
    // subscribe to notifications from device discovery component
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DIALServiceDiscoveryNotifcationReceived:) name:nil object:syncKitDelegate.DIALSDiscoveryComponent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RefreshDiscoveredDevicesNotificationReceived:) name:kRefreshDiscoveredDevicesNotification object:nil];
}

//------------------------------------------------------------------------------

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
}

//------------------------------------------------------------------------------


- (void) viewDidDisappear:(BOOL)animated
{
    
    // remove observer for notifications from DIALDiscovery component
    [[NSNotificationCenter defaultCenter]removeObserver:self name:nil object:_tvDiscoveryComponent];
    
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
#pragma mark - UITapGestureRecognizer callback method
//------------------------------------------------------------------------------

/**
 On tap, select the row tapped
 */
- (void)tableTapped:(UITapGestureRecognizer *)tap
{
    CGPoint location = [tap locationInView:_devicesTableView];
    NSIndexPath *path = [_devicesTableView indexPathForRowAtPoint:location];
    
    if(path)
    {
        // tap was on existing row, so pass it to the delegate method
        [self tableView:_devicesTableView didSelectRowAtIndexPath:path];
    }
    else
    {
        // don't do anything
    }
}

//------------------------------------------------------------------------------
#pragma mark - Notification handlers
//------------------------------------------------------------------------------

/**
 
 Handle RefreshDiscoveredDevicesNotification notification
 
 */
- (void) RefreshDiscoveredDevicesNotificationReceived: (NSNotification*) aNotification
{
    
    deviceList =  [_tvDiscoveryComponent getDiscoveredDIALDevices];
    [revisedDeviceList removeAllObjects];
    [revisedDeviceList addObjectsFromArray:deviceList];
    
    // add dummy app
    //[revisedDeviceList addObject:[self createDummyApp]];
    [_devicesTableView reloadData];
    
}

//------------------------------------------------------------------------------

/**
 Handle a received DIALServiceDiscoveryNotifcation
 */
- (void) DIALServiceDiscoveryNotifcationReceived: (NSNotification*) aNotification
{
    
    deviceList =  [_tvDiscoveryComponent getDiscoveredDIALDevices];
    [revisedDeviceList removeAllObjects];
    [revisedDeviceList addObjectsFromArray:deviceList];
    
    [_devicesTableView reloadData];
    
    
}

//------------------------------------------------------------------------------

/**
 Handle a received didReceiveCIIConnectionFailureNotification
 */
- (void) didReceiveCIIConnectionFailureNotification: (NSNotification*) aNotification
{
    
    deviceList =  [_tvDiscoveryComponent getDiscoveredDIALDevices];
    [revisedDeviceList removeAllObjects];
    [revisedDeviceList addObjectsFromArray:deviceList];
    
    [_devicesTableView reloadData];
    
}

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - TableView Delegate Methods
//------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    
    
    
    return [revisedDeviceList count];
    
}

//------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    static NSString *deviceTableIdentifier = @"DeviceTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:deviceTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deviceTableIdentifier];
        
    }
    
    DIALDevice* app = [revisedDeviceList objectAtIndex:indexPath.row];
    cell.backgroundColor  = [UIColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1.0];
    cell.textLabel.text =  app.friendlyName;
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    cell.imageView.image = [UIImage imageNamed:@"DIALTV_UI_ResourceBundle.bundle/tv_white_64x64.png"];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
    
}

//------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    selectedDIALDevice = [[revisedDeviceList objectAtIndex:indexPath.row]copyWithZone:nil];
    
    MWLogDebug(@"%@ master device selected, launching CII", selectedDIALDevice.friendlyName);
    
    
    syncKitDelegate.currentDIALDevice = selectedDIALDevice;
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue:selectedDIALDevice forKey:kNewDIAL_HbbTV_ServiceSelected];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewDIAL_HbbTV_ServiceSelected object:nil userInfo:dict];
    
    
    [self performSegueWithIdentifier:_segueIdentifier sender:self];

    
}

//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
#pragma mark - Other methods
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    
    
    
    
    
}






@end
