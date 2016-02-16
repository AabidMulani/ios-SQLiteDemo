//
//  ViewController.m
//  SQLITETutorial
//
//  Created by Magneto on 7/26/14.
//  Copyright (c) 2014 Magneto. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	arrOfPerson=[[NSMutableArray alloc]init];
    [self createOrOpenDb];
}
-(void)createOrOpenDb {
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[paths objectAtIndex:0];
    dbPathString=[path stringByAppendingPathComponent:@"Persons.sqlite3"];
    char *error;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    
    if (![fileManager fileExistsAtPath:dbPathString]) {
        const char *dbPath=[dbPathString UTF8String];
        ///Create Db///
        if (sqlite3_open(dbPath, &db)==SQLITE_OK) {
            const char *sql_stmt= "CREATE TABLE IF NOT EXISTS PERSONS (ID INTEGER PRIMARY KEY AUTOINCREMENT,NAME TEXT,AGE INTEGER)";
            sqlite3_exec(db, sql_stmt, NULL, NULL, &error);
            if (error) {
                NSLog(@"ERROR:%s",error);
            }
            sqlite3_close(db);
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addPerson:(id)sender {
    char *error;
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        NSString *insertSTMT=[NSString stringWithFormat:@"INSERT INTO PERSONS (NAME,AGE) VALUES ('%s','%d')",[self.txtName.text UTF8String],[self.txtAge.text intValue]];
        const char *insert_stmt=[insertSTMT UTF8String];
        if (sqlite3_exec(db, insert_stmt, NULL, NULL, &error)==SQLITE_OK) {
            NSLog(@"Person Added");
            [self.txtAge resignFirstResponder];
            [self.txtName resignFirstResponder];
            Person *person=[[Person alloc]init];
            person.name=self.txtName.text;
            person.age=[self.txtAge.text intValue];
            [arrOfPerson addObject:person];
            self.txtName.text=@"";
            self.txtAge.text=@"";
            [self.myTableView reloadData];
        }
        sqlite3_close(db);
    }
}

- (IBAction)deletePerson:(id)sender {
    [self.myTableView setEditing:!self.myTableView.editing animated:YES];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        Person *p=[arrOfPerson objectAtIndex:indexPath.row];
        [self deleteData:[NSString stringWithFormat:@"DELETE FROM PERSONS WHERE NAME IS '%s'",[p.name UTF8String]]];
        [arrOfPerson removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
-(void)deleteData:(NSString *)query{
    char *error;
    if (sqlite3_exec(db, [query UTF8String], NULL, NULL, &error)==SQLITE_OK) {
        NSLog(@"PERSON DELETED");
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (IBAction)displayList:(id)sender {
    sqlite3_stmt *statement;
    if (sqlite3_open([dbPathString UTF8String], &db)==SQLITE_OK) {
        [arrOfPerson removeAllObjects];
        NSString *sqlQuery=@"SELECT * FROM PERSONS";
        const char *query=[sqlQuery UTF8String];
        if (sqlite3_prepare(db, query,-1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSString *name=[[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                NSString *age=[[NSString alloc]initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                Person *person=[[Person alloc]init];
                person.name=name;
                person.age=[age intValue];
                [arrOfPerson addObject:person];
            }
            [self.myTableView reloadData];
        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrOfPerson.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    Person *person=[arrOfPerson objectAtIndex:indexPath.row];
    cell.textLabel.text=person.name;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%d",person.age];
    return cell;
}
@end
