//
//  TCHMessageListCell.h
//  Ties-CH
//
//  Created by  on 6/5/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCHMessageListCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imgPic;
@property (nonatomic, weak) IBOutlet UIImageView *blackLayer;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *thumbProgressView;
@property (nonatomic, weak) IBOutlet UIView *messageView;
@property (nonatomic, weak) IBOutlet UILabel *message;

@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIButton *addToCollButton;
@property (nonatomic, weak) IBOutlet UIButton *acceptRequestButton;
@property (nonatomic, weak) IBOutlet UIButton *replyButton;

@property (nonatomic, weak) IBOutlet UIView *mainView;
@property (nonatomic, weak) IBOutlet UIView *numOfMesView;
@property (nonatomic, weak) IBOutlet UILabel *numOfMess;

@property (nonatomic, weak) IBOutlet UILabel *time;

@end
