//
//  OCTGist.h
//  Me
//
//  Created by Boris Bügling on 11.08.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import "OCTObject.h"

@interface OCTGist : OCTObject

@property NSString* created_at;
@property NSDictionary* files;
@property NSArray* history;

@end
