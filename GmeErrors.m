//
//  GmeErrors.m
//  RetroPlayer
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import "GmeErrors.h"

NSString * const GmeErrorDomain = @"net.fly.ant";

@implementation NSError (GME)

+ (id)gme_error:(gme_err_t)error;
{
    NSString * nsError = [NSString stringWithUTF8String:error];
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               nsError, @"foo",
                               nil];
    
    NSError * errorObject = [NSError errorWithDomain:GmeErrorDomain code:0 userInfo:userInfo];
    return errorObject;
}

@end
