//
//  MFTextTableViewCell.m
//  MFTableDemo
//
//  Created by Midfar Sun on 4/15/15.
//  Copyright (c) 2015 Midfar Sun. All rights reserved.
//

#import "MFTextTableViewCell.h"

//there maybe warning: no index path for table cell being reused
@interface MFTextTableViewCell()<UITextFieldDelegate>
{
    
}
@end

@implementation MFTextTableViewCell
@synthesize delegate;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        //NSLog(@"MFTextTableViewCell initWithCoder");
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //NSLog(@"MFTextTableViewCell initWithStyle:reuseIdentifier:%@", reuseIdentifier);
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [self initParams];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initParams
{
    [self setMEditing:NO];
    _mTextField.returnKeyType = UIReturnKeyDefault;
    _mTextField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MF_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MF_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setEditing:(BOOL)editing
{
    //NSLog(@"MFTextTableViewCell setEditing:%d", editing);
    [super setEditing:editing];
    [self setMEditing:editing];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    //NSLog(@"MFTextTableViewCell setEditing:%d animated:%d", editing, animated);
    [super setEditing:editing animated:animated];
    [self setMEditing:editing];
}

#pragma mark - Notification
-(void)MF_keyboardWillShow:(NSNotification *)notification
{
    //当前行在编辑状态时移动会造成数据错误，所以编辑状态不让移动cell
    self.showsReorderControl = NO;//no effect in iOS7.1 simulator
}

-(void)MF_keyboardWillHide:(NSNotification *)notification
{
    self.showsReorderControl = _mIsSupportMove;
}

#pragma mark - Function
- (void)setMText:(NSString *)text
{
    _mTextField.text = text;
}

- (NSString *)getMText
{
    return _mTextField.text;
}

- (void)setMEditing:(BOOL)mEditing
{
    _mEditing = mEditing;
    _mTextField.enabled = _mEditing;
}

- (void)showMKeyboard
{
    [_mTextField becomeFirstResponder];
}

- (void)hideMKeyboard
{
    [_mTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (delegate && [delegate respondsToSelector:@selector(mfTextTableViewCell:textFieldShouldReturn:)]) {
        [delegate mfTextTableViewCell:self textFieldShouldReturn:textField.text];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (delegate && [delegate respondsToSelector:@selector(mfTextTableViewCell:textFieldValueChanged:)]) {
        NSMutableString *text = [NSMutableString stringWithString:textField.text];
        [text replaceCharactersInRange:range withString:string];
        [delegate mfTextTableViewCell:self textFieldValueChanged:text];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

@end
