//
//  ViewController.m
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-22.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import "ViewController.h"
#import "BookView.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)initBooks {
    NSInteger numberOfBooks = 200;
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
}

- (void)switchToNormalMode {
    _editMode = NO;
    
    [self.navigationItem setLeftBarButtonItem:_editBarButton];
}

- (void)switchToEditMode {
    _editMode = YES;
    [_booksIndexsToBeRemoved removeAllIndexes];
    [self.navigationItem setLeftBarButtonItem:_cancleBarButton];
    [self.navigationItem setRightBarButtonItem:_trashBarButton];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initBarButtons];
    [self switchToNormalMode];
    
	[self initBooks];
    
    _bookShelfView = [[GSBookShelfView alloc] initWithFrame:CGRectMake(0, 0, 320, 460 - 44) cellHeight:120 cellMarginWidth:20 bookViewBottomOffset:110 numberOfBooksInCell:3];
    [_bookShelfView setDataSource:self];
    [_bookShelfView setShelfViewDelegate:self];
    
    [self.view addSubview:_bookShelfView];
    
}


#pragma mark GSBookShelfViewDataSource

- (NSInteger)numberOfBooksInBookShelfView:(GSBookShelfView *)bookShelfView {
    return [_bookArray count];
}

- (BookView *)bookShelfView:(GSBookShelfView *)bookShelfView bookViewAtIndex:(NSInteger)index {
    static NSString *identifier = @"bookView";
    BookView *bookView = (BookView *)[bookShelfView dequeueReuseableBookViewWithIdentifier:identifier];
    if (bookView == nil) {
        bookView = [[BookView alloc] initWithFrame:CGRectZero];
        bookView.reuseIdentifier = identifier;
        [bookView.button addTarget:self action:@selector(bookViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [bookView setIndex:index];
    [bookView setSelected:[(NSNumber *)[_bookStatus objectAtIndex:index] intValue]];
    int imageNO = [(NSNumber *)[_bookArray objectAtIndex:index] intValue] % 9;
    [bookView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.tiff", imageNO]]];
    return bookView;
}

- (UIView *)bookShelfView:(GSBookShelfView *)bookShelfView cellForRow:(NSInteger)row {
    return nil;
}

- (void)bookShelfView:(GSBookShelfView *)bookShelfView moveBookFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    [_bookArray moveObjectFromIndex:fromIndex toIndex:toIndex];
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
    [_bookShelfView removeBookViewAtIndexs:_booksIndexsToBeRemoved animate:YES];
}

#pragma mark - BookView Listener

- (void)bookViewClicked:(UIButton *)button {
    BookView *bookView = (BookView *)button.superview;
    NSNumber *status = [NSNumber numberWithInt:bookView.selected];
    [_bookStatus replaceObjectAtIndex:bookView.index withObject:status];
    
    if (bookView.selected) {
        [_booksIndexsToBeRemoved addIndex:bookView.index];
    }
    else {
        [_booksIndexsToBeRemoved removeIndex:bookView.index];
    }
}

@end
