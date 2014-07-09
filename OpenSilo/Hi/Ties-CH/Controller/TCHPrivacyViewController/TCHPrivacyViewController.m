//
//  TCHPrivacyViewController.m
//  Ties-CH
//
//  Created by wan, peng on 6/11/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import "TCHPrivacyViewController.h"

@interface TCHPrivacyViewController ()
- (IBAction)onClickClose:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation TCHPrivacyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _webView.scalesPageToFit = YES;
    NSString *urlAddress = [NSString stringWithFormat:@"%@index/terms",API_HOME];
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onClickClose:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
