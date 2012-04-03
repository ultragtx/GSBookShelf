/*
 BookShelfView.m
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

#import "GSBookShelfView.h"
#import "GSBookViewContainerView.h"
#import "GSCellContainerView.h"

@interface GSBookShelfView (Private)

- (CGRect)visibleRect;
- (void)resetContentSize;

@end

@implementation GSBookShelfView

//@synthesize shelfViewDelegate = _shelfViewDelegate;
@synthesize dataSource = _dataSource;
@synthesize dragAndDropEnabled = _dragAndDropEnabled;
@synthesize scrollWhileDragingEnabled = _scrollWhileDragingEnabled;
@synthesize cellHeight = _cellHeight;
@synthesize cellMargin = _cellMargin;
@synthesize bookViewBottomOffset = _bookViewBottomOffset;
@synthesize shelfShadowHeight = _shelfShadowHeight;
@synthesize numberOfBooksInCell = _numberOfBooksInCell;

@synthesize headerView = _headerView;
@synthesize aboveTopView = _aboveTopView;
@synthesize belowBottomView = _belowBottomView;

// init 

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _dragAndDropEnabled = YES;
        _scrollWhileDragingEnabled = YES;
        
        _bookViewContainerView = [[GSBookViewContainerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        _bookViewContainerView.parentBookShelfView = self;
        _cellContainerView = [[GSCellContainerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        _cellContainerView.parentBookShelfView = self;
        
        [self addSubview:_cellContainerView];
        [self addSubview:_bookViewContainerView];
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [self reloadData];
}

#pragma mark - Accessors

- (void)setDataSource:(id<GSBookShelfViewDataSource>)dataSource {
    _dataSource = dataSource;
    if (![_dataSource respondsToSelector:@selector(bookShelfView:moveBookFromIndex:toIndex:)]) {
        _dragAndDropEnabled = NO;
    }
}

#pragma mark - Private Methods

- (CGRect)visibleRect {
    // visibleRect for the two container views
    CGRect visibleRect = [self bounds];
    CGFloat headerHeight = _headerView.frame.size.height;
    visibleRect.size.height -= fmaxf(headerHeight - visibleRect.origin.y, 0.0f);
    visibleRect.origin.y = fmaxf(visibleRect.origin.y - headerHeight, 0.0f);
    return visibleRect;
}

- (void)resetContentSize {
    //NSLog(@"resetContentSize");
    
    // Use the flowing code beteen /* */ to set a custom position for header
    /*
     CGFloat headerHeight = 44.0f;
     [_headerView setFrame:CGRectMake(0, _headerView.frame.size.height - headerHeight, _headerView.frame.size.width, _headerView.frame.size.height)];
     */
    CGFloat headerHeight = _headerView.frame.size.height;
    
    NSInteger numberOfBooks = [_dataSource numberOfBooksInBookShelfView:self];
    // plus one cell for scrollView bounces
    NSInteger numberOfCells = ceilf((float)numberOfBooks / (float)_numberOfBooksInCell);
    
    CGRect bounds = [self bounds];
    // fill the visible rect with cells and plus one cell for scrollView bounces
    NSInteger minNumberOfCells = ceilf(bounds.size.height/ _cellHeight);
    
    
    CGFloat contentSizeHeight = MAX(numberOfCells, minNumberOfCells) * _cellHeight + headerHeight;
    
    [self setContentSize:CGSizeMake(self.frame.size.width, contentSizeHeight)];
    
    // Set Bounds For the two container view
    [_cellContainerView setFrame:CGRectMake(0, 0 + headerHeight, self.contentSize.width, self.contentSize.height - headerHeight)];
    [_bookViewContainerView setFrame:CGRectMake(0, 0 + headerHeight, self.contentSize.width, self.contentSize.height - headerHeight)];
    
    [_aboveTopView setFrame:CGRectMake(0, -_aboveTopView.frame.size.height, _aboveTopView.frame.size.width, _aboveTopView.frame.size.height)];
    
    [_belowBottomView setFrame:CGRectMake(0, self.contentSize.height, _belowBottomView.frame.size.width, _belowBottomView.frame.size.height)];
    
    //NSLog(@"cellContainerView frame:%@", NSStringFromCGRect(_cellContainerView.frame));
}

- (void)resetContentOffset {
    CGFloat headerHeight = _headerView.frame.size.height;
    CGPoint offset = CGPointMake(0, headerHeight);
    [self setContentOffset:offset];
}

#pragma mark - Layout

- (void)layoutSubviews {
    //NSLog(@"layout");
    [super layoutSubviews];
    
    //[_bookViewContainerView setNeedsLayout];
    [_bookViewContainerView layoutSubviewsWithVisibleRect:[self visibleRect]];
    [_cellContainerView layoutSubviewsWithVisibleRect:[self visibleRect]];
}

#pragma mark - Public

- (void)reloadData {

    _numberOfBooksInCell = [_dataSource numberOFBooksInCellOfBookShelfView:self];
    
    
    // remove these views first, set new and then add back
    [_headerView removeFromSuperview];
    [_aboveTopView removeFromSuperview];
    [_belowBottomView removeFromSuperview];
    
    _headerView = [_dataSource headerViewOfBookShelfView:self];
    _aboveTopView = [_dataSource aboveTopViewOfBookShelfView:self];
    _belowBottomView = [_dataSource belowBottomViewOfBookShelfView:self];
    
    [self insertSubview:_headerView atIndex:0];
    [self insertSubview:_aboveTopView atIndex:0];
    [self insertSubview:_belowBottomView atIndex:0];
    
    _cellHeight = [_dataSource cellHeightOfBookShelfView:self];
    _cellMargin = [_dataSource cellMarginOfBookShelfView:self];
    _bookViewBottomOffset = [_dataSource bookViewBottomOffsetOfBookShelfView:self];
    
    [_cellContainerView reloadData];
    [_bookViewContainerView reloadData];
    [self resetContentSize];
    [self resetContentOffset];
    [self setNeedsLayout];
}

- (UIView *)dequeueReuseableBookViewWithIdentifier:(NSString *)identifier {
    return [_bookViewContainerView dequeueReusableBookViewWithIdentifier:identifier];
}

- (UIView *)dequeueReuseableCellViewWithIdentifier:(NSString *)identifier {
    return [_cellContainerView dequeueReuseableCellWithIdentifier:identifier];
}

- (void)removeBookViewsAtIndexs:(NSIndexSet *)indexs animate:(BOOL)animate; {
    [self resetContentSize];
    CGPoint contentOffset = [self contentOffset];
    if (contentOffset.y + self.bounds.size.height > self.contentSize.height) {
        contentOffset.y = self.contentSize.height - self.bounds.size.height;
    }
    [self setContentOffset:contentOffset animated:NO];
    [_bookViewContainerView removeBookViewsAtIndexs:indexs animate:animate];
}

- (void)insertBookViewsAtIndexs:(NSIndexSet *)indexs animate:(BOOL)animate {

    [self resetContentSize];
    [_bookViewContainerView insertBookViewsAtIndexs:indexs animate:animate];
}

- (NSArray *)visibleBookViews {
    return [_bookViewContainerView visibleBookViews];
}

- (NSArray *)visibleCells {
    return [_cellContainerView visibleCells];
}

- (UIView *)bookViewAtIndex:(NSInteger)index {
    return [_bookViewContainerView bookViewAtIndex:index];
}

- (UIView *)cellAtRow:(NSInteger)row {
    return [_cellContainerView cellAtRow:row];
}

@end
