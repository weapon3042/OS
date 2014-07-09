//
//  TCHMessageList.m
//  Ties-CH
//
//  Created by  on 6/3/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import "TCHMessageList.h"
#import "TCHGirlListCell.h"
#import "MNMBottomPullToRefreshManager.h"
#import "TCHMessageListCell.h"
#import "TCHMainViewController.h"
#import "IBActionSheet.h"

@interface TCHMessageList () <UITableViewDelegate, UITableViewDataSource, MNMBottomPullToRefreshManagerClient> {
    
    NSInteger pageNumber;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    
    BOOL isDragging;
    BOOL isLoading;
    
    NSString *timeStamp;
}

@property (nonatomic, strong) NSMutableArray *arrPeople;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UITableView *girlsListTableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, weak) IBOutlet UIImageView *refreshArrow;

-(IBAction)onClickFriendsList:(id)sender;
-(IBAction)onClickHome:(id)sender;

@end

@implementation TCHMessageList

-(void)loadView {
    pageNumber = 1;
    timeStamp = TimeStamp;
    
    _girlsListTableView.decelerationRate = UIScrollViewDecelerationRateFast;
    _girlsListTableView.pagingEnabled = YES;
    
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:80.0f tableView:_girlsListTableView withClient:self];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [appDelegate showLoading];
        [self fetchChatHistory];
    });
}

-(NSMutableArray *)arrPeople {
    if (!_arrPeople) {
        _arrPeople = [[NSMutableArray alloc] init];
    }
    return _arrPeople;
}

-(void)reloadLoadedView {
    [super reloadLoadedView];
    
    [_arrPeople removeAllObjects];
    [_girlsListTableView reloadData];
    pageNumber = 1;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [appDelegate showLoading];
        [self fetchChatHistory];
    });
}

#pragma mark -
#pragma mark Action Events

- (UIViewController*)rootViewController {
    
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

-(IBAction)onClickClose:(id)sender {
    
    IBActionSheet *standardIBAS = [[IBActionSheet alloc] initWithTitle:@"Are you sure to delete this message？"  cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil, nil];
    
    standardIBAS.callbackBlock =
    ^(IBActionSheetCallbackType result, NSInteger buttonIndex) {
        UIButton *button = (UIButton *)sender;
        NSDictionary *dict = [_arrPeople objectAtIndex:button.tag-1];
        
        [appDelegate showLoading];
        [self deleteMessageWithMessageId:[dict objectForKey:@"id"]];
    };
    [standardIBAS showInView:self];
}

-(IBAction)onClickAddToColl:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSDictionary *dict = [_arrPeople objectAtIndex:button.tag-1];
    
    [appDelegate showLoading];
    [self sendRequest:[dict objectForKey:@"senderId"]];
}

-(IBAction)onClickMessage:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSDictionary *dict = [_arrPeople objectAtIndex:button.tag-1];
    
    TCHMainViewController *viewController = (TCHMainViewController *)[self rootViewController];
    [viewController presentTCHMessageComposeVC:@"" messageId:[dict objectForKey:@"id"] isReplyMode:YES];
}

-(IBAction)onClickAcceptButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSDictionary *dict = [_arrPeople objectAtIndex:button.tag-1];
    
    [appDelegate showLoading];
    [self acceptRequestWithMessageId:[dict objectForKey:@"id"]];
}

#pragma Mark navigation button

-(IBAction)onClickFriendsList:(id)sender {
    TCHMainViewController *viewController = (TCHMainViewController *)[self rootViewController];
    [viewController setCurrentPage:kFavoriteFriendsList];
}

-(IBAction)onClickHome:(id)sender {
    TCHMainViewController *viewController = (TCHMainViewController *)[self rootViewController];
    [viewController setCurrentPage:kGirlsListingView];
}

#pragma mark -
#pragma mark Web service call

-(void)fetchChatHistory {
    
    NSDictionary *profileDict = [[NSUserDefaults standardUserDefaults] objectForKey:UserProfile];
    NSString *uuid = [profileDict objectForKey:@"uuid"];
    
    NSDictionary *parameters = @{
                                 @"uuid" : uuid,
                                 @"timestamp" : timeStamp,
                                 @"pageNumber": [NSString stringWithFormat:@"%d",pageNumber],
                                 @"pageSize": @"5"};
    
    AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
    client.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [client GET:[NSString stringWithFormat:@"%@r/message/?",API_HOME] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([[[responseObject objectForKey:@"ack"] lowercaseString] isEqualToString:@"success"]) {
            NSArray *array = [[responseObject objectForKey:@"object"] objectForKey:@"messages"];
            for (NSInteger i = 0; i < [array count]; i++) {
                [self.arrPeople addObject:[array objectAtIndex:i]];
            }
        }
        
        appDelegate.numOfUnreadMessages = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"object"] objectForKey:@"count"]];
        
        _girlsListTableView.pagingEnabled = YES;
        [appDelegate stopLoading];
        [_girlsListTableView reloadData];
        [pullToRefreshManager_ tableViewReloadFinished];
        
        NSIndexPath *indexPath = [[_girlsListTableView indexPathsForVisibleRows] lastObject];
        [_girlsListTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _girlsListTableView.pagingEnabled = YES;
        [appDelegate stopLoading];
        [appDelegate.window makeToast:ServerConnection backgroundColor:RedColor];
        [pullToRefreshManager_ tableViewReloadFinished];
    }];
}

-(void)pullToRefresh {
    
    timeStamp = TimeStamp;
    
    NSDictionary *profileDict = [[NSUserDefaults standardUserDefaults] objectForKey:UserProfile];
    NSString *uuid = [profileDict objectForKey:@"uuid"];
    
    NSDictionary *parameters = @{
                                 @"uuid" : uuid,
                                 @"timestamp" : timeStamp,
                                 @"pageNumber": @"1",
                                 @"pageSize": @"5"};
    
    AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
    client.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [client GET:[NSString stringWithFormat:@"%@r/message/?",API_HOME] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([self.arrPeople count] > 0) {
            [self.arrPeople removeAllObjects];
        }
        
        if ([[[responseObject objectForKey:@"ack"] lowercaseString] isEqualToString:@"success"]) {
            NSArray *array = [[responseObject objectForKey:@"object"] objectForKey:@"messages"];
            for (NSInteger i = 0; i < [array count]; i++) {
                [self.arrPeople addObject:[array objectAtIndex:i]];
            }
        }
        
        appDelegate.numOfUnreadMessages = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"object"] objectForKey:@"count"]];
        
        _girlsListTableView.pagingEnabled = YES;
        [_girlsListTableView reloadData];
        [self recoverTitle];
        [self stopLoading];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _girlsListTableView.pagingEnabled = YES;
        [appDelegate.window makeToast:ServerConnection backgroundColor:RedColor];
        [self recoverTitle];
        [self stopLoading];
    }];
}

- (void) recoverTitle {
    self.title.text = @"Inbox";
}

-(void)sendRequest:(NSString *)receiver {
    
    NSDictionary *profileDict = [[NSUserDefaults standardUserDefaults] objectForKey:UserProfile];
    NSString *uuid = [profileDict objectForKey:@"uuid"];
    
    NSDictionary *parameters = @{
                                 @"uuid" : uuid,
                                 @"receiver": receiver };
    
    AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
    client.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [client POST:[NSString stringWithFormat:@"%@r/message/sendFriendRequest?",API_HOME] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
        if ([[[responseObject objectForKey:@"ack"] lowercaseString] isEqualToString:@"success"]) {
            [appDelegate.window makeToast:RequestSentSuccesssfully backgroundColor:GreenColor];
            
        } else if([[responseObject objectForKey:@"error"] isEqualToString:@"You already sent a request"]){
            [appDelegate.window makeToast:@"You request has been sent." backgroundColor:[UIColor redColor]];
        } else if([[responseObject objectForKey:@"error"] isEqualToString:@"You are friends already"]){
            [appDelegate.window makeToast:@"You are friends already!" backgroundColor:[UIColor redColor]];
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

-(void)acceptRequestWithMessageId:(NSString *)messageId {
    NSDictionary *profileDict = [[NSUserDefaults standardUserDefaults] objectForKey:UserProfile];
    NSString *uuid = [profileDict objectForKey:@"uuid"];
    
    NSDictionary *parameters = @{
                                 @"uuid" : uuid,
                                 @"messageId": messageId };
    
    AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
    client.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [client POST:[NSString stringWithFormat:@"%@r/message/acceptFriendRequest?",API_HOME] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([[[responseObject objectForKey:@"ack"] lowercaseString] isEqualToString:@"success"]) {
            [appDelegate.window makeToast:RequestAcceptSuccesssfully backgroundColor:GreenColor];
            
        } else if([[responseObject objectForKey:@"error"] isEqualToString:@"You already sent a request"]){
            [appDelegate.window makeToast:@"You request has been sent." backgroundColor:[UIColor redColor]];
        } else if([[responseObject objectForKey:@"error"] isEqualToString:@"You are friends already"]){
            [appDelegate.window makeToast:@"You are friends already!" backgroundColor:[UIColor redColor]];
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

-(void)deleteMessageWithMessageId:(NSString *)messageId {
    NSDictionary *profileDict = [[NSUserDefaults standardUserDefaults] objectForKey:UserProfile];
    NSString *uuid = [profileDict objectForKey:@"uuid"];
    
    NSDictionary *parameters = @{
                                 @"uuid" : uuid,
                                 @"messageId": messageId };
    
    AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
    client.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [client POST:[NSString stringWithFormat:@"%@r/message/delete?",API_HOME] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([[[responseObject objectForKey:@"ack"] lowercaseString] isEqualToString:@"success"]) {
            [appDelegate.window makeToast:MessageRemovedSuccessfully backgroundColor:GreenColor];
            
        } else {
            [appDelegate.window makeToast:ServerDBError backgroundColor:[UIColor redColor]];
        }
        
        [appDelegate stopLoading];
        [self reloadLoadedView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [appDelegate stopLoading];
        //[appDelegate.window makeToast:ServerConnection backgroundColor:[UIColor redColor]];
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
    TCHMessageListCell *cell = [TCHMessageListCell dequeOrCreateInTable:tableView cellId:[NSString stringWithFormat:@"TCHMessageListCell%d",indexPath.row]];
    
    if (indexPath.row == 0) {
        cell.numOfMesView.hidden = NO;
        cell.mainView.hidden = YES;
        
        cell.numOfMess.text = [NSString stringWithFormat:@"%@",appDelegate.numOfUnreadMessages];
        
    } else {
        
        cell.numOfMesView.hidden = YES;
        cell.mainView.hidden = NO;

        
        NSMutableDictionary *dict = [[_arrPeople objectAtIndex:indexPath.row - 1] mutableCopy];
        [dict handleNullValues];
        
        [cell.thumbProgressView startAnimating];
        
        NSURL *url = [NSURL URLWithString:[dict objectForKey:@"senderPic"] ? [[dict objectForKey:@"senderPic"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @""];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        UIImage *placeholderImage = [UIImage imageNamed:@"imgPlaceholder"];
        
        __weak TCHMessageListCell *weakCell = cell;
        
        [cell.imgPic setImageWithURLRequest:request
                           placeholderImage:placeholderImage
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                        
                                        [weakCell.thumbProgressView stopAnimating];
                                        weakCell.imgPic.image = image;
                                        
                                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                        [weakCell.thumbProgressView stopAnimating];
                                    }];
        
        cell.messageView.layer.cornerRadius = 15.0f;
        
        cell.closeButton.tag = indexPath.row;
        cell.addToCollButton.tag = indexPath.row;
        cell.replyButton.tag = indexPath.row;
        cell.acceptRequestButton.tag = indexPath.row;
        
        [cell.closeButton addTarget:self action:@selector(onClickClose:) forControlEvents:UIControlEventTouchUpInside];
        [cell.addToCollButton addTarget:self action:@selector(onClickAddToColl:) forControlEvents:UIControlEventTouchUpInside];
        [cell.replyButton addTarget:self action:@selector(onClickMessage:) forControlEvents:UIControlEventTouchUpInside];
        [cell.acceptRequestButton addTarget:self action:@selector(onClickAcceptButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if (![dict objectForKey:@"msg"] || [[dict objectForKey:@"msg"] isEqualToString:@""]) {
            cell.message.hidden = YES;
        } else if([[dict objectForKey:@"msgType"] isEqualToString:@"friendRequest"]){
            cell.message.hidden = NO;
            cell.message.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg"]];
        } else {
            cell.message.hidden = NO;
            cell.message.text = [NSString stringWithFormat:@"%@ : %@",[dict objectForKey:@"senderName"],[dict objectForKey:@"msg"]];
        }

        if ([[dict objectForKey:@"isFriend"] intValue] == 1) {
            cell.addToCollButton.hidden = YES;
            cell.acceptRequestButton.hidden = YES;
            cell.message.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"msg"]];
            
        } else if([[dict objectForKey:@"msgType"] isEqualToString:@"friendRequest"] &&
                  [[dict objectForKey:@"msgStatus"] isEqualToString:@"inrequest"]) {
            cell.addToCollButton.hidden = YES;
            cell.acceptRequestButton.hidden = NO;
            
        } else {
            
            cell.addToCollButton.hidden = NO;
            cell.acceptRequestButton.hidden = YES;
        }
        cell.blackLayer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:BlackLayerOpacity];
         NSString* localtime = [appDelegate convertDateTimeFromTimeFormat:@"HH:mm MM/dd/yyyy" toDateTimeFormat:@"HH:mm MM/dd/yyyy" forDateTime:[dict objectForKey:@"sendtimeForUI"]];
        cell.time.text = [appDelegate dateTimeDifference:localtime];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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
            _girlsListTableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -52.0f)
            _girlsListTableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
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
    _girlsListTableView.pagingEnabled = NO;
    [self performSelector:@selector(loadTable) withObject:nil afterDelay:1.0f];
}

- (void)startLoading {
    isLoading = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        _girlsListTableView.contentInset = UIEdgeInsetsMake(52.0, 0, 0, 0);
        self.title.text = Loading;
        _refreshArrow.hidden = YES;
        [_activityView startAnimating];
    }];
    
    [self pullToRefresh];
}

- (void)stopLoading {
    isLoading = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        _girlsListTableView.contentInset = UIEdgeInsetsZero;
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
    [self fetchChatHistory];
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
