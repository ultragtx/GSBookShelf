//
//  BookShelfView.h
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-22.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSMutableArray+Rearrange.h"

@class GSBookViewContainerView;
@class GSCellContainerView;

@protocol GSBookShelfViewDelegate;
@protocol GSBookShelfViewDataSource;

@interface GSBookShelfView : UIScrollView {
    id<GSBookShelfViewDelegate> __unsafe_unretained _shelfViewDelegate;
    id<GSBookShelfViewDataSource> __unsafe_unretained _dataSource;
    
    GSBookViewContainerView *_bookViewContainerView;
    GSCellContainerView *_cellContainerView;
    
    // Function Enabler
    
    BOOL _dragAndDropEnabled;
    BOOL _scrollWhileDragingEnabled;
    //BOOL _editModeEnabled; //only support Delete Now, May add a AddButton Like Book at index 0 to support add
    
    
    // Layout of books and cells
    
    CGFloat _cellHeight; // height of each cell
    CGFloat _cellMarginWidth; // margin of cell where to display the first book
    
    CGFloat _bookViewBottomOffset;  // distance from the bottom of bookview to the top of cell, which means where the books should put on the shelf
    
    NSInteger _numberOfBooksInCell;
    
    @private
    
    
}

@property (nonatomic, unsafe_unretained) id<GSBookShelfViewDelegate> shelfViewDelegate;
@property (nonatomic, unsafe_unretained) id<GSBookShelfViewDataSource> dataSource;

@property (nonatomic, readonly) BOOL dragAndDropEnabled;
@property (nonatomic, assign) BOOL scrollWhileDragingEnabled;

@property (nonatomic, readonly) CGFloat cellHeight;
@property (nonatomic, readonly) CGFloat cellMarginWidth;
@property (nonatomic, readonly) CGFloat bookViewBottomOffset;
@property (nonatomic, readonly) NSInteger numberOfBooksInCell;

- (id)initWithFrame:(CGRect)frame cellHeight:(CGFloat)cellHeight cellMarginWidth:(CGFloat)cellMarginWidth bookViewBottomOffset:(CGFloat)bookViewBottomOffset numberOfBooksInCell:(NSInteger)numberOfBooksInCell;

- (UIView *)dequeueReuseableBookViewWithIdentifier:(NSString *)identifier;
- (UIView *)dequeueReuseableCellViewWithIdentifier:(NSString *)identifier;

- (NSArray *)visibleBooks;
- (NSArray *)visibleCells;

- (void)deleteBookAtIndex:(NSInteger)index animate:(BOOL)animate;
- (void)deleteBookAtIndexs:(NSArray *)indexs animate:(BOOL)animate;
- (void)addBookAtIndex:(NSInteger)index animate:(BOOL)animate;
@end

@protocol GSBookShelfViewDataSource <NSObject>

//- (CGFloat)heightOfCellInBookShelfView:(GSBookShelfView *)bookShelfView;

//- (NSInteger)numberOfCellsInBookShelfView:(GSBookShelfView *)bookShelfView;

//- (NSInteger)numberOfBooksInCellOfBookShelfView:(GSBookShelfView *)bookShelfView; // Books on Each Cell

- (NSInteger)numberOfBooksInBookShelfView:(GSBookShelfView *)bookShelfView; // Total number of Books

- (UIView *)bookShelfView:(GSBookShelfView *)bookShelfView bookViewAtIndex:(NSInteger)index;
- (UIView *)bookShelfView:(GSBookShelfView *)bookShelfView cellForRow:(NSInteger)row;

@optional
// Override to support rearranging.
- (void)bookShelfView:(GSBookShelfView *)bookShelfView moveBookFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end

@protocol GSBookShelfViewDelegate <NSObject>



@end
