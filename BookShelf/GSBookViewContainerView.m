//
//  BookViewContainerView.m
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-24.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import "GSBookViewContainerView.h"
#import "GSBookShelfView.h"
#import "GSBookView.h"

#define kRatio_width_spacing 2.2f
#define kRatio_height_width 1.414f

#define kGrow_animation_duration 0.15
#define kSrink_animation_duration 0.15

typedef enum {
    ADD_TYPE_FIRSTTIME,
    ADD_TYPE_HEAD,
    ADD_TYPE_TAIL
}AddType;

typedef enum {
    RM_TYPE_HEAD,
    RM_TYPE_TAIL
}RemoveType;

@interface GSBookViewContainerView (Private)

// Animation
- (void)growAnimationAtPoint:(CGPoint)point forView:(UIView *)view;

// BookView Rect
- (CGRect)bookViewRectAtRow:(NSInteger)row col:(NSInteger)col;

@end

@interface GSBookViewContainerView (Test)

- (void)checkVisibleBookViewsValid;
@end

@implementation GSBookViewContainerView

@synthesize parentBookShelfView = _parentBookShelfView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        _reuseableBookViews = [[NSMutableSet alloc] initWithCapacity:0];
        
        _firstVisibleRow = -1;
        _lastVisibleRow = -1;
        
        _visibleBookViews = [[NSMutableArray alloc] initWithCapacity:0];
        
        // dragAndDrop
        _isDragViewPickedUp = NO;
        
        // GestureRecognizer
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        [self addGestureRecognizer:longPressGestureRecognizer];
        
    }
    return self;
}

#pragma mark - Accessors

- (void)setParentBookShelfView:(GSBookShelfView *)parentBookShelfView {
    _parentBookShelfView = parentBookShelfView;
    
    // calculate bookview's size and spacing
    
    CGFloat cellWidth = _parentBookShelfView.frame.size.width;
    CGFloat cellMarginWidth = _parentBookShelfView.cellMarginWidth;
    NSInteger numOfBooksInCell = _parentBookShelfView.numberOfBooksInCell;
    
    _bookViewSpacingWidth = (cellWidth - 2 * cellMarginWidth) / (numOfBooksInCell * kRatio_width_spacing + (numOfBooksInCell - 1));
    
    _bookViewWidth = _bookViewSpacingWidth * kRatio_width_spacing;
    _bookViewHeight = _bookViewWidth * kRatio_height_width;
}

#pragma mark - Layout 

- (GSBookView *)addBookViewAsSubviewWith:(NSInteger)index row:(NSInteger)row col:(NSInteger)col {
    
    GSBookView *bookView = [_parentBookShelfView.dataSource bookShelfView:_parentBookShelfView bookViewAtIndex:index];
    
    bookView.tag = index; // set the tag as the index
    
    [bookView setFrame:[self bookViewRectAtRow:row col:col]];
    
    //NSLog(@"bookView Frame:%@", NSStringFromCGRect(bookView.frame));
    
    [self addSubview:bookView];
    return bookView;
}

- (void)addBookViewAtIndex:(NSInteger)index row:(NSInteger)row col:(NSInteger)col addType:(AddType)addType {
    
    GSBookView *bookView = [self addBookViewAsSubviewWith:index row:row col:col];
    
    switch (addType) {
        case ADD_TYPE_FIRSTTIME:
        case ADD_TYPE_TAIL:
            
            [_visibleBookViews addObject:bookView];
            break;
            
        case ADD_TYPE_HEAD:
            [_visibleBookViews insertObject:bookView atIndex:0];
            break;

    }
}

- (void)removeBookViewWithType:(RemoveType)rmType {
    NSInteger rmIndex;
    switch (rmType) {
        case RM_TYPE_HEAD:
            rmIndex = 0;
            break;
        case RM_TYPE_TAIL:
            rmIndex = [_visibleBookViews count] - 1;
    }
    GSBookView *bookView = [_visibleBookViews objectAtIndex:rmIndex];
    [_reuseableBookViews addObject:bookView];
    [bookView removeFromSuperview];
    [_visibleBookViews removeObjectAtIndex:rmIndex];
}


- (void)layoutSubviewsWithVisibleRect:(CGRect)visibleRect {
    //NSLog(@"bookViewContainer layout");
    //CGRect visibleRect = [self bounds];
    //NSLog(@"visibleRect %@", NSStringFromCGRect(visibleRect));
    _visibleRect = visibleRect;
    
    NSInteger numberOfBooksInCell = _parentBookShelfView.numberOfBooksInCell;
    
    NSInteger numberOfBooks = [_parentBookShelfView.dataSource numberOfBooksInBookShelfView:_parentBookShelfView];
    
    NSInteger numberOfCells = ceilf((float)numberOfBooks / (float)numberOfBooksInCell);
    
    
    NSInteger firstNeededRow = MAX(0, floorf(CGRectGetMinY(visibleRect) / _parentBookShelfView.cellHeight));
    NSInteger lastNeededRow = MIN(numberOfCells - 1, floorf(CGRectGetMaxY(visibleRect) / _parentBookShelfView.cellHeight));
    
    //NSLog(@"\n------------\nfirstNeededRow:%d firstVisibleRow:%d\nlastNeededRow: %d lastVisibleRow: %d\n************", firstNeededRow, _firstVisibleRow, lastNeededRow, _lastVisibleRow);
    
    // remove and add bookview according to the row
    if (_firstVisibleRow == -1) {
        // First time 
        for (NSInteger row = firstNeededRow; row <= lastNeededRow; row++) {
            // add firstTime
            for (NSInteger col = 0; col < numberOfBooksInCell; col++) {
                NSInteger index = row * numberOfBooksInCell + col;
                if (index >= numberOfBooks) {
                    break;
                }
                [self addBookViewAtIndex:index row:row col:col addType:ADD_TYPE_FIRSTTIME];
            }
        }
    }
    else {
        // Not first time
        if (firstNeededRow < _firstVisibleRow) {
            NSInteger addToRow = (_firstVisibleRow - 1 < lastNeededRow) ? _firstVisibleRow - 1 : lastNeededRow; 
            
            for (NSInteger row = addToRow; row >= firstNeededRow; row--) {
                // add to head of the _visibileBookView
                // use reversed row to always add to index 0
                for (NSInteger col = numberOfBooksInCell - 1; col >= 0; col--) {
                    NSInteger index = row * numberOfBooksInCell + col;
                    if (index < numberOfBooks) {
                        [self addBookViewAtIndex:index row:row col:col addType:ADD_TYPE_HEAD];
                    }
                }
            }
        }
        
        if (lastNeededRow < _lastVisibleRow) {
            NSInteger rmFromRow = (_firstVisibleRow > lastNeededRow + 1) ? _firstVisibleRow : lastNeededRow + 1;
            for (NSInteger row = _lastVisibleRow; row >= rmFromRow; row--) {
                // rm from tail of the _visibleBookView
                // use reversed row to always remove at tile
                for (NSInteger col = numberOfBooksInCell - 1; col >= 0; col--) {
                    NSInteger index = row * numberOfBooksInCell + col;
                    if (index < numberOfBooks) {
                        [self removeBookViewWithType:RM_TYPE_TAIL];
                    }
                }
            }
        }
        
        if (lastNeededRow > _lastVisibleRow) {
            NSInteger addFromRow = (_lastVisibleRow + 1 > firstNeededRow) ? _lastVisibleRow + 1 : firstNeededRow;
            for (NSInteger row = addFromRow; row <= lastNeededRow; row++) {
                // add to tail
                for (NSInteger col = 0; col < numberOfBooksInCell; col++) {
                    NSInteger index = row * numberOfBooksInCell + col;
                    if (index >= numberOfBooks) {
                        break;
                    }
                    [self addBookViewAtIndex:index row:row col:col addType:ADD_TYPE_TAIL];
                }
            }
        }
        
        if (firstNeededRow > _firstVisibleRow) {
            NSInteger rmToRow = (_lastVisibleRow  <= firstNeededRow - 1) ? _lastVisibleRow : firstNeededRow - 1;
            for (NSInteger row = _firstVisibleRow; row <= rmToRow; row++) {
                // rm from head
                for (NSInteger col = 0; col < numberOfBooksInCell; col++) {
                    NSInteger index = row * numberOfBooksInCell + col;
                    if (index >= numberOfBooks) {
                        break;
                    }
                    [self removeBookViewWithType:RM_TYPE_HEAD];
                }
            }
        }
    }
    
    [self checkVisibleBookViewsValid];
    
    _firstVisibleRow = firstNeededRow;
    _lastVisibleRow = lastNeededRow;
}

#pragma mark - BookView Rect

- (CGRect)bookViewRectAtRow:(NSInteger)row col:(NSInteger)col {
    CGFloat cellHeight = _parentBookShelfView.cellHeight;
    CGFloat bookViewBottomOffset = _parentBookShelfView.bookViewBottomOffset;
    CGFloat cellMarginWidth = _parentBookShelfView.cellMarginWidth;
    
    CGFloat originX = cellMarginWidth + col * (_bookViewWidth + _bookViewSpacingWidth);
    CGFloat originY = row * cellHeight + bookViewBottomOffset - _bookViewHeight;
    
    return CGRectMake(originX, originY, _bookViewWidth, _bookViewHeight);
}

- (CGRect)bookViewRectAtPoint:(CGPoint)point {
    CGFloat cellHeight = _parentBookShelfView.cellHeight;
    
    NSInteger currentRow = floorf(point.y / cellHeight);
    
    CGFloat cellMarginWidth = _parentBookShelfView.cellMarginWidth; 
    
    NSInteger currentCol = floorf((point.x - cellMarginWidth) / (_bookViewWidth + _bookViewSpacingWidth));
    
    CGRect bookViewRect = [self bookViewRectAtRow:currentRow col:currentCol];
    

    if (!CGRectContainsPoint(bookViewRect, point)) {
        bookViewRect = CGRectZero;
    }
    
    return bookViewRect;
}

- (UIView *)bookViewAtPoint:(CGPoint)point {
    UIView *bookView = nil;
    
    CGFloat cellHeight = _parentBookShelfView.cellHeight;
    
    NSInteger numberOfBooksInCell = _parentBookShelfView.numberOfBooksInCell;
    
    NSInteger numberOfBooks = [_parentBookShelfView.dataSource numberOfBooksInBookShelfView:_parentBookShelfView];
    
    NSInteger currentRow = floorf(point.y / cellHeight);
    
    for (NSInteger col = 0; col < numberOfBooksInCell; col++) {
        NSInteger index = currentRow * numberOfBooksInCell + col;
        if (index >= numberOfBooks) {
            break;
        }
        CGRect bookViewRect = [self bookViewRectAtRow:currentRow col:col];
        if (CGRectContainsPoint(bookViewRect, point)) {
            
            NSInteger indexOfVisibleBookViews = numberOfBooksInCell * (currentRow - _firstVisibleRow) + col;
            bookView = [_visibleBookViews objectAtIndex:indexOfVisibleBookViews];
            
            //NSInteger firstVisibleIndex = _firstVisibleRow * numberOfBooksInCell;
            //NSLog(@"indexOfVisible: %d", indexOfVisibleBookViews);
            //NSLog(@"index: %d", indexOfVisibleBookViews + firstVisibleIndex);
            break;
        }
    }
    return bookView;
}

#pragma mark - Gesture Recognizer

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [gestureRecognizer locationInView:self];
        BOOL dragAndDropEnable = _parentBookShelfView.dragAndDropEnabled;

        UIView *view = [self bookViewAtPoint:touchPoint];

        if (dragAndDropEnable && view != nil) {
            [self bringSubviewToFront:view];
            _dragView = view;
            [self growAnimationAtPoint:touchPoint forView:_dragView];
            _isDragViewPickedUp = YES;
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (_isDragViewPickedUp) {
            CGPoint touchPoint = [gestureRecognizer locationInView:self];
            _dragView.center = touchPoint;
            
            UIView *targetView = [self bookViewAtPoint:touchPoint];
            if (targetView != nil && targetView != _dragView) {
                // Rerange _visibleBookViews
            }
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (_isDragViewPickedUp) {
            
        }
    }
}

#pragma mark - Animation 

- (void)growAnimationAtPoint:(CGPoint)point forView:(UIView *)view {
    [UIView animateWithDuration:kGrow_animation_duration animations:^{
        view.transform = CGAffineTransformMakeScale(1.2, 1.2);
        view.center = point;
    }];
}

- (void)shrinkAnimationToPoint:(CGPoint)point forView:(UIView *)view {
    
}


#pragma mark - test

- (void)checkVisibleBookViewsValid {
    //NSLog(@"---------------------------");
    int i = ((UIView *)[_visibleBookViews objectAtIndex:0]).tag;
    for (UIView *view in _visibleBookViews) {
        if (i != view.tag) {
            NSLog(@"$$$$$$ checkVisibleBookViewsValid error");
        }
        i++;
    }
    //NSLog(@"***************************");
}

@end
