//
//  TCHMainViewController.m
//  Ties-CH
//
//  Created by  on 6/3/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import "TCHMainViewController.h"

#import "TCHGirlsListingView.h"
#import "TCHMessageList.h"
#import "TCHFavoriteFriendsList.h"
#import "TCHAccountSettings.h"
#import "TCHUpdateProfileVC.h"
#import "TCHMessageComposeVC.h"

#define kNumPages 4

@interface TCHMainViewController () <UIScrollViewDelegate> {
    NSInteger currentPage;
    BOOL isScrollViewLoaded;
}

@property (nonatomic, weak) IBOutlet UIView *mainview;
@property (nonatomic, weak) IBOutlet UIScrollView *mainScrollView;

@property (nonatomic, weak) TCHGirlsListingView *tchGirlsListingView;
@property (nonatomic, weak) TCHMessageList *tchMessageList;
@property (nonatomic, weak) TCHFavoriteFriendsList *tchFavoriteFriendsList;
@property (nonatomic, weak) TCHAccountSettings *tchAccountSettings;


@end

@implementation TCHMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}

#pragma mark -
#pragma mark Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    currentPage = 3;
    
    [_mainview setBackgroundColor:ThemeColor];
    
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    BOOL isProfileConfigure = [[NSUserDefaults standardUserDefaults] boolForKey:IsProfileConfigure];
    
    if (isProfileConfigure) {
        [self performSelector:@selector(setupScrollView) withObject:nil afterDelay:0.5];
    } else {
        [self presentTCHUpdateProfileVC];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!isScrollViewLoaded) {
        [self setupScrollView];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Custom Methods

-(void)presentTCHUpdateProfileVC {
    TCHUpdateProfileVC *viewController = [[TCHUpdateProfileVC alloc] initWithNibName:@"TCHUpdateProfileVC" bundle:[NSBundle mainBundle]];
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)presentTCHMessageComposeVC:(NSString *)receiver messageId:(NSString *)messageId isReplyMode:(BOOL)isReplyMode {
    TCHMessageComposeVC *viewController = [[TCHMessageComposeVC alloc] initWithNibName:@"TCHMessageComposeVC" bundle:[NSBundle mainBundle]];
    
    viewController.receiver = receiver;
    viewController.messageId = messageId;
    viewController.isReplyMode = isReplyMode;
    
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark -
#pragma mark Initialize ScrollView

-(void)setCurrentPage:(NSInteger)scrollToPage {
    currentPage = scrollToPage;
    [_mainScrollView setContentOffset:CGPointMake(_mainScrollView.frame.size.width * currentPage, 0) animated:YES];
}

-(void)reloadLoadedGirlList {
    if (_tchGirlsListingView) {
        [_tchGirlsListingView reloadLoadedView];
    }
}

-(void)setupScrollView {
    
    isScrollViewLoaded = YES;
    
    _mainScrollView.contentSize = CGSizeMake(_mainScrollView.frame.size.width * kNumPages, _mainScrollView.frame.size.height);
	_mainScrollView.contentOffset = CGPointMake(_mainScrollView.frame.size.width * (kNumPages - 1), 0);
    
    [self loadScrollViewWithPage:currentPage - 1];
	[self loadScrollViewWithPage:currentPage];
    [self loadScrollViewWithPage:currentPage + 1];
}

#pragma mark -
#pragma mark ScrollView Delegate Method

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	CGFloat pageWidth = _mainScrollView.frame.size.width;
    int page = floor((_mainScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
    if (currentPage != page) {
        currentPage = page;
        
        [self loadScrollViewWithPage:page - 1];
        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page + 1];
    }
}

- (void)loadScrollViewWithPage:(NSInteger )page {
    if (page < 0) return;
    if (page >= kNumPages) return;
    
    switch (page) {
            
        case 0: {
            
            if (nil == _tchAccountSettings.superview) {
                
                UIViewController *controller = [[UIViewController alloc] initWithNibName:@"TCHAccountSettings" bundle:[NSBundle mainBundle]];
                _tchAccountSettings = (TCHAccountSettings *)controller.view;
                
                CGRect frame = _mainScrollView.frame;
                frame.origin.x = frame.size.width * page;
                frame.origin.y = 0;
                _tchAccountSettings.frame = frame;
                [_mainScrollView addSubview:_tchAccountSettings];
                [_tchAccountSettings loadView];
            } else {
                [_tchAccountSettings reloadLoadedView];
            }
        }
            break;
            
        case 1: {
            
            if (nil == _tchFavoriteFriendsList.superview) {
                
                UIViewController *controller = [[UIViewController alloc] initWithNibName:@"TCHFavoriteFriendsList" bundle:[NSBundle mainBundle]];
                _tchFavoriteFriendsList = (TCHFavoriteFriendsList *)controller.view;
                
                CGRect frame = _mainScrollView.frame;
                frame.origin.x = frame.size.width * page;
                frame.origin.y = 0;
                _tchFavoriteFriendsList.frame = frame;
                [_mainScrollView addSubview:_tchFavoriteFriendsList];
                [_tchFavoriteFriendsList loadView];
            } else {
                [_tchFavoriteFriendsList reloadLoadedView];
            }
        }
            break;
            
        case 2: {
            
            if (nil == _tchMessageList.superview) {
                
                UIViewController *controller = [[UIViewController alloc] initWithNibName:@"TCHMessageList" bundle:[NSBundle mainBundle]];
                _tchMessageList = (TCHMessageList *)controller.view;
                
                CGRect frame = _mainScrollView.frame;
                frame.origin.x = frame.size.width * page;
                frame.origin.y = 0;
                _tchMessageList.frame = frame;
                [_mainScrollView addSubview:_tchMessageList];
                [_tchMessageList loadView];
            } else {
                [_tchMessageList reloadLoadedView];
            }
        }
            break;
            
        case 3: {
            
            if (nil == _tchGirlsListingView.superview) {
                
                UIViewController *controller = [[UIViewController alloc] initWithNibName:@"TCHGirlsListingView" bundle:[NSBundle mainBundle]];
                _tchGirlsListingView = (TCHGirlsListingView *)controller.view;
                
                CGRect frame = _mainScrollView.frame;
                frame.origin.x = frame.size.width * page;
                frame.origin.y = 0;
                _tchGirlsListingView.frame = frame;
                [_mainScrollView addSubview:_tchGirlsListingView];
                [_tchGirlsListingView loadView];
            } else {
                [_tchGirlsListingView.notificationBubble setTitle:appDelegate.numOfUnreadMessages forState:UIControlStateNormal];
                
                if ([appDelegate.numOfUnreadMessages isEqualToString:@"0"]) {
                    [_tchGirlsListingView.notificationBubble setHidden:YES];
                } else {
                    [_tchGirlsListingView.notificationBubble setHidden:NO];
                }
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
