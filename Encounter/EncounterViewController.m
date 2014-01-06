//
//  EncounterViewController.m
//  Encounter
//
//  Created by Dominic Ong on 12/23/13.
//  Copyright (c) 2013 DOngJKau. All rights reserved.
//

#import "EncounterViewController.h"
#import "CreateRoomViewController.h"

@interface EncounterViewController ()
@property (weak, nonatomic) IBOutlet UIButton *createRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *joinRoomButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *masterNavigationBar;

@end

@implementation EncounterViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.navigationController.navigationBar.hidden = NO;
    /*
    if([segue.identifier isEqualToString:@"Create Room"])
    {
        if([segue.destinationViewController isKindOfClass:[CreateRoomViewController class]]){
            //CreateRoomViewController *crvs = (CreateRoomViewController *)segue.destinationViewController;
        }
    }
     */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Hide the Navigation bar for the home screen
    self.navigationController.navigationBar.hidden = YES;
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
