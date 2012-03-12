//
//  CellContainerView.h
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-24.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GSBookShelfView;

@interface GSCellContainerView : UIView {
    GSBookShelfView __unsafe_unretained *_parentBookShelfView;
    
    @private
    
    NSInteger _firstVisibleRow;
    NSInteger _lastVisibleRow;
    
    NSMutableArray *_visibleCells;
    NSMutableDictionary *_reuseableCells;
    
    
}

@property (nonatomic, unsafe_unretained) GSBookShelfView *parentBookShelfView;

- (void)reloadData;
- (UIView *)dequeueReuseableCellWithIdentifier:(NSString *)identifier;
- (void)layoutSubviewsWithVisibleRect:(CGRect)visibleRect;

@end
