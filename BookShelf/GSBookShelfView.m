//
//  BookShelfView.m
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-22.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import "GSBookShelfView.h"
#import "GSBookViewContainerView.h"
#import "GSCellContainerView.h"

@interface GSBookShelfView (Private)

- (CGRect)visibleRect;
- (void)resetContentSize;

@end

@implementation GSBookShelfView

@synthesize shelfViewDelegate = _shelfViewDelegate;
@synthesize dataSource = _dataSource;
@synthesize dragAndDropEnabled = _dragAndDropEnabled;
@synthesize cellHeight = _cellHeight;
@synthesize cellMarginWidth = _cellMarginWidth;
@synthesize bookViewBottomOffset = _bookViewBottomOffset;
@synthesize numberOfBooksInCell = _numberOfBooksInCell;

// init 

- (id)initWithFrame:(CGRect)frame {
    NSLog(@"You should Use the initWithFrame:cellHeight:cellMarginWidth:bookViewBottomOffset:numberOfBooksInCell: to init the BookShelfView");
    return nil;
}

- (id)initWithFrame:(CGRect)frame cellHeight:(CGFloat)cellHeight cellMarginWidth:(CGFloat)cellMarginWidth bookViewBottomOffset:(CGFloat)bookViewBottomOffset numberOfBooksInCell:(NSInteger)numberOfBooksInCell {
    
    self = [super initWithFrame:frame];
    if (self) {
        _cellHeight = cellHeight;
        _cellMarginWidth = cellMarginWidth;
        _bookViewBottomOffset = bookViewBottomOffset;
        _numberOfBooksInCell = numberOfBooksInCell;
        
        _dragAndDropEnabled = YES;
        
        _bookViewContainerView = [[GSBookViewContainerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        _bookViewContainerView.parentBookShelfView = self;
        _cellContainerView = [[GSCellContainerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        
        [self addSubview:_cellContainerView];
        [self addSubview:_bookViewContainerView];
        

    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [self resetContentSize];
    
}

#pragma mark - Private Methods

- (CGRect)visibleRect {
    CGRect visibleRect = [self bounds];
    
    return visibleRect;
}

- (void)resetContentSize {
    //NSLog(@"resetContentSize");
    NSInteger numberOfBooks = [_dataSource numberOfBooksInBookShelfView:self];
    // plus one cell for scrollView bounces
    NSInteger numberOfCells = ceilf((float)numberOfBooks / (float)_numberOfBooksInCell);
    
    CGRect visibleRect = [self visibleRect];
    // fill the visible rect with cells and plus one cell for scrollView bounces
    float minNumberOfCells = floorf(visibleRect.size.height / _cellHeight);
    
    
    CGFloat contentSizeHeight = MAX(numberOfCells, minNumberOfCells) * _cellHeight;;
    
    [self setContentSize:CGSizeMake(self.frame.size.width, contentSizeHeight)];
    
    // Set Bounds For the two container view
    [_cellContainerView setFrame:CGRectMake(_cellContainerView.frame.origin.x, _cellContainerView.frame.origin.y, self.contentSize.width, self.contentSize.height)];
    [_bookViewContainerView setFrame:CGRectMake(_bookViewContainerView.frame.origin.x, _bookViewContainerView.frame.origin.y, self.contentSize.width, self.contentSize.height)];
    
    //NSLog(@"cellContainerView frame:%@", NSStringFromCGRect(_cellContainerView.frame));
}

#pragma mark Layout

- (void)layoutSubviews {
    //NSLog(@"layout");
    [super layoutSubviews];
    
    //[_bookViewContainerView setNeedsLayout];
    [_bookViewContainerView layoutSubviewsWithVisibleRect:[self visibleRect]];
}



@end
