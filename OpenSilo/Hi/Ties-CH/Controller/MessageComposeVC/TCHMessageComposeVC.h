//
//  TCHMessageComposeVC.h
//  Ties-CH
//
//  Created by  on 6/3/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCHMessageComposeVC : UIViewController

@property (nonatomic, assign) NSString *receiver;
@property (nonatomic, assign) NSString *messageId;
@property (nonatomic, assign) BOOL isReplyMode;

@end
