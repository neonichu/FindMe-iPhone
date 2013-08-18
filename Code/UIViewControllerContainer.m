//
//  UIViewControllerContainer.m
//  Me
//
//  Created by Boris Bügling on 11.08.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import "UIViewControllerContainer.h"

@implementation UIViewControllerContainer

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.viewController.view.frame = self.contentView.bounds;
}

-(void)setViewController:(UIViewController *)viewController {
    if (_viewController == viewController) {
        return;
    }
    
    [_viewController.view removeFromSuperview];
    
    _viewController = viewController;
    [self.contentView addSubview:_viewController.view];
}

@end
