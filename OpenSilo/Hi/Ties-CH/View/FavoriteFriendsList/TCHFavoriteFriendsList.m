//
//  TCHFavoriteFriendsList.m
//  Ties-CH
//
//  Created by  on 6/3/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import "TCHFavoriteFriendsList.h"
#import "TCHFriendListCell.h"
#import "MNMBottomPullToRefreshManager.h"
#import "IBActionSheet.h"

@interface TCHFavoriteFriendsList ()<UITableViewDelegate, UITableViewDataSource, MNMBottomPullToRefreshManagerClient> {
    
    NSInteger pageNumber;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSInteger numOfFriends;
    
    BOOL isDragging;
    BOOL isLoading;
    NSString *timeStamp;
}

@property (nonatomic, strong) NSMutableArray *arrPeople;
@property (nonatomic, weak) IBOutlet UITableView *friendsListTableView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, weak) IBOutlet UIImageView *refreshArrow;

-(IBAction)onClickMessage:(id)sender;
-(IBAction)onClickProfile:(id)sender;

@end

@implementation TCHFavoriteFriendsList

-(void)loadView {
    pageNumber = 1;
    timeStamp = TimeStamp;
    
    _friendsListTableView.decelerationRate = UIScrollViewDecelerationRateFast;
    _friendsListTableView.pagingEnabled = YES;
    
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:80.0f tableView:_friendsListTableView withClient:self];
    
    [appDelegate showLoading];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchFriendsList];
    });
}

-(void)reloadLoadedView {
    [_arrPeople removeAllObjects];
    [_friendsListTableView reloadData];
    pageNumber = 1;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [appDelegate showLoading];
        [self fetchFriendsList];
    });
}

-(NSMutableArray *)arrPeople {
    if (!_arrPeople) {
        _arrPeople = [[NSMutableArray alloc] init];
    }
    return _arrPeople;
}

#pragma mark -
#pragma mark Action Events

-(IBAction)onClickMessage:(id)sender {
    TCHMainViewController *viewController = (TCHMainViewController *)[self rootViewController];
    [viewController setCurrentPage:kMessageList];
}

-(IBAction)onClickProfile:(id)sender {
    TCHMainViewController *viewController = (TCHMainViewController *)[self rootViewController];
    [viewController setCurrentPage:kPreferencesView];
}

-(IBAction)onClickUnfriend:(id)sender {
    
    IBActionSheet *standardIBAS = [[IBActionSheet alloc] initWithTitle:@"Are you sure to remove from friend list？"  cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Confirm" otherButtonTitles:nil, nil];
    
    standardIBAS.callbackBlock =
    ^(IBActionSheetCallbackType result, NSInteger buttonIndex) {
        UIButton *button = (UIButton *)sender;
        NSDictionary *dict = [_arrPeople objectAtIndex:button.tag-1];
        
        [self unfriend:[dict objectForKey:@"friendId"]];
    };
    
    [standardIBAS showInView:self];
}

-(void)shareViaWeChat:(id)sender {
    
    NSIndexPath *indexPath = [[_friendsListTableView indexPathsForVisibleRows] lastObject];
    ;
    TCHFriendListCell *cell = (TCHFriendListCell *)[_friendsListTableView cellForRowAtIndexPath:indexPath];
    
}

-(IBAction)onClickReply:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSDictionary *dict = [_arrPeople objectAtIndex:button.tag-1];
    
    TCHMainViewController *viewController = (TCHMainViewController *)[self rootViewController];
    [viewController presentTCHMessageComposeVC:[dict objectForKey:@"id"] messageId:@"" isReplyMode:NO];
}

-(IBAction)inviteFriends:(id)sender {
    
    IBActionSheet *standardIBAS = [[IBActionSheet alloc] initWithTitle:@"Invite friends from phone book！"  cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Confirm" otherButtonTitles:nil, nil];
    
    standardIBAS.callbackBlock =
    ^(IBActionSheetCallbackType result, NSInteger buttonIndex) {
        
        [appDelegate showLoading];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            SMContactsSelector *controller = [[SMContactsSelector alloc] initWithNibName:@"SMContactsSelector" bundle:nil];
            controller.delegate = self;
            controller.requestData = DATA_CONTACT_TELEPHONE;
            controller.showModal = YES;
            controller.showCheckButton = YES;
            
            TCHMainViewController *viewController = (TCHMainViewController *)[self rootViewController];
            [viewController presentViewController:controller animated:YES completion:^{
                [appDelegate stopLoading];
            }];
        });
    };
    
    [standardIBAS showInView:self];
}

-(void)open {
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

-(void) recoverTitle {
    self.title.text = @"Friends";
}

#pragma mark -
#pragma mark Web service call

-(void)fetchFriendsList {
    NSDictionary *profileDict = [[NSUserDefaults standardUserDefaults] objectForKey:UserProfile];
    
    NSString *uuid = [profileDict objectForKey:@"uuid"];
    
    NSDictionary *parameters = @{@"uuid": uuid,
                                 @"timestamp" : timeStamp,
                                 @"pageNumber" : [NSString stringWithFormat:@"%d",pageNumber],
                                 @"pageSize": @"5"};
    
    AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
    client.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [client GET:[NSString stringWithFormat:@"%@r/friend/?",API_HOME] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([[[responseObject objectForKey:@"ack"] lowercaseString] isEqualToString:@"success"]) {
            NSArray *array = [[responseObject objectForKey:@"object"] objectForKey:@"friends"];
            for (NSInteger i = 0; i < [array count]; i++) {
                [self.arrPeople addObject:[array objectAtIndex:i]];
            }
        }
        numOfFriends = [[[responseObject objectForKey:@"object"] objectForKey:@"count"] integerValue];
    
        _friendsListTableView.pagingEnabled = YES;
        [appDelegate stopLoading];
        [_friendsListTableView reloadData];
        [pullToRefreshManager_ tableViewReloadFinished];
        
        NSIndexPath *indexPath = [[_friendsListTableView indexPathsForVisibleRows] lastObject];
        [_friendsListTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _friendsListTableView.pagingEnabled = YES;
        [appDelegate stopLoading];

        [pullToRefreshManager_ tableViewReloadFinished];
    }];
}

- (void) pullToRefresh {
    
    timeStamp = TimeStamp;
    
    NSDictionary *profileDict = [[NSUserDefaults standardUserDefaults] objectForKey:UserProfile];
    
    NSString *uuid = [profileDict objectForKey:@"uuid"];
    
    NSDictionary *parameters = @{@"uuid": uuid,
                                 @"timestamp" : timeStamp,
                                 @"pageNumber" : @"1",
                                 @"pageSize": @"5"};
    
    AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
    client.responseSerializer = [AFJSONResponseSerializer serializer];
    
//    self.title.text = @"加载中...";
    [client GET:[NSString stringWithFormat:@"%@r/friend/?",API_HOME] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([self.arrPeople count] > 0) {
            [self.arrPeople removeAllObjects];
        }
        
        if ([[[responseObject objectForKey:@"ack"] lowercaseString] isEqualToString:@"success"]) {
            NSArray *array = [[responseObject objectForKey:@"object"] objectForKey:@"friends"];
            for (NSInteger i = 0; i < [array count]; i++) {
                [self.arrPeople addObject:[array objectAtIndex:i]];
            }
        }
        numOfFriends = [[[responseObject objectForKey:@"object"] objectForKey:@"count"] integerValue];
        
        _friendsListTableView.pagingEnabled = YES;
        [_friendsListTableView reloadData];
        [self recoverTitle];
        [self stopLoading];

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _friendsListTableView.pagingEnabled = YES;
        [pullToRefreshManager_ tableViewReloadFinished];
        [self recoverTitle];
        [self stopLoading];

    }];
}

-(void)unfriend:(NSString *)friendId {
    NSDictionary *profileDict = [[NSUserDefaults standardUserDefaults] objectForKey:UserProfile];
    NSString *uuid = [profileDict objectForKey:@"uuid"];
    
    NSDictionary *parameters = @{
                                 @"uuid" : uuid,
                                 @"friendId": friendId };
    
    AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
    client.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [client POST:[NSString stringWithFormat:@"%@r/friend/unbind?",API_HOME] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([[[responseObject objectForKey:@"ack"] lowercaseString] isEqualToString:@"success"]) {
            [appDelegate.window makeToast:RemovedFromFriendList backgroundColor:GreenColor];
            
        } else {
            [appDelegate.window makeToast:ServerDBError backgroundColor:[UIColor redColor]];
        }
        
        [appDelegate stopLoading];
        [self reloadLoadedView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [appDelegate stopLoading];
        [appDelegate.window makeToast:ServerConnection backgroundColor:[UIColor redColor]];
    }];
}

#pragma mark -
#pragma mark Tableview Datasource Method

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.frame.size.height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_arrPeople count] + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCHFriendListCell *cell = [TCHFriendListCell dequeOrCreateInTable:tableView cellId:[NSString stringWithFormat:@"TCHFriendListCell%d",(int)indexPath.row]];
    cell.noOfFriends.textAlignment = NSTextAlignmentCenter;
    if (indexPath.row == 0) {
        cell.initialView.hidden = NO;
        cell.friendsView.hidden = YES;
        
        [cell.inviteFriend addTarget:self action:@selector(inviteFriends:) forControlEvents:UIControlEventTouchUpInside];

        cell.noOfFriends.text = [NSString stringWithFormat:@"%d",(int)numOfFriends];
        
    } else {
        cell.initialView.hidden = YES;
        cell.friendsView.hidden = NO;
        
        cell.unfriendButton.tag = indexPath.row;
        cell.weChatButton.tag = indexPath.row;
        cell.replyButton.tag = indexPath.row;
        
        [cell.unfriendButton addTarget:self action:@selector(onClickUnfriend:) forControlEvents:UIControlEventTouchUpInside];
        [cell.weChatButton addTarget:self action:@selector(shareViaWeChat:) forControlEvents:UIControlEventTouchUpInside];
        [cell.replyButton addTarget:self action:@selector(onClickReply:) forControlEvents:UIControlEventTouchUpInside];
        
        NSMutableDictionary *dict = [[_arrPeople objectAtIndex:indexPath.row - 1] mutableCopy];
        [dict handleNullValues];
        
        [cell.thumbProgressView startAnimating];
        
        NSURL *url = [NSURL URLWithString:[dict objectForKey:@"friendPic"] ? [[dict objectForKey:@"friendPic"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @""];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        UIImage *placeholderImage = [UIImage imageNamed:@"imgPlaceholder"];
        
        __weak TCHFriendListCell *weakCell = cell;
        
        [cell.imgPic setImageWithURLRequest:request
                           placeholderImage:placeholderImage
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                        
                                        [weakCell.thumbProgressView stopAnimating];
                                        weakCell.imgPic.image = image;
                                        
                                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                        [weakCell.thumbProgressView stopAnimating];
                                    }];
        
        cell.userNameView.layer.cornerRadius = 15.0f;
        cell.userName.text = [dict objectForKey:@"friendName"];
        
        cell.blackLayer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:BlackLayerOpacity];
         NSString* localtime = [appDelegate convertDateTimeFromTimeFormat:@"HH:mm MM/dd/yyyy" toDateTimeFormat:@"HH:mm MM/dd/yyyy" forDateTime:[dict objectForKey:@"createtimeForUI"]];
        cell.time.text = [appDelegate dateTimeDifference:localtime];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma -
#pragma SMContactsSelectorDelegate Methods

- (void)numberOfRowsSelected:(NSInteger)numberRows withData:(NSArray *)data andDataType:(DATA_CONTACT)type {
    
    NSMutableArray *recipients = [[NSMutableArray alloc] init];
    
    if (type == DATA_CONTACT_TELEPHONE) {
        for (int i = 0; i < [data count]; i++) {
            NSString *str = [data objectAtIndex:i];
            str = [str reformatTelephone];
            [recipients addObject:str];
        }
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self sendSMS:recipients];
    });
}

-(void)sendSMS:(NSArray *)recipients {

    if([MFMessageComposeViewController canSendText]) {
        
        NSString * message = @"I am using 'Hi' app, please give it a try!";
        
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        [messageController setRecipients:recipients];
        [messageController setBody:message];

//       NSString *imagePath = [SelfProfileImageName pathInDocumentDirectory];
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        if([fileManager fileExistsAtPath:imagePath]) {
//            NSData *imgData = [NSData dataWithContentsOfFile:imagePath];
//            [messageController addAttachmentData:imgData typeIdentifier:@"image/jpeg" filename:@"image.jpeg"];
//        }
        
        TCHMainViewController *viewController = (TCHMainViewController *)[self rootViewController];
        [viewController presentViewController:messageController animated:YES completion:nil];

    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms:"]]) {
        
        NSString *recipientsNumber = [NSString stringWithFormat:@"sms:%@",[recipients componentsJoinedByString:@","]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:recipientsNumber]];
        
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Message could not be sent" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark MNMBottomPullToRefreshManagerClient

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y < 0) {
        if (isLoading) {
            _refreshArrow.hidden = YES;
        } else {
            isDragging = YES;
            _refreshArrow.hidden = NO;
            self.title.text = PullDownToRefresh;
        }
    }
    
    if (isLoading) {
        
        if (scrollView.contentOffset.y > 0)
            _friendsListTableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -52.0f)
            _friendsListTableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -52.0f) {
                self.title.text = ReleaseToRefresh;
                [_refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else {
                self.title.text = PullDownToRefresh;
                [_refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    }
    
    [pullToRefreshManager_ tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [pullToRefreshManager_ tableViewReleased];
    
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -52.0f) {
        [self startLoading];
    } else {
        _refreshArrow.hidden = YES;
        [self recoverTitle];
    }
}

- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager {
    
    _friendsListTableView.pagingEnabled = NO;
    [self performSelector:@selector(loadTable) withObject:nil afterDelay:1.0f];
}

- (void)startLoading {
    isLoading = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        _friendsListTableView.contentInset = UIEdgeInsetsMake(52.0, 0, 0, 0);
        self.title.text = Loading;
        _refreshArrow.hidden = YES;
        [_activityView startAnimating];
    }];
    
    [self pullToRefresh];
}

- (void)stopLoading {
    isLoading = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        _friendsListTableView.contentInset = UIEdgeInsetsZero;
        [_refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    }
                     completion:^(BOOL finished) {
                         [_activityView stopAnimating];
                     }];
}

#pragma mark -
#pragma mark Aux view methods

- (void)loadTable {
    pageNumber++;
    [self fetchFriendsList];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [pullToRefreshManager_ relocatePullToRefreshView];
}

#pragma mark -
#pragma mark Tableview Delegate Method

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
