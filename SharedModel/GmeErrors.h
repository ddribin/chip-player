//
//  GmeErrors.h
//  RetroPlayer
//
//  Created by Dave Dribin on 3/30/10.
//  Copyright 2010 Bit Maki, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "gme/gme.h"


extern NSString * const GmeErrorDomain;

@interface NSError (GME)

+ (id)gme_error:(gme_err_t)error;

@end
