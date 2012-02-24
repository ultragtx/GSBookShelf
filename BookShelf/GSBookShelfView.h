//
//  BookShelfView.h
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-22.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GSBookViewContainerView;
@class GSCellContainerView;
@class GSBookView;
@class GSBookShelfCellView;

@protocol GSBookShelfViewDelegate;
@protocol GSBookShelfViewDataSource;

@interface GSBookShelfView : UIScrollView {
    id<GSBookShelfViewDelegate> __unsafe_unretained _shelfViewDelegate;
    id<GSBookShelfViewDataSource> __unsafe_unretained _dataSource;
    
    GSBookViewContainerView *_bookViewContainerView;
    GSCellContainerView *_cellContainerView;
}

@property (nonatomic, unsafe_unretained) id<GSBookShelfViewDelegate> shelfViewDelegate;
@property (nonatomic, unsafe_unretained) id<GSBookShelfViewDataSource> dataSource;



@end

@protocol GSBookShelfViewDataSource <NSObject>

- (CGFloat)heightOfCellInBookShelfView:(GSBookShelfView *)bookShelfView;
- (NSInteger)numberOfBooksInBookShelfView:(GSBookShelfView *)bookShelfView;

- (GSBookView *)bookShelfView:(GSBookShelfView *)bookShelfView bookViewAtIndex:(NSInteger)index;
- (GSBookShelfCellView *)bookShelfView:(GSBookShelfView *)bookShelfView cellForRow:(NSInteger)row;

@end

@protocol GSBookShelfViewDelegate <NSObject>



@end
