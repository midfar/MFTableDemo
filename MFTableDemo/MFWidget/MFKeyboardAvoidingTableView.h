//
//  MFKeyboardAvoidingTableView.h
//  MFTableDemo
//
//  Created by Michael Tyson on 30/09/2013.
//  Copyright 2013 A Tasty Pixel. All rights reserved.
//
//  Modified by Midfar Sun on 4/16/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MFKeyboardAvoidingState : NSObject
@property (nonatomic, assign) UIEdgeInsets priorInset;
@property (nonatomic, assign) UIEdgeInsets priorScrollIndicatorInsets;
@property (nonatomic, assign) BOOL         keyboardVisible;
@property (nonatomic, assign) CGRect       keyboardRect;
@property (nonatomic, assign) CGSize       priorContentSize;

@property (nonatomic) BOOL priorPagingEnabled;
@end

@interface MFKeyboardAvoidingTableView : UITableView

- (MFKeyboardAvoidingState*)keyboardAvoidingState;

@end
