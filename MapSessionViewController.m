//
//  MapSessionViewController.m
//  Encounter
//
//  Created by Dominic Ong on 12/24/13.
//  Copyright (c) 2013 DOngJKau. All rights reserved.
//

#import "MapSessionViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Firebase/Firebase.h>
#import <GoogleMapsDirection/GMDirection.h>
#import <GoogleMapsDirection/GMDirectionService.h>
#import <GoogleMapsDirection/GMHTTPClient.h>

@interface MapSessionViewController()
@property (weak, nonatomic) IBOutlet UINavigationItem *mapNavigationBar;

@end


@implementation MapSessionViewController{
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
    BOOL mapHasLoaded_;
    NSString *sessionUrl;
    NSString *usersUrl;
    Firebase *session;
    Firebase *users;
    __block NSDictionary *deviceMap;
    NSDictionary *deviceCoordinates;
    NSMutableArray *markers_;
    NSString *UUID;
}

-(void) viewWillDisappear:(BOOL)animated{
    [session removeAllObservers];
    [session observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSString *roomString = [NSString stringWithFormat:@"%04lu", _roomNumber];
        deviceMap = [snapshot childSnapshotForPath:roomString].value;
        NSMutableArray *usersInRoom = [deviceMap objectForKey:@"list"];
        [usersInRoom removeObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
        
        if([usersInRoom count] == 0){
            [[session childByAppendingPath:roomString] removeValue];
        }else{
            [[[session childByAppendingPath:roomString] childByAppendingPath:@"list"] setValue:usersInRoom];
        }
        
    }];
    
    deviceMap = nil;
    deviceCoordinates = nil;
    markers_ = nil;
    UUID = nil;
    session = nil;
    users = nil;
    mapView_ = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    sessionUrl = @"https://encounter-sessions.firebaseio.com/";
    usersUrl = @"https://encounter-users.firebaseio.com/";
    
    session = [[Firebase alloc] initWithUrl: sessionUrl];
    users = [[Firebase alloc] initWithUrl:usersUrl];
    
    markers_ = [[NSMutableArray alloc] init];
    
    mapHasLoaded_ = NO;
    
    UIBarButtonItem *fitBoundsButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Fit"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(didTapFitBounds)];
    self.navigationItem.rightBarButtonItem = fitBoundsButton;
    
    if(_numPeople == 1)
    {
        _mapNavigationBar.title = [NSString stringWithFormat:@"Room %lu: 1 person", self.roomNumber];
    }
    else
    {
        _mapNavigationBar.title = [NSString stringWithFormat:@"Room %lu: %lu people",self.roomNumber, self.numPeople];
    }
    
    [session observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSString *roomString = [NSString stringWithFormat:@"%04lu", _roomNumber];
        deviceMap = [snapshot childSnapshotForPath:roomString].value;
        NSMutableArray *usersInRoom = [deviceMap objectForKey:@"list"];
        int count = 0;
        for(id user in usersInRoom){
            if(![user isKindOfClass:[NSNull class]]){
                count++;
            }
        }
        _numPeople = count;
        
        //Update Nav Bar Title
        if(_numPeople == 1)
        {
            _mapNavigationBar.title = [NSString stringWithFormat:@"Room %lu: 1 person", self.roomNumber];
        }
        else
        {
            _mapNavigationBar.title = [NSString stringWithFormat:@"Room %lu: %lu people",self.roomNumber, self.numPeople];
        }
        
    }];
     
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:12];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    mapView_.mapType = kGMSTypeNormal;
    
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
    self.view = mapView_;
    //[self.view addSubview: mapView_];
    
    //Track All Room Participants
    [users observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSMutableArray *originalUsers = [deviceMap objectForKey:@"list"];
        
        NSMutableArray *usersInRoom = [[NSMutableArray alloc] init];
        NSMutableArray *coordinates = [[NSMutableArray alloc] init];
        for(NSString *user in originalUsers){
            if(![user isKindOfClass:[NSNull class]]){
                [usersInRoom addObject:user];
                [coordinates addObject:[snapshot childSnapshotForPath: user].value];
            }
        }
        
        NSDictionary *userCoordinates = [[NSDictionary alloc] initWithObjects:coordinates forKeys: usersInRoom];
        
        [mapView_ clear];
        [markers_ removeAllObjects];
        for(NSString *user in userCoordinates){
            double lat = [(NSString *)[[userCoordinates objectForKey:user] objectForKey:@"latitude"] doubleValue];
            double lon = [(NSString *)[[userCoordinates objectForKey:user] objectForKey:@"longitude"] doubleValue];
            CLLocationCoordinate2D position = CLLocationCoordinate2DMake(lat, lon);
            GMSMarker *marker = [GMSMarker markerWithPosition:position];
            [markers_ addObject:marker];
            marker.map = mapView_;
        }
        
        NSString *origin = [NSString stringWithFormat:@"%@,%@", [[userCoordinates objectForKey:UUID] objectForKey:@"latitude"],[[userCoordinates objectForKey:UUID] objectForKey:@"longitude"]];
        [markers_ removeObject:UUID];
        
        for(NSString *user in userCoordinates){
            NSString *destination = [NSString stringWithFormat:@"%@,%@", [[userCoordinates objectForKey:user] objectForKey:@"latitude"],[[userCoordinates objectForKey:user] objectForKey:@"longitude"]];
            [[GMDirectionService sharedInstance] getDirectionsFrom: origin
                                                                to:destination
                                                   withTransitType:@"walking"
                                                         succeeded:^(GMDirection *directionResponse) {
                if([directionResponse statusOK]){
                    NSLog(@"Duration : %@", [directionResponse durationHumanized]);
                    NSLog(@"Distance : %@", [directionResponse distanceHumanized]);
                    
                    NSArray *routes = [[directionResponse directionResponse] objectForKey:@"routes"];
                    
                    GMSPath *path = [GMSPath pathFromEncodedPath:routes[0][@"overview_polyline"]  [@"points"]];
                    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
                    polyline.strokeColor = [UIColor redColor];
                    polyline.strokeWidth = 5.f;
                    polyline.map = mapView_;

                }
            } failed:^(NSError *error) {
                NSLog(@"Can't reach the server");
            }];
        }
        
        
        
        
    }];
    
    // Add elements on top of the map view (Found!, Zoom In/Out)
    UIButton *foundButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [foundButton setTitle:@"" forState:UIControlStateNormal];
    //[foundButton setTitle:@"selected" forState:UIControlStateSelected];
    //breaks code for some reason
    UIImage *foundButtonImage = [UIImage imageNamed: @"ic_found.png"];
    //UIImage *foundButtonPressedImage = [UIImage imageNamed:@"ic_found_blue.png"];
    [foundButton setBackgroundImage: foundButtonImage forState: UIControlStateNormal];
    //[foundButton setBackgroundImage:foundButtonPressedImage forState:UIControlStateSelected];
    int x = mapView_.bounds.size.width - 240;
    int y = mapView_.bounds.size.height - 60;
    foundButton.frame = CGRectMake(x, y, 160, 40);
    foundButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [foundButton addTarget:self action:@selector(foundButton:) forControlEvents:UIControlEventTouchUpInside];
    [mapView_ addSubview: foundButton];
}

- (void)dealloc {
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}


-(IBAction)foundButton:(UIButton *)sender{
    //MAKE FOUND BUTTON UNWIND SEGUE
     [self dismissViewControllerAnimated:YES completion:^{
     }];
}

- (void)didTapFitBounds {
    GMSCoordinateBounds *bounds;
    for (GMSMarker *marker in markers_) {
        if (bounds == nil) {
            bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:marker.position
                                                          coordinate:marker.position];
        }
        bounds = [bounds includingCoordinate:marker.position];
    }
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds
                                             withPadding:100.0f];
    [mapView_ moveCamera:update];
}

#pragma mark - KVO updates

-(void)refreshMyLocation{
    firstLocationUpdate_ = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        
        NSNumber *latitude = [[NSNumber alloc] initWithDouble:location.coordinate.latitude];
        NSNumber *longitude = [[NSNumber alloc] initWithDouble:location.coordinate.longitude];
        
        NSArray *coordinates = [[NSArray alloc] initWithObjects:latitude, longitude, nil];
        NSArray *stringCoord = [[NSArray alloc] initWithObjects:[latitude stringValue], [longitude stringValue], nil];
        NSArray *keys = [[NSArray alloc] initWithObjects:@"latitude", @"longitude", nil];
        
        NSDictionary *userCoordinates = [[NSDictionary alloc] initWithObjects:coordinates forKeys:keys];
        NSDictionary *userStringCoord = [[NSDictionary alloc] initWithObjects:stringCoord forKeys:keys];
        double lat = [[userCoordinates objectForKey:@"latitude"] doubleValue];
        double lon = [[userCoordinates objectForKey:@"longitude"] doubleValue];
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(lat, lon);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        [markers_ addObject:marker];
        marker.map = mapView_;

        //Add/Update user in the encounter-users

        [[users childByAppendingPath: UUID] setValue:userStringCoord];
        if(!mapHasLoaded_){
            mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:14];
            mapHasLoaded_ = YES;
        }
        [self performSelector:@selector(refreshMyLocation) withObject:nil afterDelay:10.0];
    }else{
        
    }
}

@end
