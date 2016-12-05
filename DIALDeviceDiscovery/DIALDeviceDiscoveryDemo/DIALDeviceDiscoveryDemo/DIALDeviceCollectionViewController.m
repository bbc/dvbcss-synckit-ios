//
//  DIALDeviceCollectionViewController.m
//  Acolyte
//
//  Created by Rajiv Ramdhany on 10/02/2015.
//  Copyright (c) 2015 BBC RD. All rights reserved.
//

#import <SimpleLogger/SimpleLogger.h>
#import "DIALDeviceCollectionViewController.h"
#import "CollectionViewFlowLargeLayout.h"
#import "DeviceCollectionViewCell.h"
#import "AppDelegate.h"

//------------------------------------------------------------------------------
#pragma mark - Constant Declarations
//------------------------------------------------------------------------------

NSString const *SEGUE_ID = @"DeviceCollectionViewToExperiencesView";

//------------------------------------------------------------------------------
#pragma mark - DIALDeviceCollectionViewController (Interface Extension)
//------------------------------------------------------------------------------

@interface DIALDeviceCollectionViewController ()
{
    
}

@end


//------------------------------------------------------------------------------
#pragma mark - DIALDeviceCollectionViewController implementation
//------------------------------------------------------------------------------

@implementation DIALDeviceCollectionViewController
{
    /** A reference to our super-framework's delegate: the main configurator component */
    AppDelegate          *appdelegate;
    NSArray              *deviceList;
    NSMutableArray       *revisedDeviceList;
    DIALDevice           *selectedDIALDevice;
   
}

@synthesize tvDiscoveryComponent = _tvDiscoveryComponent;
@synthesize devicesCollectionView = _devicesCollectionView;
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



//------------------------------------------------------------------------------
#pragma mark - UIViewController methods
//------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.14 green:0.14 blue:0.14 alpha:1.0];
    
    // get a reference to app's delegate object
    appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // get a refrerence to a DIAL device discoverer
    _tvDiscoveryComponent = appdelegate.DIALSDiscoveryComponent;
    
    // discovered apps
    deviceList =  [_tvDiscoveryComponent getDiscoveredDIALDevices];
    revisedDeviceList = [[NSMutableArray alloc] init];
    [revisedDeviceList addObjectsFromArray:deviceList];
    
    _parentView = self.view;
    self.title = @"Which TV?";
    
    CollectionViewFlowLargeLayout *largeLayout = [[CollectionViewFlowLargeLayout alloc] init];
    
    
    // create a collection view for devices
    _devicesCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 10, self.view.frame.origin.y +10, self.view.frame.size.width -20 , self.view.frame.size.height -20) collectionViewLayout:largeLayout];
    [self.devicesCollectionView registerClass:[DeviceCollectionViewCell class] forCellWithReuseIdentifier:@"DIALTVCellIdentifier"];
    _devicesCollectionView.dataSource = self;
    _devicesCollectionView.delegate = self;
    _devicesCollectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    // register class for collection view cell
    
    self.devicesCollectionView.backgroundColor = [UIColor clearColor];
    
    [_parentView addSubview:self.devicesCollectionView];
    
    _segueIdentifier = (NSString*) SEGUE_ID;
    
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collectionTapped:)];
//    [self.devicesCollectionView addGestureRecognizer:tap];
    
    // subscribe to notifications from device discovery component
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DIALServiceDiscoveryNotifcationReceived:) name:nil object:appdelegate.DIALSDiscoveryComponent];
    
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
#pragma mark - UICollectionViewDataSource methods
//------------------------------------------------------------------------------


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    return [revisedDeviceList count];
    
}

//------------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

//------------------------------------------------------------------------------

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DeviceCollectionViewCell *cell =  [cv dequeueReusableCellWithReuseIdentifier:@"DIALTVCellIdentifier" forIndexPath:indexPath];
    
     DIALDevice* app = [revisedDeviceList objectAtIndex:indexPath.row];
    
    cell.backgroundColor = [UIColor clearColor];
    [cell setImage:[UIImage imageNamed:@"DIALTV_UI_ResourceBundle.bundle/television_480x480.png"]];
    //[cell setLabelText:@"Samsung 48U6400"];
    [cell setLabelText:app.friendlyName];
    //[cell setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg", indexPath.item % 4]]];
    
    return cell;
}

//------------------------------------------------------------------------------

- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }


//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - UICollectionViewDelegate methods
//------------------------------------------------------------------------------


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedDIALDevice = [[revisedDeviceList objectAtIndex:indexPath.row]copyWithZone:nil];

    
    MWLogDebug(@"%@ master device selected, launching CII", selectedDIALDevice.friendlyName);
    
    
    appdelegate.currentDIALDevice = selectedDIALDevice;
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue:selectedDIALDevice forKey:kNewDIAL_HbbTV_ServiceSelected];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewDIAL_HbbTV_ServiceSelected object:nil userInfo:dict];
    
    
    [self performSegueWithIdentifier:_segueIdentifier sender:self];
}




//------------------------------------------------------------------------------
#pragma mark - UITapGestureRecognizer handlers
//------------------------------------------------------------------------------

- (void)collectionTapped:(UITapGestureRecognizer *)tap
{
    CGPoint location = [tap locationInView: _devicesCollectionView];
    NSIndexPath *path = [_devicesCollectionView indexPathForItemAtPoint:location];
    
    if(path)
    {
        // tap was on existing row, so pass it to the delegate method
        [self collectionView:_devicesCollectionView didDeselectItemAtIndexPath:path];
    }
    else
    {
        // don't do anything
    }
}


//------------------------------------------------------------------------------
#pragma mark - notification handlers
//------------------------------------------------------------------------------


- (void) RefreshDiscoveredDevicesNotificationReceived: (NSNotification*) aNotification
{
    
    deviceList =  [_tvDiscoveryComponent getDiscoveredDIALDevices];
    [revisedDeviceList removeAllObjects];
    [revisedDeviceList addObjectsFromArray:deviceList];
    
   
    [_devicesCollectionView reloadData];
    
}

//------------------------------------------------------------------------------

- (void) DIALServiceDiscoveryNotifcationReceived: (NSNotification*) aNotification
{
    
    deviceList =  [_tvDiscoveryComponent getDiscoveredDIALDevices];
    [revisedDeviceList removeAllObjects];
    [revisedDeviceList addObjectsFromArray:deviceList];
    
    
    [_devicesCollectionView reloadData];
    
    
}

//------------------------------------------------------------------------------

- (void) didReceiveCIIConnectionFailureNotification: (NSNotification*) aNotification
{
    
    deviceList =  [_tvDiscoveryComponent getDiscoveredDIALDevices];
    [revisedDeviceList removeAllObjects];
    [revisedDeviceList addObjectsFromArray:deviceList];
    
    
    [_devicesCollectionView reloadData];
    
}

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - utility methods
//------------------------------------------------------------------------------


- (void) printViewControllersInNavStack
{
    MWLogDebug(@"\nDIALDeviceCollectionViewController didSelectItemAtIndexPath before segue, controllers in navigationController: " );
    NSArray *viewControllers = [[self navigationController] viewControllers];
    for(UIViewController *vc in viewControllers){
        MWLogDebug(@"---------> %@", [vc description]  );
    }
}


//------------------------------------------------------------------------------

@end
