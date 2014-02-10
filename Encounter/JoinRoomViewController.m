//
//  JoinRoomViewController.m
//  Encounter
//
//  Created by Dominic Ong on 12/24/13.
//  Copyright (c) 2013 DOngJKau. All rights reserved.
//

#import "JoinRoomViewController.h"
#import "MapSessionViewController.h"
#import <Firebase/Firebase.h>


@interface JoinRoomViewController()

@property (weak, nonatomic) IBOutlet UITextField *pinTextField;
- (IBAction)confirmButton:(UIButton *)sender;
@property (strong, nonatomic)UITapGestureRecognizer *tap;
@property CGPoint originalCenter;
@property UIAlertView *alertMsg;

@end

@implementation JoinRoomViewController{
    NSString *sessionUrl;
    NSString *usersUrl;
    Firebase *session;
    Firebase *users;
    __block NSDictionary *usedPins;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Join Map"]){
        if([segue.destinationViewController isKindOfClass:[MapSessionViewController class]]){
            MapSessionViewController *msvc = (MapSessionViewController *)segue.destinationViewController;
            unsigned long roomNum = [_pinTextField.text intValue];
            msvc.roomNumber = roomNum;
            [session observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot){
                NSString *roomString = [NSString stringWithFormat:@"%04lu", roomNum];
                NSDictionary *listMap = [snapshot childSnapshotForPath: roomString].value;
                NSMutableArray *deviceList = [listMap objectForKey:@"list"];
                
                if(![deviceList containsObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString]]){
                    [deviceList addObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
                }
                
                msvc.numPeople = deviceList.count;
                
                [[[session childByAppendingPath:roomString] childByAppendingPath:@"list"] setValue:deviceList];
            }];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}

-(void)viewDidLoad
{
    NSLog(@"Join Room View");
    sessionUrl = @"https://encounter-sessions.firebaseio.com/";
    usersUrl = @"https://encounter-users.firebaseio.com/";
    
    session = [[Firebase alloc] initWithUrl: sessionUrl];
    users = [[Firebase alloc] initWithUrl:usersUrl];

    [session observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot){
        usedPins = snapshot.value;
    }];

    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    _tap.enabled = NO;
    [self.view addGestureRecognizer:_tap];
    self.originalCenter = self.view.center;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    _tap.enabled = YES;
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - 100);
}

-(void)hideKeyboard
{
    self.view.center = self.originalCenter;
    [_pinTextField resignFirstResponder];
    _tap.enabled = NO;
}

-(BOOL)roomPinIsValid:(int)roomPin{
    if(usedPins == nil){
        return NO;
    }else{
        int existingRoom;
        for(id key in usedPins){
            existingRoom = [[NSString stringWithFormat:@"%@", key] intValue];
            if(roomPin == existingRoom)
                return YES;
        }
    }
    return NO;
}

- (IBAction)confirmButton:(UIButton *)sender {
    if([_pinTextField.text length] == 4)
    {
        int roomNum = [_pinTextField.text intValue];
        
        if([self roomPinIsValid:roomNum])
            [self performSegueWithIdentifier:@"Join Map" sender:self];
        else
        {
            _alertMsg = [[UIAlertView alloc] initWithTitle:@"Oh dear..." message:@"The Room Does Exist!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
            [_alertMsg show];
        }
    }
    else
    {
        _alertMsg = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please Enter A Pin With 4 Numbers" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [_alertMsg show];
    }
}
@end
