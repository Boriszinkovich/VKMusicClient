//
//  LoginVC.m
//  VKMusicClient
//
//  Created by User on 11.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#import "LoginVC.h"

#import "UserDefaults.h"

@interface LoginVC () <UIWebViewDelegate>

@property (nonatomic, strong, nonnull) UIWebView *theWebView;
@property (nonatomic, strong, nonnull) UIActivityIndicatorView *theIndicatorView;
@property (nonatomic, strong) Reachability *theInternetReachability;

@end

NSString * const keyLoginURLString = @"https://oauth.vk.com/authorize?"
@"client_id=3502561&"
@"scope=65544&" // 8(audio) + 65536(all time)
@"redirect_uri=https://oauth.vk.com/blank.html&"
@"display=mobile&"
@"v=5.7&"
@"response_type=token";
NSString * const keyAccessToken = @"access_token";

@implementation LoginVC

#pragma mark - Class Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Init & Dealloc

#pragma mark - Setters (Public)

#pragma mark - Getters (Public)

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isFirstLoad)
    {
        [self createAllViews];
    }
}

#pragma mark - Create Views & Variables

- (void)createAllViews
{
    if (!self.isFirstLoad)
    {
        return;
    }
    self.isFirstLoad = NO;
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIWebView *theWebView = [UIWebView new];
    theWebView.delegate = self;
    self.theWebView = theWebView;
    [self.view addSubview:theWebView];
    theWebView.theHeight = theWebView.superview.theHeight;
    theWebView.theWidth = theWebView.superview.theWidth;
    
    UIActivityIndicatorView *theIndicatorView = [UIActivityIndicatorView new];
    self.theIndicatorView = theIndicatorView;
    [self.view addSubview:theIndicatorView];
    theIndicatorView.theHeight = 80;
    theIndicatorView.theWidth = 80;
    theIndicatorView.theCenterX = theIndicatorView.superview.theWidth/2;
    theIndicatorView.theCenterY = theIndicatorView.superview.theHeight/2;
    theIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    {
        /// for test
        NSHTTPCookieStorage *theCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *theCookie in theCookieStorage.cookies)
        {
            [theCookieStorage deleteCookie:theCookie];
        }
    }
    [theIndicatorView startAnimating];
    
    Reachability *theInternerReachability = [Reachability reachabilityForInternetConnection];
    self.theInternetReachability = theInternerReachability;
    {
        weakify(self);
        theInternerReachability.reachableBlock = ^(Reachability *theReachability)
        {
            [BZExtensionsManager methodAsyncMainWithBlock:^
             {
                 strongify(self);
                 [self methodLoadAutorizationURL];
             }];
        };
    }
    {
        weakify(self);
        theInternerReachability.unreachableBlock = ^(Reachability *theReachability)
        {
            [BZExtensionsManager methodAsyncMainWithBlock:^
             {
                 strongify(self);
                 [self.theIndicatorView stopAnimating];
                 [self methodAlertWithNoInternet];
             }];
        };
    }
    [theInternerReachability startNotifier];

    [self methodLoadAutorizationURL];
}

#pragma mark - Actions

#pragma mark - Gestures

#pragma mark - Notifications

#pragma mark - Delegates (UIWebViewDelegate)

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    [self.theIndicatorView stopAnimating];
    NSString *theURLString = request.URL.absoluteString;
    if ([theURLString containsString:@"join"])
    {
        [self methodAlertWithNoRegistration];
        return NO;
    }
    
    if ([theURLString containsString:@"access_denied"] && [theURLString containsString:@"user_denied"])
    {
        return NO;
    }
    if (!self.theInternetReachability.isReachable)
    {
        [self methodAlertWithNoInternet];
        return NO;
    }
    if ([theURLString containsString: keyAccessToken])
    {
        NSString *theQueryString = request.URL.description;
        NSArray *theQueryArray = [theQueryString componentsSeparatedByString:@"#"];
        BZAssert(theQueryArray.count >= 1);
        theQueryString = theQueryArray.lastObject;
        
        NSArray *theParametersArray = [theQueryString componentsSeparatedByString:@"&"];
        for (NSString *theParameterString in theParametersArray)
        {
            
            NSArray *thePairArray = [theParameterString componentsSeparatedByString:@"="];
            BZAssert((BOOL)(thePairArray.count == 2));
            NSString *theKeyString = thePairArray.firstObject;
            if (isEqual(theKeyString, keyAccessToken))
            {
                [UserDefaults sharedInstance].theAccessToken = thePairArray.lastObject;
            }
            else if ([theKeyString isEqualToString:@"user_id"])
            {
                [UserDefaults sharedInstance].theUserIdString = thePairArray.lastObject;
            }
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:keyLoginVCLoadNotification
         object:self];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.theIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.theIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.theIndicatorView stopAnimating];
}

#pragma mark - Methods (Public)

#pragma mark - Methods (Private)

- (void)methodLoadAutorizationURL
{
    if (!self.theInternetReachability.isReachable)
    {
        [self methodAlertWithNoInternet];
    }
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:keyLoginURLString]];
    [self.theWebView loadRequest:theRequest];
}

- (void)methodAlertWithNoRegistration
{
    UIAlertController *theAlert = [UIAlertController alertControllerWithTitle:@"Registration restricted"
                                                                      message:@"You must have vk account to use VKPlayer"
                                                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *theDefaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
    
    [theAlert addAction:theDefaultAction];
    [self presentViewController:theAlert animated:YES completion:nil];
}

- (void)methodAlertWithNoInternet
{
    UIAlertController *theAlert = [UIAlertController alertControllerWithTitle:@"No internet connection"
                                                                      message:@"Please, check you internet connection and continue searching"
                                                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *theDefaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
    
    [theAlert addAction:theDefaultAction];
    [self presentViewController:theAlert animated:YES completion:nil];
}

#pragma mark - Standard Methods

@end






























