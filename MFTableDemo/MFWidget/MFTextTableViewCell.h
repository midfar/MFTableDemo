//
//  MFTextTableViewCell.h
//  MFTableDemo
//
//  Created by Midfar Sun on 4/15/15.
//  Copyright (c) 2015 Midfar Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFTextTableViewCell;
@protocol MFTextTableViewCellDelegate <NSObject>

/**
 用户点击了键盘的[回车]按钮
 */
-(void)mfTextTableViewCell:(MFTextTableViewCell *)cell textFieldShouldReturn:(NSString *)text;
/**
 实时监听用户输入的内容。由于cell重用时会导致获取的indexPath不正确，所以这里要实时监听
 */
-(void)mfTextTableViewCell:(MFTextTableViewCell *)cell textFieldValueChanged:(NSString *)text;

@end

@interface MFTextTableViewCell : UITableViewCell

@property(weak, nonatomic)IBOutlet UITextField *mTextField;
@property(nonatomic, assign)id<MFTextTableViewCellDelegate> delegate;

@property(nonatomic, assign)BOOL mEditing;
@property(nonatomic, assign)BOOL mIsSupportMove;

- (void)setMText:(NSString *)text;
- (NSString *)getMText;

- (void)showMKeyboard;
//- (void)hideMKeyboard;

@end
