//
//  TCHGirlsListingView.h
//  Ties-CH
//
//  Created by  on 6/3/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BugButton.h"
#import "SMContactsSelector.h"

@interface TCHGirlsListingView : TCHRootView <BugButtonDelegate, SMContactsSelectorDelegate>


@property (nonatomic, weak) IBOutlet UIButton *notificationBubble;

- (void)numberOfRowsSelected:(NSInteger)numberRows withData:(NSArray *)data andDataType:(DATA_CONTACT)type;
-(void)loadView;

@end
