//
//  FirebaseHelper.m
//  Napkn
//
//  Created by Zach Whelchel on 7/16/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "FirebaseHelper.h"

@implementation FirebaseHelper

+ (Firebase *)baseFirebaseReference
{
    return [[Firebase alloc] initWithUrl:@"https://sweet-nothings.firebaseio.com"];
}

+ (Firebase *)userFirebaseReference
{
    if ([self userIsLoggedIn]) {
        return [[self baseFirebaseReference] childByAppendingPath:[NSString stringWithFormat:@"/users/%@/", [self userUID]]];
    }
    else {
        return nil;
    }
}

+ (Firebase *)thoughtsFirebaseReference
{
    if ([self userIsLoggedIn]) {
        return [[self userFirebaseReference] childByAppendingPath:[NSString stringWithFormat:@"/thoughts/"]];
    }
    else {
        return nil;
    }
}

+ (BOOL)userIsLoggedIn
{
    Firebase *ref = [self baseFirebaseReference];
    return ref.authData == nil ? NO : YES;
}

+ (void)logUserOut
{
    Firebase *ref = [self baseFirebaseReference];
    [ref unauth];
}

+ (NSString *)userUID
{
    Firebase *ref = [self baseFirebaseReference];
    return [ref.authData uid];
}

+ (BOOL)stringIsValidEmail:(NSString *)string
{
    NSString *emailRegex = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:string];
}

@end
