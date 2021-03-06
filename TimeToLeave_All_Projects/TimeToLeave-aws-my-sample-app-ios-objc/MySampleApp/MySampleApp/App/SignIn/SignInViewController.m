//
//  SignInViewController.m
//  MySampleApp
//
//
// Copyright 2016 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-objc v0.6
//
//
#import <Foundation/Foundation.h>
#import "MainViewController.h"
#import "SignInViewController.h"
#import <AWSCore/AWSCore.h>
#import "AWSIdentityManager.h"

static NSString *LOG_TAG;

@interface SignInViewController ()

@property (nonatomic, strong) id didSignInObserver;

@end

@implementation SignInViewController

+ (void)initialize {
    [super initialize];
    LOG_TAG = NSStringFromClass(self);
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@: Sign-In Loading.", LOG_TAG);

    __weak SignInViewController *weakSelf = self;
    self.didSignInObserver =
        [[NSNotificationCenter defaultCenter]
            addObserverForName:AWSIdentityManagerDidSignInNotification
                        object:[AWSIdentityManager sharedInstance]
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification * _Nonnull note) {
                                  [weakSelf.presentingViewController
                                      dismissViewControllerAnimated:YES
                                                         completion:nil];
                               }];
    // FACEBOOK UI SETUP
    [self.facebookButton addTarget:self
                            action:@selector(handleFacebookLogin)
                  forControlEvents:UIControlEventTouchUpInside];
    UIImage *facebookButtonImage = [UIImage imageNamed:@"FacebookButton"];
    if (facebookButtonImage) {
        [self.facebookButton setImage:facebookButtonImage
                             forState:UIControlStateNormal];
    } else {
        NSLog(@"%@: Facebook button image unavailable. We're hiding this button.", LOG_TAG);
        self.facebookButton.hidden = YES;
    }

    [self.view addConstraint:[NSLayoutConstraint
                                 constraintWithItem:self.facebookButton
                                          attribute:NSLayoutAttributeTop
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:[self anchorViewForFacebook]
                                          attribute:NSLayoutAttributeBottom
                                         multiplier:1
                                          constant:8.0]];
    [self.googleButton removeFromSuperview];
    [self.customProviderButton removeFromSuperview];
    [self.customCreateAccountButton removeFromSuperview];
    [self.customForgotPasswordButton removeFromSuperview];
    [self.customUserIdField removeFromSuperview];
    [self.customPasswordField removeFromSuperview];
    [self.leftHorizontalBar removeFromSuperview];
    [self.rightHorizontalBar removeFromSuperview];
    [self.orSignInWithLabel removeFromSuperview];

    [self.customProviderButton setImage:[UIImage imageNamed:@"LoginButton"]
                               forState:UIControlStateNormal];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.didSignInObserver];
}

#pragma mark - Utility Methods

- (void)handleLoginWithSignInProvider:(AWSSignInProviderType)signInProviderType {
    [[AWSIdentityManager sharedInstance]
        loginWithSignInProvider:signInProviderType
              completionHandler:^(id result, NSError *error) {
                                    if (!error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self.parentViewController dismissViewControllerAnimated:YES
                                                                                          completion:nil];
                                        });
                                    }
                                    NSLog(@"result = %@, error = %@", result, error);
                                }];
}

- (void)showErrorDialog:(NSString *)loginProviderName withError:(const NSError *)error {
    NSLog(@"%@: %@ failed to sign in w/ error: %@", LOG_TAG, loginProviderName, error);

    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Sign-in Provider Sign-In Error",
                                                                      @"Sign-in error for sign-in failure.")
                                            message:NSLocalizedString(@"%@ failed to sign in w/ error: %@",
                                                                      @"Sign-in message structure for sign-in failure.")
                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction =
        [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",
                                                         @"Label to cancel sign-in failure.")
                                 style:UIAlertActionStyleCancel
                                handler:nil];
    [alertController addAction:doneAction];

    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

#pragma mark - IBActions

- (void)handleFacebookLogin {
    [self handleLoginWithSignInProvider:AWSSignInProviderTypeFacebook];
}

- (UIView *)anchorViewForFacebook {
    return self.anchorView;
}


@end
