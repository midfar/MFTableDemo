//
//  MFKeyboardAvoidingTableView.m
//  MFTableDemo
//
//  Created by Midfar Sun on 4/16/15.
//  Copyright (c) 2015 Midfar Sun. All rights reserved.
//

#import "MFKeyboardAvoidingTableView.h"
#import <objc/runtime.h>

//static const CGFloat kCalculatedContentPadding = 10;
static const CGFloat kMinimumScrollOffsetPadding = 20;

static const int kStateKey;
#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

@interface MFKeyboardAvoidingState : NSObject
@property (nonatomic, assign) UIEdgeInsets priorInset;
@property (nonatomic, assign) UIEdgeInsets priorScrollIndicatorInsets;
@property (nonatomic, assign) BOOL         keyboardVisible;
@property (nonatomic, assign) CGRect       keyboardRect;
@property (nonatomic, assign) CGSize       priorContentSize;

@property (nonatomic) BOOL priorPagingEnabled;
@end
@implementation MFKeyboardAvoidingState
@end

@implementation MFKeyboardAvoidingTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (MFKeyboardAvoidingState*)keyboardAvoidingState {
    MFKeyboardAvoidingState *state = objc_getAssociatedObject(self, &kStateKey);
    if ( !state ) {
        state = [[MFKeyboardAvoidingState alloc] init];
        objc_setAssociatedObject(self, &kStateKey, state, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#if !__has_feature(objc_arc)
        [state release];
#endif
    }
    return state;
}

- (void)setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MF_keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MF_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

//- (instancetype)initWithCoder:(NSCoder *)coder
//{
//    self = [super initWithCoder:coder];
//    if (self) {
//        [self setup];
//    }
//    return self;
//}

-(void)awakeFromNib
{
    [self setup];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self MF_updateContentInset];
}

-(void)setContentSize:(CGSize)contentSize {
    if (CGSizeEqualToSize(contentSize, self.contentSize)) {
        // Prevent triggering contentSize when it's already the same
        // this cause table view to scroll to top on contentInset changes
        return;
    }
    [super setContentSize:contentSize];
    [self MF_updateContentInset];
}

#pragma mark - Notification
//TextField切换时，会依次调用show-hide-show，这里需要做延时判断
-(void)MF_keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardRect = [self convertRect:[[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    if (CGRectIsEmpty(keyboardRect)) {
        return;
    }
    
    MFKeyboardAvoidingState *state = self.keyboardAvoidingState;
    
    UIView *firstResponder = [self MF_findFirstResponderBeneathView:self];
    
    if ( !firstResponder ) {
        return;
    }
    
    state.keyboardRect = keyboardRect;
    
    if ( !state.keyboardVisible ) {
        state.priorInset = self.contentInset;
        state.priorScrollIndicatorInsets = self.scrollIndicatorInsets;
        state.priorPagingEnabled = self.pagingEnabled;
    }
    
    state.keyboardVisible = YES;
    self.pagingEnabled = NO;
    
    //if ( [self isKindOfClass:[TPKeyboardAvoidingScrollView class]] ) {
    //    state.priorContentSize = self.contentSize;
    //    
    //    if ( CGSizeEqualToSize(self.contentSize, CGSizeZero) ) {
    //        // Set the content size, if it's not set. Do not set content size explicitly if auto-layout
    //        // is being used to manage subviews
    //        self.contentSize = [self TPKeyboardAvoiding_calculatedContentSizeFromSubviewFrames];
    //    }
    //}
    
    // Shrink view's inset by the keyboard's height, and scroll to show the text field/view being edited
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    
    self.contentInset = [self MF_contentInsetForKeyboard];
    
    CGFloat viewableHeight = self.bounds.size.height - self.contentInset.top - self.contentInset.bottom;
    [self setContentOffset:CGPointMake(self.contentOffset.x,
                                       [self MF_idealOffsetForView:firstResponder
                                                             withViewingAreaHeight:viewableHeight])
                  animated:NO];
    
    self.scrollIndicatorInsets = self.contentInset;
    [self layoutIfNeeded];
    
    [UIView commitAnimations];
}

-(void)MF_keyboardWillHide:(NSNotification *)notification
{
    CGRect keyboardRect = [self convertRect:[[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    if (CGRectIsEmpty(keyboardRect)) {
        return;
    }
    
    MFKeyboardAvoidingState *state = self.keyboardAvoidingState;
    
    if ( !state.keyboardVisible ) {
        return;
    }
    
    state.keyboardRect = CGRectZero;
    state.keyboardVisible = NO;
    
    // Restore dimensions to prior size
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    
    //if ( [self isKindOfClass:[TPKeyboardAvoidingScrollView class]] ) {
    //    self.contentSize = state.priorContentSize;
    //}
    
    self.contentInset = state.priorInset;
    self.scrollIndicatorInsets = state.priorScrollIndicatorInsets;
    self.pagingEnabled = state.priorPagingEnabled;
    [self layoutIfNeeded];
    [UIView commitAnimations];
}

#pragma mark - Function
- (UIEdgeInsets)MF_contentInsetForKeyboard {
    MFKeyboardAvoidingState *state = self.keyboardAvoidingState;
    UIEdgeInsets newInset = self.contentInset;
    CGRect keyboardRect = state.keyboardRect;
    newInset.bottom = keyboardRect.size.height - MAX((CGRectGetMaxY(keyboardRect) - CGRectGetMaxY(self.bounds)), 0);
    return newInset;
}

-(CGFloat)MF_idealOffsetForView:(UIView *)view withViewingAreaHeight:(CGFloat)viewAreaHeight {
    CGSize contentSize = self.contentSize;
    CGFloat offset = 0.0;
    
    CGRect subviewRect = [view convertRect:view.bounds toView:self];
    
    // Attempt to center the subview in the visible space, but if that means there will be less than kMinimumScrollOffsetPadding
    // pixels above the view, then substitute kMinimumScrollOffsetPadding
    CGFloat padding = (viewAreaHeight - subviewRect.size.height) / 2;
    if ( padding < kMinimumScrollOffsetPadding ) {
        padding = kMinimumScrollOffsetPadding;
    }
    
    // Ideal offset places the subview rectangle origin "padding" points from the top of the scrollview.
    // If there is a top contentInset, also compensate for this so that subviewRect will not be placed under
    // things like navigation bars.
    offset = subviewRect.origin.y - padding - self.contentInset.top;
    
    // Constrain the new contentOffset so we can't scroll past the bottom. Note that we don't take the bottom
    // inset into account, as this is manipulated to make space for the keyboard.
    if ( offset > (contentSize.height - viewAreaHeight) ) {
        offset = contentSize.height - viewAreaHeight;
    }
    
    // Constrain the new contentOffset so we can't scroll past the top, taking contentInsets into account
    if ( offset < -self.contentInset.top ) {
        offset = -self.contentInset.top;
    }
    
    return offset;
}

- (UIView*)MF_findFirstResponderBeneathView:(UIView*)view {
    // Search recursively for first responder
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *result = [self MF_findFirstResponderBeneathView:childView];
        if ( result ) return result;
    }
    return nil;
}

- (void)MF_updateContentInset {
    MFKeyboardAvoidingState *state = self.keyboardAvoidingState;
    if ( state.keyboardVisible ) {
        self.contentInset = [self MF_contentInsetForKeyboard];
    }
}

@end
