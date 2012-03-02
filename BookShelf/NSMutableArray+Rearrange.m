//
//  NSMutableArray+Rearrange.m
//  BookShelf
//
//  Created by 鑫容 郭 on 12-3-2.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import "NSMutableArray+Rearrange.h"

@implementation NSMutableArray (Rearrange)

- (void)moveObjectFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
    
    if (fromIndex != toIndex) {
        id __strong obj = [self objectAtIndex:fromIndex];
        [self removeObjectAtIndex:fromIndex];
        if (toIndex >= [self count]) {
            [self addObject:obj];
        }
        else {
            [self insertObject:obj atIndex:toIndex];
        }
    }
}

@end
