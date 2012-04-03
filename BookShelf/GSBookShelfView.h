/*
 BookShelfView.h
 BookShelf
 
 Created by Xinrong Guo on 12-2-22.
 Copyright (c) 2012 FoOTOo. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 Neither the name of the project's author nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <UIKit/UIKit.h>
#import "NSMutableArray+Rearrange.h"

@class GSBookViewContainerView;
@class GSCellContainerView;

@protocol GSBookShelfViewDelegate;
@protocol GSBookShelfViewDataSource;

@interface GSBookShelfView : UIScrollView {
@private
    id<GSBookShelfViewDataSource> __unsafe_unretained _dataSource;
    
    GSBookViewContainerView *_bookViewContainerView;
    GSCellContainerView *_cellContainerView;
    
    UIView *_headerView;
    UIView *_aboveTopView;
    UIView *_belowBottomView;
    
    // Function Enabler
    
    BOOL _dragAndDropEnabled;
    BOOL _scrollWhileDragingEnabled;
    //BOOL _editModeEnabled; //only support Delete Now, May add a AddButton Like Book at index 0 to support add
    
    
    // Layout of books and cells
    
    CGFloat _cellHeight;
    CGFloat _cellMargin;
    
    CGFloat _bookViewBottomOffset;
    
    CGFloat _shelfShadowHeight;
    
    NSInteger _numberOfBooksInCell;
}

@property (nonatomic, unsafe_unretained) id<GSBookShelfViewDataSource> dataSource;

@property (nonatomic, readonly) UIView *headerView;
@property (nonatomic, readonly) UIView *aboveTopView;
@property (nonatomic, readonly) UIView *belowBottomView;

@property (nonatomic, readonly) BOOL dragAndDropEnabled;
@property (nonatomic, assign) BOOL scrollWhileDragingEnabled;

@property (nonatomic, readonly) CGFloat cellHeight; // height of each cell
@property (nonatomic, readonly) CGFloat cellMargin; // margin of cell where to display the first book
@property (nonatomic, readonly) CGFloat bookViewBottomOffset;  // distance from the bottom of bookview to the top of cell, which means where the books should put on the shelf

@property (nonatomic, readonly) CGFloat shelfShadowHeight; // the shadow heigt of cell (in iBooks the shelf image has a shadow that will cover the cell below it, so if your image of cell has a shadow like this, you can set the shadow's height. If not set it zero
@property (nonatomic, readonly) NSInteger numberOfBooksInCell;

- (UIView *)dequeueReuseableBookViewWithIdentifier:(NSString *)identifier;
- (UIView *)dequeueReuseableCellViewWithIdentifier:(NSString *)identifier;

- (NSArray *)visibleBookViews;
- (NSArray *)visibleCells;
- (UIView *)bookViewAtIndex:(NSInteger)index;
- (UIView *)cellAtRow:(NSInteger)row;
//- (UIView *)bookViewAtIndex:(NSInteger)index;
//- (UIView *)cellAtIndex:(NSInteger)index;

- (void)reloadData;

- (void)removeBookViewsAtIndexs:(NSIndexSet *)indexs animate:(BOOL)animate;
- (void)insertBookViewsAtIndexs:(NSIndexSet *)indexs animate:(BOOL)animate; 

@end

@protocol GSBookShelfViewDataSource <NSObject>

- (NSInteger)numberOfBooksInBookShelfView:(GSBookShelfView *)bookShelfView; // Total number of Books
- (NSInteger)numberOFBooksInCellOfBookShelfView:(GSBookShelfView *)bookShelfView; // Number of books in each cell

- (UIView *)bookShelfView:(GSBookShelfView *)bookShelfView bookViewAtIndex:(NSInteger)index;
- (UIView *)bookShelfView:(GSBookShelfView *)bookShelfView cellForRow:(NSInteger)row;

- (UIView *)aboveTopViewOfBookShelfView:(GSBookShelfView *)bookShelfView; // View tha will be shown when you drag down |bookShelfView| and reach the edge.
- (UIView *)belowBottomViewOfBookShelfView:(GSBookShelfView *)bookShelfView; // View tha will be shown when you drag up |bookShelfView| and reach the edge.

- (UIView *)headerViewOfBookShelfView:(GSBookShelfView *)bookShelfView; // This view will be shown above the first cell. You can return a UISearchBar or something you like.

// The followings help with the layout of books
// Take a look at the "comments.png" in BookShelf >> Image to understand what are these means
- (CGFloat)cellHeightOfBookShelfView:(GSBookShelfView *)bookShelfView;
- (CGFloat)cellMarginOfBookShelfView:(GSBookShelfView *)bookShelfView;

- (CGFloat)bookViewHeightOfBookShelfView:(GSBookShelfView *)bookShelfView;
- (CGFloat)bookViewWidthOfBookShelfView:(GSBookShelfView *)bookShelfView;

- (CGFloat)bookViewBottomOffsetOfBookShelfView:(GSBookShelfView *)bookShelfView;

// The shadow heigt of cell (in iBooks the shelf image has a shadow that will cover the cell below it, 
// so if your image of cell has a shadow like this, you can set it with the shadow's height. If not set it zero
- (CGFloat)cellShadowHeightOfBookShelfView:(GSBookShelfView *)bookShelfView;

@optional
// Override to support rearranging.
- (void)bookShelfView:(GSBookShelfView *)bookShelfView moveBookFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end

@protocol GSBookShelfViewDelegate <NSObject>

// no use currently

@end
