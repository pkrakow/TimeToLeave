//
//  DemoFeature.m
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
#import "DemoFeature.h"

@implementation DemoFeature

- (instancetype)initWithName:(NSString *)name
                      detail:(NSString *)detail
                        icon:(NSString *)icon
                  storyboard:(NSString *)storyboard {
    if (self = [super init]) {
        _displayName = name;
        _detailText = detail;
        _icon = icon;
        _storyboard = storyboard;
    }

    return self;
}

@end
