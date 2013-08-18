//
//  OCTGist.m
//  Me
//
//  Created by Boris Bügling on 11.08.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import "OCTGist.h"

@implementation OCTGist

+ (NSValueTransformer *)objectIDJSONTransformer {
	return [MTLValueTransformer reversibleTransformerWithBlock:^id(id object) {
        return object;
    }];
}

@end
