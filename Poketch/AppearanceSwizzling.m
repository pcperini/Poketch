//
//  AppearanceSwizzling.m
//  Poketch
//
//  Created by PATRICK PERINI on 3/7/16.
//  Copyright © 2016 pcperini. All rights reserved.
//

#import "AppearanceSwizzling.h"
#import <objc/message.h>

@implementation AppearanceSwizzling

+ (void)setupAppearances {
    id appearance = objc_msgSend(NSClassFromString(@"UITableViewIndex"), @selector(appearance));
    objc_msgSend(appearance,
        NSSelectorFromString(@"setFont:"),
        [UIFont fontWithName:@"PokemonGB" size:10.0]);
}

@end
