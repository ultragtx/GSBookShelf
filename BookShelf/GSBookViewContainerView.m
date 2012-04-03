/*
 BookViewContainerView.m
 BookShelf
 
 Created by Xinrong Guo on 12-2-24.
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

#import "GSBookViewContainerView.h"
#import "GSBookShelfView.h"
#import "GSBookView.h"

#define kRatio_width_spacing 2.5f
#define kRatio_height_width 1.2f

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

// reuse

- (void)addReuseableBookView:(UIView *)bookView;

// Scroll
- (void)stopScrollTimer;
- (void)scrollIfNecessary;

// Move
- (void)moveBooksIfNecessary;

// Animation
- (void)growAnimationAtPoint:(CGPoint)point forView:(UIView *)view;
- (void)animateBookViewToBookViewPostion:(BookViewPostion)toPosition rect:(CGRect)toRect;

// BookView Rect
- (CGRect)bookViewRectAtBookViewPosition:(BookViewPostion)position;

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

        _reuseableBookViews = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        _firstVisibleRow = -1;
        _lastVisibleRow = -1;
        
        _visibleBookViews = [[NSMutableArray alloc] initWithCapacity:0];
        
        // dragAndDrop
        _isDragViewPickedUp = NO;
        _isBooksMoving = NO;
        _isDragViewRemovedFromVisibleBookViews = NO;
        
        // Remove
        _isRemoving = NO;
        _indexsOfBookViewNotShown = [NSMutableIndexSet indexSet];
        _tempVisibleBookViewCollector = [[NSMutableArray alloc] initWithCapacity:0];
        
        // GestureRecognizer
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        [self addGestureRecognizer:longPressGestureRecognizer];
        
    }
    return self;
}

# pragma mark - Reload

- (void)calculateLayout {
    CGFloat cellWidth = _parentBookShelfView.frame.size.width;
    CGFloat cellMargin = _parentBookShelfView.cellMargin; //[_parentBookShelfView.dataSource cellMarginOfBookShelfView:_parentBookShelfView];
    
    NSInteger numOfBooksInCell = [_parentBookShelfView.dataSource numberOFBooksInCellOfBookShelfView:_parentBookShelfView];
    
    _bookViewWidth = [_parentBookShelfView.dataSource bookViewWidthOfBookShelfView:_parentBookShelfView];
    _bookViewHeight = [_parentBookShelfView.dataSource bookViewHeightOfBookShelfView:_parentBookShelfView];
    
    _bookViewSpacingWidth = (cellWidth - 2 * cellMargin - numOfBooksInCell * _bookViewWidth) / (numOfBooksInCell - 1);
}

- (void)reloadData {
    [self calculateLayout];
    
    // Flags
    // visible row
    _firstVisibleRow = -1;
    _lastVisibleRow = -1;
    
    // dragAndDrop
    _isDragViewPickedUp = NO;
    _isBooksMoving = NO;
    _isDragViewRemovedFromVisibleBookViews = NO;
    
    // Remove
    _isRemoving = NO;
    
    for (UIView *view in _visibleBookViews) {
        [view removeFromSuperview];
    }
    [_visibleBookViews removeAllObjects];
    
    [_reuseableBookViews removeAllObjects];
}

#pragma mark - Reuse

- (void)addReuseableBookView:(UIView *)bookView {
    NSString *reuseIdentifier = nil;
    if ([bookView respondsToSelector:@selector(reuseIdentifier)]) {
        reuseIdentifier = [(id<GSBookView>)bookView reuseIdentifier];
    }
    
    if (reuseIdentifier == nil) {
        return;
    }
    
    NSMutableSet *bookViewSet = [_reuseableBookViews objectForKey:reuseIdentifier];
    if (!bookViewSet) {
        bookViewSet = [[NSMutableSet alloc] initWithCapacity:0];
        [_reuseableBookViews setObject:bookViewSet forKey:reuseIdentifier];
    }
    [bookViewSet addObject:bookView];
    //NSLog(@"bookViewSet count:%d", [bookViewSet count]);
}

- (UIView *)dequeueReusableBookViewWithIdentifier:(NSString *)identifier {
    NSMutableSet *bookViewSet = (NSMutableSet *)[_reuseableBookViews objectForKey:identifier];
    UIView *bookView = [bookViewSet anyObject];
    if (bookView) {
        [bookViewSet removeObject:bookView];
    }
    return bookView;
}

#pragma mark - Layout 

- (UIView *)addBookViewAsSubviewWithBookViewPosition:(BookViewPostion)position {
    
    UIView *bookView = [_parentBookShelfView.dataSource bookShelfView:_parentBookShelfView bookViewAtIndex:position.index];
    // Take a look at the "Discussion" in removeBookViewWithType:
    // Since _dragView won't be removed from supervie, we should not add it or change the frame either. And although the new bookView returned from dataSource have the same position with _dragView, but they are not the same view, so set _dragView to bookView, ignore the bookView returned from dataSource.
    if (_isDragViewPickedUp && position.index == _pickUpPosition.index) {
        _isDragViewRemovedFromVisibleBookViews = NO;
        bookView = _dragView;
    }
    else {
        //bookView.tag = position.index; // set the tag as the index
        [bookView setFrame:[self bookViewRectAtBookViewPosition:position]];
        
        //NSLog(@"bookView Frame:%@", NSStringFromCGRect(bookView.frame));
        /*if (![_indexsOfBookViewToBeRemoved containsIndex:position.index] && !_isRemoving) {
            [self addSubview:bookView];
        }*/
        if (!([_indexsOfBookViewToBeRemoved containsIndex:position.index] || [_indexsOfBookViewNotShown containsIndex:position.index])) {
            [self addSubview:bookView];
        }
        
    }
    return bookView;
}

- (void)addBookViewAtBookViewPosition:(BookViewPostion) position addType:(AddType)addType {
    
    UIView *bookView = [self addBookViewAsSubviewWithBookViewPosition:position];
    
    NSMutableArray *visibleBookViews = _isRemoving ? _tempVisibleBookViewCollector : _visibleBookViews;
    
    switch (addType) {
        case ADD_TYPE_FIRSTTIME:
        case ADD_TYPE_TAIL:
            [visibleBookViews addObject:bookView];
            break;
            
        case ADD_TYPE_HEAD:
            [visibleBookViews insertObject:bookView atIndex:0];
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
    UIView *bookView = [_visibleBookViews objectAtIndex:rmIndex];
    // Discusstion:When Drag And Scroll happends,somtimes _dragView's pickupPosition may have not changed. Then it may be told to be removed from superView, and this will cause the _dragView dissappear. So here we prevent the removeFromSuperview from happening, but still remove it from the _visibleBookViews. _visibleBookViews tells which view is visible except the _dragView, which means _dragView is "invisible" for _visibleBookViews when it's original position scroll out of the _visibleRect.
    if (_isDragViewPickedUp && bookView == _dragView) {
        _isDragViewRemovedFromVisibleBookViews = YES;
    }
    else {
        [self addReuseableBookView:bookView];
        [bookView removeFromSuperview];
    }
    [_visibleBookViews removeObjectAtIndex:rmIndex];
}


- (void)layoutSubviewsWithVisibleRect:(CGRect)visibleRect {
    // To reduce memory usage, we only add visible bookViews to the subviews. So every time it scrolls, we shoud add and remove some bookViews.You can check the sample project (ScrollView Suit >> Tiling) for information.
    
    // Discussion: the layout sequence is easy to understand. There are 6 situation we should consider.  You can draw these condition on a papper to get it more clear.
    
    // 1. lastNeededRow < _firstVisibleRow
    // 2. firstNeededRow < _firstVisibleRow && lastNeededRow > _firstVisibleRow && lastNeededRow < _lastVisibleRow
    // 3. firstNeededRow < _firstVisibleRow && lastNeededRow > _lastVisibleRow
    // 4. firstNeededRow > _firstVisibleRow && lastNeededRow < _lastVisibleRow
    // 5. firstNeededRow > _firstVisibleRow && firstNeededRow < _lastVisibleRow && lastNeededRow > _lastVisibleRow
    // 6. firstNeededRow > _lastVisibleRow
    
    // We deal with these situations with a sequence of operation:
    // 1. if (lastNeededRow < _lastVisibleRow) remove some from the tail of _visibleBookViews
    // 2. if (firstNeededRow < _firstVisibleRow) add some to the head of _visibleBookViews
    // 3. if (firstNeededRow > _firstVisibleRow) remove some from the head of _visibleBookViews
    // 4. if (lastNeededRow > _lastVisibleRow) add some to the tail of _visibleBookViews
    
    // only two of these four steps will happen for each situation. Thanks to these we don't need to consider about where to insert or remove a propper bookView. Just add or remove then at the head or tail.

    
    //NSLog(@"bookViewContainer layout");
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
                BookViewPostion position = {row, col, index};
                [self addBookViewAtBookViewPosition:position addType:ADD_TYPE_FIRSTTIME];
            }
        }
    }
    else {
        // Not first time
        
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
        
        if (firstNeededRow < _firstVisibleRow) {
            NSInteger addToRow = (_firstVisibleRow - 1 < lastNeededRow) ? _firstVisibleRow - 1 : lastNeededRow; 
            
            for (NSInteger row = addToRow; row >= firstNeededRow; row--) {
                // add to head of the _visibileBookView
                // use reversed row to always add to index 0
                for (NSInteger col = numberOfBooksInCell - 1; col >= 0; col--) {
                    NSInteger index = row * numberOfBooksInCell + col;
                    if (index < numberOfBooks) {
                        BookViewPostion position = {row, col, index};
                        [self addBookViewAtBookViewPosition:position addType:ADD_TYPE_HEAD];
                    }
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

        
        if (lastNeededRow > _lastVisibleRow) {
            NSInteger addFromRow = (_lastVisibleRow + 1 > firstNeededRow) ? _lastVisibleRow + 1 : firstNeededRow;
            for (NSInteger row = addFromRow; row <= lastNeededRow; row++) {
                // add to tail
                for (NSInteger col = 0; col < numberOfBooksInCell; col++) {
                    NSInteger index = row * numberOfBooksInCell + col;
                    if (index >= numberOfBooks) {
                        break;
                    }
                    BookViewPostion position = {row, col, index};
                    [self addBookViewAtBookViewPosition:position addType:ADD_TYPE_TAIL];
                }
            }
        }
    }
    
    //[self checkVisibleBookViewsValid];
    //NSLog(@"visible count:%d", [_visibleBookViews count]);
    _firstVisibleRow = firstNeededRow;
    _lastVisibleRow = lastNeededRow;
}

#pragma mark - BookViewPosition 

#pragma mark - BookView Rect

- (NSInteger)convertToIndexFromVisibleBookViewIndex:(NSInteger)index {
    // not safe for some events
    return _firstVisibleRow * _parentBookShelfView.numberOfBooksInCell + index;
}

- (BookViewPostion)convertToBookViewPositionFromIndex:(NSInteger)index {
    NSInteger row = index / _parentBookShelfView.numberOfBooksInCell;
    NSInteger col = index % _parentBookShelfView.numberOfBooksInCell;
    BookViewPostion position = {row, col, index};
    return position;
}

- (NSInteger)converToIndexOfVisibleBookViewsFromBookViewPosition:(BookViewPostion)position {
    
    NSInteger numberOfBooksInCell = _parentBookShelfView.numberOfBooksInCell;
    
    NSInteger indexOfVisibleBookViews = numberOfBooksInCell * (position.row - _firstVisibleRow) + position.col;
    
    return indexOfVisibleBookViews;
}

- (NSInteger)converToIndexOfVisibleBookViewsFromIndex:(NSInteger)index {
    BookViewPostion position = [self convertToBookViewPositionFromIndex:index];
    return [self converToIndexOfVisibleBookViewsFromBookViewPosition:position];
}

- (BOOL)isBookViewPositionVisible:(BookViewPostion)position {
    NSInteger numberOfBooks = [_parentBookShelfView.dataSource numberOfBooksInBookShelfView:_parentBookShelfView];
    
    /*if (position.index < numberOfBooks && position.index >= 0) {
        return YES;
    }*/
    if (position.row >= _firstVisibleRow && position.row <= _lastVisibleRow && position.index < numberOfBooks && position.index >= 0) {
        return YES;
    }
    
    return NO;
}

- (CGRect)bookViewRectAtBookViewPosition:(BookViewPostion)position {
    // Dose not need position.index here
    CGFloat cellHeight = _parentBookShelfView.cellHeight;
    CGFloat bookViewBottomOffset = _parentBookShelfView.bookViewBottomOffset;
    CGFloat cellMarginWidth = _parentBookShelfView.cellMargin;
    
    CGFloat originX = cellMarginWidth + position.col * (_bookViewWidth + _bookViewSpacingWidth);
    CGFloat originY = position.row * cellHeight + bookViewBottomOffset - _bookViewHeight;
    
    return CGRectMake(originX, originY, _bookViewWidth, _bookViewHeight);
}

- (BookViewPostion)bookViewPositionAtPoint:(CGPoint)point {
    // Always return a valid BookViewPosition
    CGFloat cellHeight = _parentBookShelfView.cellHeight;
    
    NSInteger currentRow = floorf(point.y / cellHeight);
    
    CGFloat cellMarginWidth = _parentBookShelfView.cellMargin; 
    
    NSInteger currentCol = floorf((point.x - cellMarginWidth) / (_bookViewWidth + _bookViewSpacingWidth));
    
    NSInteger numberOfBooksInCell = _parentBookShelfView.numberOfBooksInCell;
    
    BookViewPostion position = {currentRow, currentCol, currentRow * numberOfBooksInCell + currentCol};
    
    return position;
}

- (CGRect)bookViewRectAtPoint:(CGPoint)point {
    // Return an CGRectZero if the point is not in any bookView's frame
    BookViewPostion position = [self bookViewPositionAtPoint:point];
    CGRect bookViewRect = [self bookViewRectAtBookViewPosition:position];    

    if (!CGRectContainsPoint(bookViewRect, point)) {
        bookViewRect = CGRectZero;
    }
    
    return bookViewRect;
}

- (UIView *)bookViewAtPoint:(CGPoint)point {
    UIView *bookView = nil;
    
    BookViewPostion position = [self bookViewPositionAtPoint:point];
    CGRect bookViewRect = [self bookViewRectAtBookViewPosition:position];
    
    if (!CGRectEqualToRect(bookViewRect, CGRectZero) && [self isBookViewPositionVisible:position]) {
        // a valid bookViewRect
        NSInteger indexOfVisibleBookViews = [self converToIndexOfVisibleBookViewsFromBookViewPosition:position];
        
        bookView = [_visibleBookViews objectAtIndex:indexOfVisibleBookViews];
    }
    return bookView;
}

#pragma mark - Gesture Recognizer

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [gestureRecognizer locationInView:self];
        BOOL dragAndDropEnable = _parentBookShelfView.dragAndDropEnabled;
        if (dragAndDropEnable) {
            
            BookViewPostion position = [self bookViewPositionAtPoint:touchPoint];
            CGRect bookViewRect = [self bookViewRectAtBookViewPosition:position];
            
            if (CGRectContainsPoint(bookViewRect, touchPoint) && [self isBookViewPositionVisible:position]) {
                NSInteger indexOfVisibleBookViews = [self converToIndexOfVisibleBookViewsFromBookViewPosition:position];
                _dragView = [_visibleBookViews objectAtIndex:indexOfVisibleBookViews];
                [self bringSubviewToFront:_dragView];
                [self growAnimationAtPoint:touchPoint forView:_dragView];
                
                _pickUpPosition = position;
                _pickUpRect = bookViewRect;
                _isDragViewPickedUp = YES;
                _isDragViewRemovedFromVisibleBookViews = NO;
            }
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (_isDragViewPickedUp) {
            CGPoint touchPoint = [gestureRecognizer locationInView:self];
            _dragView.center = touchPoint;
            [self moveBooksIfNecessary];
            [self scrollIfNecessary];
            
        }
    }
    /*else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (_isDragViewPickedUp) {
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationCurveLinear | UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 _dragView.frame = _pickUpRect;
                             }
                             completion:^(BOOL finished) {
                                 _isDragViewPickedUp = NO;
                             }];
            
            
        }
        [self stopScrollTimer];
    }*/
    else {
        if (_isDragViewPickedUp) {
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationCurveLinear | UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 //_dragView.frame = _pickUpRect;
                                 _dragView.transform = CGAffineTransformIdentity;
                                 _dragView.center = CGPointMake(CGRectGetMidX(_pickUpRect), CGRectGetMidY(_pickUpRect));
                             }
                             completion:^(BOOL finished) {
                                 _isDragViewPickedUp = NO;
                                 if (_isDragViewRemovedFromVisibleBookViews) {
                                     [self addReuseableBookView:_dragView];
                                     [_dragView removeFromSuperview];
                                 }
                                 _dragView = nil;
                             }];
            
            
        }
        [self stopScrollTimer];
    }

}

#pragma mark - Scroll While Draging

#define kScroll_trigger_dis 40.0f
#define kScroll_interval_max 0.0075
#define kScroll_interval_min 0.00050

- (void)stopScrollTimer {
    [_scrollTimer invalidate];
}

- (void)scrollIfNecessary {
    if (_parentBookShelfView.scrollWhileDragingEnabled) {
        [self stopScrollTimer];
        CGFloat distanceFromTop = _dragView.center.y - _visibleRect.origin.y;
        if (distanceFromTop < kScroll_trigger_dis) {
            double rate = (kScroll_trigger_dis - distanceFromTop) / 6.0;
            NSTimeInterval interval = fmax(kScroll_interval_min, kScroll_interval_max / rate);
            _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(dragScroll:) userInfo:[NSNumber numberWithBool:YES] repeats:YES];
            
        }
        else if (distanceFromTop > _visibleRect.size.height - kScroll_trigger_dis) {
            
            double rate = (kScroll_trigger_dis - (_visibleRect.size.height - distanceFromTop)) / 6.0;
            NSTimeInterval interval = fmax(kScroll_interval_min, kScroll_interval_max / rate);
            _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(dragScroll:) userInfo:[NSNumber numberWithBool:NO] repeats:YES];
            
        }
    }
}

- (BOOL)canScroll:(BOOL)isScrollUp {
    if (isScrollUp) {
        if (_parentBookShelfView.contentOffset.y <= 0) {
            return NO;
        }
    }
    else {
        if (_parentBookShelfView.contentOffset.y + _visibleRect.size.height >=_parentBookShelfView.contentSize.height) {
            return NO;
        }
    }
    return YES;
}

- (void)dragScroll:(NSTimer *)timer {
    // contentOffset +/- 1
    BOOL isScrollUp = ((NSNumber *)timer.userInfo).boolValue;
    if ([self canScroll:isScrollUp]) {
        CGPoint newOffset = _parentBookShelfView.contentOffset;
        newOffset.y = newOffset.y + (isScrollUp ? -1 : 1);
        [_parentBookShelfView setContentOffset:newOffset];
        
        CGPoint newDragViewCenter = _dragView.center;
        newDragViewCenter.y = newDragViewCenter.y + (isScrollUp ? -1 : 1);
        _dragView.center = newDragViewCenter;
        [self moveBooksIfNecessary];
    }
}

#pragma mark - Move 

- (void)moveBooksIfNecessary {
    [self bringSubviewToFront:_dragView];
    BookViewPostion position = [self bookViewPositionAtPoint:_dragView.center];
    CGRect bookViewRect = [self bookViewRectAtBookViewPosition:position];

    if (CGRectContainsPoint(bookViewRect, _dragView.center) && [self isBookViewPositionVisible:position]) {
        if (!CGRectEqualToRect(bookViewRect, _pickUpRect)) {
            // Rerange _visibleBookViews
            [self animateBookViewToBookViewPostion:position rect:bookViewRect];
        }
    }
}

- (void)moveBookView:(UIView *)bookView steps:(NSInteger)steps {
    BookViewPostion position = [self bookViewPositionAtPoint:bookView.center];
    NSInteger nPerCell = _parentBookShelfView.numberOfBooksInCell;
    CGFloat horizontalDisPerStep = _bookViewWidth + _bookViewSpacingWidth;
    CGFloat verticalDisPerStep = _parentBookShelfView.cellHeight;
    
    NSInteger horizontalSteps = ((position.col + steps) % nPerCell + nPerCell) % nPerCell - position.col;
    NSInteger verticalSteps = floorf((position.col + steps) / (float) nPerCell);
    CGFloat newCenterX = bookView.center.x + horizontalSteps * horizontalDisPerStep;
    CGFloat newCenterY = bookView.center.y + verticalSteps * verticalDisPerStep;
    bookView.center = CGPointMake(newCenterX, newCenterY);
}

#pragma mark - Animation 

- (void)growAnimationAtPoint:(CGPoint)point forView:(UIView *)view {
    [UIView animateWithDuration:kGrow_animation_duration
                          delay:0.0
                        options:UIViewAnimationCurveLinear | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(1.2, 1.2);
                         view.center = point;
                     }
                     completion:NULL];
}

- (void)shrinkAnimationToPoint:(CGPoint)point forView:(UIView *)view {
    
}

- (void)animateBookViewToBookViewPostion:(BookViewPostion)toPosition rect:(CGRect)toRect {
    if (!_isBooksMoving) {
        BOOL shouldRemoveHeadOrTailFromVisibleBookViews = NO;
        if (_isDragViewRemovedFromVisibleBookViews) {
            // Take a look at the "Discussion" in removeBookViewWithType:
            // Discussion: if the _dragView is "invisible". _dragView maybe insert into the _visibleBookViews and the head or tail in _visibleBookViews should be removedFromSuperview to keep the _visibleBookViews contains only bookViews in visible rows.
            _isDragViewRemovedFromVisibleBookViews = NO;
            shouldRemoveHeadOrTailFromVisibleBookViews = YES;
        }
        
        if (_pickUpPosition.index < toPosition.index) {
            // drag forward/down
            
            NSInteger fromIndexOfVisibleBookViews = [self converToIndexOfVisibleBookViewsFromBookViewPosition:_pickUpPosition];
            NSInteger toIndexOfVisibleBookViews = [self converToIndexOfVisibleBookViewsFromBookViewPosition:toPosition];
            
            NSInteger indexOfBookViewToBeRemoved = MAX(0, fromIndexOfVisibleBookViews);
            UIView *bookViewToRemove = [_visibleBookViews objectAtIndex:indexOfBookViewToBeRemoved];
            
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 _isBooksMoving = YES;
                                 
                                 assert(toIndexOfVisibleBookViews < [_visibleBookViews count]);
                                 for (NSInteger index = MAX(0, fromIndexOfVisibleBookViews + 1); index <= MIN(toIndexOfVisibleBookViews, [_visibleBookViews count] - 1); index++) {
                                     UIView *bookView = [_visibleBookViews objectAtIndex:index];
                                     [self moveBookView:bookView steps:-1];
                                 }
                                 
                                 [_visibleBookViews removeObjectAtIndex:indexOfBookViewToBeRemoved];
                                 [_visibleBookViews insertObject:_dragView atIndex:toIndexOfVisibleBookViews];
                                 
                                 if ([_parentBookShelfView.dataSource respondsToSelector:@selector(bookShelfView:moveBookFromIndex:toIndex:)]) {
                                     [_parentBookShelfView.dataSource bookShelfView:_parentBookShelfView moveBookFromIndex:_pickUpPosition.index toIndex:toPosition.index];
                                 }
                                 
                                 _pickUpPosition = toPosition;
                                 _pickUpRect = toRect;
                             }
                             completion:^(BOOL finished) {
                                 _isBooksMoving = NO;
                                 if (shouldRemoveHeadOrTailFromVisibleBookViews) {
                                     [bookViewToRemove removeFromSuperview];
                                 }
                                 
                             }];
            
        }
        
        
        else {
            // drag backward/up
            
            NSInteger fromIndexOfVisibleBookViews = [self converToIndexOfVisibleBookViewsFromBookViewPosition:_pickUpPosition];
            NSInteger toIndexOfVisibleBookViews = [self converToIndexOfVisibleBookViewsFromBookViewPosition:toPosition];
            
            NSInteger indexOfBookViewToBeRemoved = MIN([_visibleBookViews count] - 1, fromIndexOfVisibleBookViews);
            UIView *bookViewToRemove = [_visibleBookViews objectAtIndex:indexOfBookViewToBeRemoved];
            
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionLayoutSubviews
                             animations:^{
                                 _isBooksMoving = YES;
                                 
                                 assert(toIndexOfVisibleBookViews >= 0);
                                 for (NSInteger index = MAX(0, toIndexOfVisibleBookViews); index <= MIN(fromIndexOfVisibleBookViews - 1, [_visibleBookViews count] - 1); index++) {
                                     UIView *bookView = [_visibleBookViews objectAtIndex:index];
                                     [self moveBookView:bookView steps:1];
                                 }
                                 
                                 [_visibleBookViews removeObjectAtIndex:indexOfBookViewToBeRemoved];
                                 [_visibleBookViews insertObject:_dragView atIndex:toIndexOfVisibleBookViews];
                                 
                                 if ([_parentBookShelfView.dataSource respondsToSelector:@selector(bookShelfView:moveBookFromIndex:toIndex:)]) {
                                     [_parentBookShelfView.dataSource bookShelfView:_parentBookShelfView moveBookFromIndex:_pickUpPosition.index toIndex:toPosition.index];
                                 }
                                 
                                 _pickUpPosition = toPosition;
                                 _pickUpRect = toRect;
                             }
                             completion:^(BOOL finished) {
                                 _isBooksMoving = NO;
                                 if (shouldRemoveHeadOrTailFromVisibleBookViews) {
                                     [bookViewToRemove removeFromSuperview];
                                 }

                             }];
        }
    }
}

#pragma mark - Delete and Add

- (void)removeBookViewsAtIndexs:(NSIndexSet *)indexs animate:(BOOL)animate; {
    // The animation Sequence is:
    // 1. make bookViews disappear (a scale to (0.001, 0.001) in fact)
    // 2. because some rows may be removed, we will set the contentOffset to a propper postition
    // 3. move bookViews to fill blank
    
    // Discussion 1: _parentBookShelfView's remove.... method did step 2 above before coming in to the current method. Seems the layoutSubviews called by setContentOffset(step 2) should occour before step 1. But the true is:layoutSubvies occour after step 1. I think it's "runloop" that cause this. Animation was set and then main thread enter next loop and layoutSubviews occour.(I'm not so sure about this.)
    
    // Discussion 2: 
    // step 1. in the first animation we scale the bookViews to be removed. The current visible bookVie will move to some position in step 3 so we record the steps for each visible bookView(stepsArray), and record the positions(indexs) they will move to(_indexsOfBookViewNotShown).
    // step 2. in the layoutSubviews. we add all new added bookView to  _tempVisibleBookViewCollector instead of _visibleBookViews to keep _visibleBookViews "clean"(contains only bookViews showed in step 1). And check if the added bookview index is in _indexsOfBookViewNotShown (not add them to subviews). After layoutSubviews, the contentOffset has been set properly, and the proper bookViews will show up with some blank waiting for some bookViews moving to.
    // step 3. This is simple, just let each bookViews move with the steps record in stepsArray. After all animation. We clean the Arrays and Sets and refresh the current contents to make some bookView visible and keep everything go back to normal status.
    
    _isRemoving = YES;
    _indexsOfBookViewToBeRemoved = [[NSMutableIndexSet alloc] initWithIndexSet:indexs];
    
    NSMutableArray *stepsArray = [[NSMutableArray alloc] initWithCapacity:[_visibleBookViews count]];
    
    // Record the bookViews to be remvoed
    [UIView animateWithDuration:animate ? 0.15 : 0.0
                          delay:0.0
                        options:UIViewAnimationCurveLinear | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         // Dissmiss BookView
                         //NSLog(@"disappear animation");
                         
                         __block NSInteger steps = 0;
                         __block NSInteger moveFromIndex = 0;
                         
                         [indexs enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
                             BookViewPostion position = [self convertToBookViewPositionFromIndex:index];
                             NSInteger indexOfVisibleBookViews = [self converToIndexOfVisibleBookViewsFromBookViewPosition:position];
                             if (indexOfVisibleBookViews >= 0) {
                                 if (indexOfVisibleBookViews >= [_visibleBookViews count]) {
                                     *stop = YES;
                                 }
                                 else {
                                     // shrink
                                     UIView *bookView = [_visibleBookViews objectAtIndex:indexOfVisibleBookViews];
                                     bookView.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
                                     
                                     // record _indexsOfBookViewNotShown
                                     BOOL overVisible = indexOfVisibleBookViews >= [_visibleBookViews count];
                                     NSInteger moveToIndex = overVisible ? [_visibleBookViews count] - 1 : indexOfVisibleBookViews;
                                     while (moveFromIndex <= moveToIndex) {
                                         NSInteger realIndex = [self convertToIndexFromVisibleBookViewIndex:moveFromIndex] - steps;
                                         [_indexsOfBookViewNotShown addIndex:realIndex];
                                         
                                         [stepsArray addObject:[NSNumber numberWithInt:-steps]];
                                         
                                         moveFromIndex++;
                                     }
                                 }
                             }

                             steps++;
                             
                             //NSLog(@"index not shown: %@", [_indexsOfBookViewNotShown description]);
                         }];
                         while (moveFromIndex < [_visibleBookViews count]) {
                             NSInteger realIndex = [self convertToIndexFromVisibleBookViewIndex:moveFromIndex] - steps;
                             [_indexsOfBookViewNotShown addIndex:realIndex];
                             
                             [stepsArray addObject:[NSNumber numberWithInt:-steps]];
                              
                             moveFromIndex++;
                         }
                     }completion:^(BOOL finished) {
                         //NSLog(@"disappear animation completion");
                         
                         [UIView animateWithDuration:animate ? 0.3 : 0.0
                                               delay:0.01
                                             options:UIViewAnimationCurveLinear
                                          animations:^ {
                                              //NSLog(@"move animation");
                                              for (int i = 0; i < [_visibleBookViews count]; i++) {
                                                  UIView *bookView = [_visibleBookViews objectAtIndex:i];
                                                  [self moveBookView:bookView steps:[(NSNumber *)[stepsArray objectAtIndex:i] intValue]];
                                              }
                                              return;
                                          }
                                          completion:^(BOOL finished) {
                                              //NSLog(@"move animation completion");
                                              [_indexsOfBookViewToBeRemoved removeAllIndexes];
                                              [_indexsOfBookViewNotShown removeAllIndexes];
                                              
                                              _isRemoving = NO;
                                              for (UIView *view in _tempVisibleBookViewCollector) {
                                                  [view removeFromSuperview];
                                              }
                                              [_tempVisibleBookViewCollector removeAllObjects];
                                              
                                              for (UIView *bookView in _visibleBookViews) {
                                                  [bookView removeFromSuperview];
                                              }
                                              [_visibleBookViews removeAllObjects];
                                              _firstVisibleRow = -1;
                                              _lastVisibleRow = -1;
                                              [_parentBookShelfView setNeedsLayout];
                                          }];
                     }];
}


- (void)insertBookViewsAtIndexs:(NSIndexSet *)indexs animate:(BOOL)animate; {
    // The animation Sequence is:
    // 1. move to get blanks for bookViews will be added
    // 2. show the added bookViews
    
    // Discussion:
    // step.1 we count from first insert index to the real index in _visibleBookView to calculte the steps of bookView in _visibleBookViews will move.
    // before animation in step 2.we get bookView from datasource and set the scale to (0.001,0.001) without animation
    // then in the animation, we set the bookView's scale to (1,1) to "show" the bookView and then refresh the _visibleBookView as we did in removeBookViewsAtIndexs:animate:
    [UIView animateWithDuration:animate ? 0.3 : 0.0
                          delay:0.0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         __block NSInteger steps = 0;
                         __block NSInteger moveFromIndex = 0;
                         __block NSInteger lastIndexInIndexs = -1;
                         __block NSInteger tempIndex = 0;
                         
                         [indexs enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
                             NSInteger diff = index - lastIndexInIndexs;
                             
                             if (diff > 1) {
                                 if (lastIndexInIndexs < 0) {
                                     // first enumerate
                                     tempIndex = index;
                                 }
                                 else {
                                     tempIndex = moveFromIndex + diff - 1;
                                 }
                                 while (moveFromIndex < tempIndex) {
                                     BookViewPostion position = [self convertToBookViewPositionFromIndex:moveFromIndex];
                                     NSInteger indexOfVisibleBookViews = [self converToIndexOfVisibleBookViewsFromBookViewPosition:position];
                                     if (indexOfVisibleBookViews > (NSInteger)[_visibleBookViews count] - 1) {
                                         *stop = YES;
                                         break;
                                     }
                                     else if (indexOfVisibleBookViews >= 0) {
                                         UIView *bookView = [_visibleBookViews objectAtIndex:indexOfVisibleBookViews];
                                         [self moveBookView:bookView steps:steps];
                                     }
                                     moveFromIndex++;
                                 }
                             }
                             steps++;
                             lastIndexInIndexs = index;
                         }];
                         while (YES) {
                             BookViewPostion position = [self convertToBookViewPositionFromIndex:moveFromIndex];
                             NSInteger indexOfVisibleBookViews = [self converToIndexOfVisibleBookViewsFromBookViewPosition:position];
                             if (indexOfVisibleBookViews > (NSInteger)[_visibleBookViews count] - 1) {
                                 break;
                             }
                             else if (indexOfVisibleBookViews >= 0) {
                                 UIView *bookView = [_visibleBookViews objectAtIndex:indexOfVisibleBookViews];
                                 [self moveBookView:bookView steps:steps];
                             }
                             moveFromIndex++;
                         }
                     }
                     completion:^(BOOL finished) {
                         NSMutableArray *tempBookViewArray = [[NSMutableArray alloc] initWithCapacity:0];
                         [indexs enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
                             BookViewPostion position = [self convertToBookViewPositionFromIndex:index];
                             if (position.row > _lastVisibleRow) {
                                 *stop = YES;
                             }
                             else if (position.row >= _firstVisibleRow) {
                                 UIView *bookView = [_parentBookShelfView.dataSource bookShelfView:_parentBookShelfView bookViewAtIndex:index];
                                 CGRect bookViewFrame = [self bookViewRectAtBookViewPosition:position];
                                 [bookView setFrame:bookViewFrame];
                                 [self addSubview:bookView];
                                 bookView.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
                                 
                                 [tempBookViewArray addObject:bookView];
                             }
                         }];
                         [UIView animateWithDuration:animate ? 0.25 : 0.0
                                               delay:0.0
                                             options:UIViewAnimationCurveEaseOut | UIViewAnimationOptionLayoutSubviews
                                          animations:^{
                                              for (UIView *bookView in tempBookViewArray) {
                                                  bookView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                                              }
                                          }
                                          completion:^(BOOL finished) {
                                              for (UIView *bookView in tempBookViewArray) {
                                                  [bookView removeFromSuperview];
                                                  [self addReuseableBookView:bookView];
                                              }
                                              [tempBookViewArray removeAllObjects];
                                              
                                              for (UIView *bookView in _visibleBookViews) {
                                                  [bookView removeFromSuperview];
                                                  [self addReuseableBookView:bookView];
                                              }
                                              [_visibleBookViews removeAllObjects];
                                              _firstVisibleRow = -1;
                                              _lastVisibleRow = -1;
                                              [_parentBookShelfView setNeedsLayout];
                                          }];
                         
                     }];
}

#pragma mark - visible

- (NSArray *)visibleBookViews {
    return _visibleBookViews;
}

- (UIView *)bookViewAtIndex:(NSInteger)index {
    NSInteger indexOfVisible = [self converToIndexOfVisibleBookViewsFromIndex:index];
    if (indexOfVisible < 0 || indexOfVisible >= [_visibleBookViews count]) {
        return nil;
    }
    return [_visibleBookViews objectAtIndex:indexOfVisible];
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
