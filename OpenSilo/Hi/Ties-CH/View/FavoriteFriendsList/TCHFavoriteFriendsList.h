//
//  TCHFavoriteFriendsList.h
//  Ties-CH
//
//  Created by  on 6/3/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMContactsSelector.h"
#import <MessageUI/MessageUI.h>

@interface TCHFavoriteFriendsList : TCHRootView <SMContactsSelectorDelegate, MFMessageComposeViewControllerDelegate>

-(void)loadView;
- (void)numberOfRowsSelected:(NSInteger)numberRows withData:(NSArray *)data andDataType:(DATA_CONTACT)type;

@end
