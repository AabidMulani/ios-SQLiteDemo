//
//  ViewController.h
//  SQLITETutorial
//
//  Created by Magneto on 7/26/14.
//  Copyright (c) 2014 Magneto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "Person.h"
@interface ViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *arrOfPerson;
    sqlite3 *db;
    NSString *dbPathString;
}
@property (strong, nonatomic) IBOutlet UITextField *txtName;
@property (strong, nonatomic) IBOutlet UITextField *txtAge;
@property (strong, nonatomic) IBOutlet UIButton *btnAdd;
@property (strong, nonatomic) IBOutlet UIButton *btnDisplay;
@property (strong, nonatomic) IBOutlet UIButton *btnDelete;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
- (IBAction)addPerson:(id)sender;
- (IBAction)deletePerson:(id)sender;
- (IBAction)displayList:(id)sender;

@end
