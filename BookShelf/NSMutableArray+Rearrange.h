//
//  NSMutableArray+Rearrange.h
//  BookShelf
//
//  Created by 鑫容 郭 on 12-3-2.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Rearrange)

- (void)moveObjectFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
