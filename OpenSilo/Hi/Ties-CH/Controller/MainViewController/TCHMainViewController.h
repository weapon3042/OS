//
//  TCHMainViewController.h
//  Ties-CH
//
//  Created by  on 6/3/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPreferencesView 0
#define kFavoriteFriendsList 1
#define kMessageList 2
#define kGirlsListingView 3

@interface TCHMainViewController : UIViewController

-(void)setCurrentPage:(NSInteger)scrollToPage;
-(void)presentTCHUpdateProfileVC;
-(void)presentTCHMessageComposeVC:(NSString *)receiver messageId:(NSString *)messageId isReplyMode:(BOOL)isReplyMode;

-(void)reloadLoadedGirlList;

@end
