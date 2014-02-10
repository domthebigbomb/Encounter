//
//  CreateRoomViewController.m
//  Encounter
//
//  Created by Dominic Ong on 12/24/13.
//  Copyright (c) 2013 DOngJKau. All rights reserved.
//

#import "CreateRoomViewController.h"
#import "MapSessionViewController.h"
#import "EncounterViewController.h"
#import <Firebase/Firebase.h>

@interface CreateRoomViewController()
@property (weak, nonatomic) IBOutlet UILabel *pinLabel;
- (IBAction)confirmButton:(UIButton *)sender;
@property UIAlertView *alertMsg;
@end

@implementation CreateRoomViewController{
    NSString *sessionUrl;
    NSString *usersUrl;
    Firebase *session;
    Firebase *users;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Create Map"]){
        if([segue.destinationViewController isKindOfClass:[MapSessionViewController class]]){
            MapSessionViewController *msvc = (MapSessionViewController *)segue.destinationViewController;
            unsigned long roomNum = [_pinLabel.text intValue];
            msvc.roomNumber = roomNum;
            NSString *roomString = [NSString stringWithFormat:@"%04lu", roomNum];
            msvc.numPeople = 1;
            NSArray *singleUser = [[NSArray alloc] initWithObjects:[[[UIDevice currentDevice] identifierForVendor] UUIDString], nil];
            [[[session childByAppendingPath: roomString]childByAppendingPath:@"list"] setValue: singleUser];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}


-(void)viewDidLoad
{
    //Generate a random Pin and check it against Pins in firebase
    sessionUrl = @"https://encounter-sessions.firebaseio.com/";
    usersUrl = @"https://encounter-users.firebaseio.com/";
    
    session = [[Firebase alloc] initWithUrl: sessionUrl];
    users = [[Firebase alloc] initWithUrl:usersUrl];
    
    [self generateRoomPin];
}

-(void)generateRoomPin{
    __block int randPin = 5974; //force test of existing room
    
    [session observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot){
        NSDictionary* usedPins = snapshot.value;
        int usedPin;
        BOOL found;
        do{
            found = NO;
            
            for(id key in usedPins){
                usedPin = [[NSString stringWithFormat:@"%@", key] intValue];
                if(randPin == usedPin){
                    found = YES;
                    
                    randPin = arc4random() % (9999 - 1000 +1) + 1000;
                    // pins can be anywhere 1000 - 9999
                    
                }
            }
        }while(found == YES);
        _pinLabel.text = [NSString stringWithFormat:@"%d", randPin];

    }];
}


- (IBAction)confirmButton:(UIButton *)sender {
    if([_pinLabel.text length] == 4){
        int roomPin = [_pinLabel.text intValue];
        
        //Check if the Pin is still valid at time of creation
        [session observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            NSDictionary *usedPins = snapshot.value;
            int usedPin;
            BOOL found = NO;
            for(id key in usedPins){
                usedPin = [[NSString stringWithFormat:@"%@",key] intValue];
                if(roomPin == usedPin){
                    found = YES;
                }
            }
            if(found){
                _alertMsg = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"Pin Is No Longer Available" delegate:nil cancelButtonTitle:@"Generate New Pin" otherButtonTitles: nil];
                [_alertMsg show];
                [self generateRoomPin];
            }else{
                [[session childByAppendingPath:[NSString stringWithFormat:@"%d",roomPin]]
                 setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
                [self performSegueWithIdentifier:@"Create Map" sender:self];
            }
            
        }];
        
    }else{
        _alertMsg = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please Wait To Generate A Pin" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [_alertMsg show];
    }
}

@end
