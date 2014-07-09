//
//  TCHFriendListCell.h
//  Ties-CH
//
//  Created by  on 6/5/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCHFriendListCell : UITableViewCell


@property (nonatomic, weak) IBOutlet UIView *initialView;
@property (nonatomic, weak) IBOutlet UILabel *noOfFriends;

@property (nonatomic, weak) IBOutlet UIView *friendsView;
@property (nonatomic, weak) IBOutlet UIView *userNameView;
@property (nonatomic, weak) IBOutlet UILabel *userName;
@property (nonatomic, weak) IBOutlet UIImageView *imgPic;
@property (nonatomic, weak) IBOutlet UIImageView *blackLayer;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *thumbProgressView;

@property (nonatomic, weak) IBOutlet UIButton *unfriendButton;
@property (nonatomic, weak) IBOutlet UIButton *weChatButton;
@property (nonatomic, weak) IBOutlet UIButton *replyButton;
@property (nonatomic, weak) IBOutlet UIButton *inviteFriend;

@property (nonatomic, weak) IBOutlet UILabel *time;

@end
