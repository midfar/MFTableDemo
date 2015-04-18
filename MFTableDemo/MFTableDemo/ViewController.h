//
//  ViewController.h
//  MFTableDemo
//
//  Created by Midfar Sun on 4/15/15.
//  Copyright (c) 2015 Midfar Sun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFKeyboardAvoidingTableView.h"

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet MFKeyboardAvoidingTableView *mTableView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

- (IBAction)editButtonClicked:(id)sender;
- (IBAction)deleteButtonClicked:(id)sender;
- (IBAction)hideKeyboardButtonClicked:(id)sender;


@end

