/*
 GSBookShelfCellView.m
 BookShelf
 
 Created by Xinrong Guo on 12-2-23.
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

#import "BookShelfCellView.h"
#import <QuartzCore/QuartzCore.h>

#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

@implementation BookShelfCellView

@synthesize reuseIdentifier;

- (UIImage *)partOfImage:(UIImage *)image rect:(CGRect)rect {
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.width));
    [image drawInRect:rect];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (id)initWithFrame:(CGRect)frame woodPart:(WoodPart)part
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        //[self.layer setBorderWidth:2];
        //[self.layer setBorderColor:[[UIColor greenColor] CGColor]];
        
        // wood
        _woodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 139)];
        
        CGFloat scale = isRetina ? 2.0f : 1.0f;
        [_woodImageView setImage:[UIImage imageWithCGImage:CGImageCreateWithImageInRect([[UIImage imageNamed:@"WoodTile-iPhone.png"] CGImage], CGRectMake(0, 139 * scale * part, 320 * scale, 139 * scale))]];
        [self addSubview:_woodImageView];
        
        _sideImageView_left = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 139)];
        [_sideImageView_left setImage:[UIImage imageNamed:@"SideShading-iPhone.png"]];
        
        [self addSubview:_sideImageView_left];
        
        _sideImageView_right = [[UIImageView alloc] initWithFrame:CGRectMake(160, 0, 160, 139)];
        [_sideImageView_right setImage:[UIImage imageNamed:@"SideShading-iPhone.png"]];
        [_sideImageView_right setTransform:CGAffineTransformMakeScale(-1.0, 1.0)];
        [self addSubview:_sideImageView_right];
        //[_sideImageView_right.layer setBorderWidth:1];
        //[_sideImageView_right.layer setBorderColor:[[UIColor redColor] CGColor]];
        
        
        _shelfImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 130 - 23, 320, 87)];
        [_shelfImageView setImage:[UIImage imageNamed:@"Shelf-iPhone.png"]];
        [self addSubview:_shelfImageView];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
