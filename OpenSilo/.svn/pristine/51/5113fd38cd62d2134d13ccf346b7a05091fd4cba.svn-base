//
//  TCHProfileSelection.m
//  Ties-CH
//
//  Created by  on 6/4/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import "TCHProfileSelection.h"
#import "TCHUpdateProfileVC.h"

@interface TCHProfileSelection () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIView *profileNameView;
@property (nonatomic, weak) IBOutlet UIScrollView *userNameScrollView;
@property (nonatomic, weak) IBOutlet UITextField *txtUserName;
@property (nonatomic, weak) IBOutlet UIButton *userNameOkButton;

@property (nonatomic, weak) IBOutlet UIView *genderSelectionView;
@property BOOL animated;

-(IBAction)gotoGenderScreen:(id)sender;

-(IBAction)onClickMale:(id)sender;
-(IBAction)onClickFemale:(id)sender;

@end

@implementation TCHProfileSelection

-(void)loadView {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
    
    if (IS_IPHONE_5 || IS_HEIGHT_GTE_568) {
        
    } else {
        _userNameOkButton.center = CGPointMake(_userNameOkButton.center.x, _userNameOkButton.center.y - 44);
    }

    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.profileNameView addGestureRecognizer:tapBackground];

    _profileNameView.hidden = NO;
    _genderSelectionView.hidden = YES;
    _animated = NO;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TCHUserName]) {
        _txtUserName.text = [[NSUserDefaults standardUserDefaults] objectForKey:TCHUserName];
    }
    
    [_userNameScrollView setContentSize:
     CGSizeMake(_userNameScrollView.frame.size.width,
                self.frame.origin.y + self.frame.size.height)];
    
    [_userNameScrollView setContentOffset:CGPointZero];
}

-(void)reloadLoadedView {
    [super reloadLoadedView];
}

#pragma mark -
#pragma Keyboard Noyifiocation Action

-(void)keyboardWillShow:(NSNotification *)aNotification {
    // Animate the current view out of the way
    if (_animated == NO) {
    
        NSDictionary *userInfo = aNotification.userInfo;
        NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardEndFrame = [self.profileNameView convertRect:endFrameValue.CGRectValue fromView:nil];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        CGRect searchButtonFrame = self.profileNameView.frame;
        searchButtonFrame.origin.y = (self.profileNameView.frame.origin.y - keyboardEndFrame.size.height);
        self.profileNameView.frame = searchButtonFrame;
        
        [UIView commitAnimations];
        _animated = YES;

    }
}

-(void)keyboardWillHide:(NSNotification *)aNotification {
    // Animate the current view back to its original position
    if (_animated == YES) {

        NSDictionary *userInfo = aNotification.userInfo;
        NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardEndFrame = [self.profileNameView convertRect:endFrameValue.CGRectValue fromView:nil];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        CGRect searchButtonFrame = self.profileNameView.frame;
        searchButtonFrame.origin.y = (self.profileNameView.frame.origin.y + keyboardEndFrame.size.height);
        self.profileNameView.frame = searchButtonFrame;
        
        [UIView commitAnimations];
        _animated = NO;
    }
}


#pragma mark -
#pragma mark Action Events

-(void) dismissKeyboard:(id)sender {
    [_userNameScrollView setContentOffset:CGPointZero animated:YES];
    [self.profileNameView endEditing:YES];
}

-(IBAction)gotoGenderScreen:(id)sender {
    
    [self.profileNameView endEditing:YES];
    if (_txtUserName.text.length == 0) {
        [appDelegate.window makeToast:@"请输入您的昵称" backgroundColor:RedColor];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:_txtUserName.text forKey:TCHUserName];
    
    _profileNameView.hidden = YES;
    _genderSelectionView.hidden = NO;
}

-(IBAction)onClickMale:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:TCHMale forKey:TCHGenderCode];
    [self startCamera];
}

-(IBAction)onClickFemale:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:TCHFemale forKey:TCHGenderCode];
    [self startCamera];
}

-(void)startCamera {
    TCHUpdateProfileVC *viewController = (TCHUpdateProfileVC *)[self rootViewController];
    [viewController startCamera];
    [self removeFromSuperview];
}

- (UIViewController*)rootViewController {
    
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark UITextField Delegate Methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (IS_IPHONE_5 || IS_HEIGHT_GTE_568) {
        [_userNameScrollView setContentOffset:CGPointMake(0, 50) animated:YES];
    } else {
        [_userNameScrollView setContentOffset:CGPointMake(0, 138) animated:YES];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_userNameScrollView setContentOffset:CGPointZero animated:YES];
    [textField resignFirstResponder];
    return YES;
}

@end
