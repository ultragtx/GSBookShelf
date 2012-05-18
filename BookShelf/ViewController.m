/*
 ViewController.m
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

#import "ViewController.h"

#import "MyCellView.h"
#import "MyBookView.h"
#import "MyBelowBottomView.h"

#define CELL_HEIGHT 125

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)initBooks {
    NSInteger numberOfBooks = 100;
    _bookArray = [[NSMutableArray alloc] initWithCapacity:numberOfBooks];
    _bookStatus = [[NSMutableArray alloc] initWithCapacity:numberOfBooks];
    for (int i = 0; i < numberOfBooks; i++) {
        NSNumber *number = [NSNumber numberWithInt:i];
        [_bookArray addObject:number];
        [_bookStatus addObject:[NSNumber numberWithInt:BOOK_UNSELECTED]];
    }
    
    _booksIndexsToBeRemoved = [NSMutableIndexSet indexSet];
}

- (void)initBarButtons {
    _editBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonClicked:)];
    _cancleBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancleButtonClicked:)];
    
    _trashBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashButtonClicked:)];
    _addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonClicked:)];
}

- (void)switchToNormalMode {
    _editMode = NO;
    
    [self.navigationItem setLeftBarButtonItem:_editBarButton];
    [self.navigationItem setRightBarButtonItem:_addBarButton];
}

- (void)switchToEditMode {
    _editMode = YES;
    [_booksIndexsToBeRemoved removeAllIndexes];
    [self.navigationItem setLeftBarButtonItem:_cancleBarButton];
    [self.navigationItem setRightBarButtonItem:_trashBarButton];
    
    for (int i = 0; i < [_bookArray count]; i++) {
        [_bookStatus addObject:[NSNumber numberWithInt:BOOK_UNSELECTED]];
    }
    
    for (MyBookView *bookView in [_bookShelfView visibleBookViews]) {
        [bookView setSelected:NO];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initBarButtons];
    [self switchToNormalMode];
    
	[self initBooks];
    
    //AboveTopView *aboveTop = [[AboveTopView alloc] initWithFrame:CGRectMake(0, 0, 320, 164)];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _belowBottomView = [[MyBelowBottomView alloc] initWithFrame:CGRectMake(0, 0, 320, CELL_HEIGHT * 2)];
    
    //MyBelowBottomView *belowBottom = [[MyBelowBottomView alloc] initWithFrame:CGRectMake(0, 0, 320, CELL_HEIGHT * 2)];
    
    _bookShelfView = [[GSBookShelfView alloc] initWithFrame:CGRectMake(0, 0, 320, 460 - 44)];
    [_bookShelfView setDataSource:self];
    //[_bookShelfView setShelfViewDelegate:self];
    
    [self.view addSubview:_bookShelfView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        [_bookShelfView setFrame:CGRectMake(0, 0, 480, 320 - 44)];
    }
    else {
        [_bookShelfView setFrame:CGRectMake(0, 0, 320, 460 - 44)];
    }
    [_bookShelfView reloadData];
}

#pragma mark GSBookShelfViewDataSource

- (NSInteger)numberOfBooksInBookShelfView:(GSBookShelfView *)bookShelfView {
    return [_bookArray count];
}

- (NSInteger)numberOFBooksInCellOfBookShelfView:(GSBookShelfView *)bookShelfView {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        return 4;
    }
    else {
        return 3;
    }
}

- (UIView *)bookShelfView:(GSBookShelfView *)bookShelfView bookViewAtIndex:(NSInteger)index {
    static NSString *identifier = @"bookView";
    MyBookView *bookView = (MyBookView *)[bookShelfView dequeueReuseableBookViewWithIdentifier:identifier];
    if (bookView == nil) {
        bookView = [[MyBookView alloc] initWithFrame:CGRectZero];
        bookView.reuseIdentifier = identifier;
        [bookView addTarget:self action:@selector(bookViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [bookView setIndex:index];
    [bookView setSelected:[(NSNumber *)[_bookStatus objectAtIndex:index] intValue]];
    int imageNO = [(NSNumber *)[_bookArray objectAtIndex:index] intValue] % 4 + 1;
    [bookView setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png", imageNO]] forState:UIControlStateNormal];
    return bookView;
}

- (UIView *)bookShelfView:(GSBookShelfView *)bookShelfView cellForRow:(NSInteger)row {
    static NSString *identifier = @"cell";
    MyCellView *cellView = (MyCellView *)[bookShelfView dequeueReuseableCellViewWithIdentifier:identifier];
    if (cellView == nil) {
        cellView = [[MyCellView alloc] initWithFrame:CGRectZero];
        cellView.reuseIdentifier = identifier;
    }
    return cellView;
}

- (UIView *)aboveTopViewOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return nil;
}

- (UIView *)belowBottomViewOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return _belowBottomView;
}

- (UIView *)headerViewOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return _searchBar;
}

- (CGFloat)cellHeightOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 125.0f;
}

- (CGFloat)cellMarginOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 20.0f;
}

- (CGFloat)bookViewHeightOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 88.0f;
}

- (CGFloat)bookViewWidthOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 74.0f;
}

- (CGFloat)bookViewBottomOffsetOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 110.0f;
}

- (CGFloat)cellShadowHeightOfBookShelfView:(GSBookShelfView *)bookShelfView {
    return 0.0f;
}

- (void)bookShelfView:(GSBookShelfView *)bookShelfView moveBookFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if ([(NSNumber *)[_bookStatus objectAtIndex:fromIndex] intValue] == BOOK_SELECTED) {
        [_booksIndexsToBeRemoved removeIndex:fromIndex];
        [_booksIndexsToBeRemoved addIndex:toIndex];
    }
    
    [_bookArray moveObjectFromIndex:fromIndex toIndex:toIndex];
    [_bookStatus moveObjectFromIndex:fromIndex toIndex:toIndex];
    
    // the bookview is recognized by index in the demo, so change all the indexes of affected bookViews here
    // This is just a example, not a good one.In your code, you'd better use a key to recognize the bookView.
    // and you won't need to do the following
    MyBookView *bookView;
    bookView = (MyBookView *)[_bookShelfView bookViewAtIndex:toIndex];
    [bookView setIndex:toIndex];
    if (fromIndex <= toIndex) {
        for (int i = fromIndex; i < toIndex; i++) {
            bookView = (MyBookView *)[_bookShelfView bookViewAtIndex:i];
            [bookView setIndex:bookView.index - 1];
        }
    }
    else {
        for (int i = toIndex + 1; i <= fromIndex; i++) {
            bookView = (MyBookView *)[_bookShelfView bookViewAtIndex:i];
            [bookView setIndex:bookView.index + 1];
        }
    }
}

#pragma mark - BarButtonListener 

- (void)editButtonClicked:(id)sender {
    [self switchToEditMode];
}

- (void)cancleButtonClicked:(id)sender {
    [self switchToNormalMode];
}

- (void)trashButtonClicked:(id)sender {
    [_bookArray removeObjectsAtIndexes:_booksIndexsToBeRemoved];
    [_bookStatus removeObjectsAtIndexes:_booksIndexsToBeRemoved];
    [_bookShelfView removeBookViewsAtIndexs:_booksIndexsToBeRemoved animate:YES];
    [self switchToNormalMode];
}

- (void)addButtonClicked:(id)sender {
    int a[6] = {1, 2, 5, 7, 9, 22};
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableArray *stat = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        [indexSet addIndex:a[i]];
        [arr addObject:[NSNumber numberWithInt:1]];
        [stat addObject:[NSNumber numberWithInt:BOOK_UNSELECTED]];
    }
    [_bookArray insertObjects:arr atIndexes:indexSet];
    [_bookStatus insertObjects:stat atIndexes:indexSet];
    [_bookShelfView insertBookViewsAtIndexs:indexSet animate:YES];
}

#pragma mark - BookView Listener

- (void)bookViewClicked:(UIButton *)button {
    MyBookView *bookView = (MyBookView *)button;
    
    if (_editMode) {
        NSNumber *status = [NSNumber numberWithInt:bookView.selected];
        [_bookStatus replaceObjectAtIndex:bookView.index withObject:status];
        
        if (bookView.selected) {
            [_booksIndexsToBeRemoved addIndex:bookView.index];
        }
        else {
            [_booksIndexsToBeRemoved removeIndex:bookView.index];
        }
    }
    else {
        [bookView setSelected:NO];
    }
}

@end
