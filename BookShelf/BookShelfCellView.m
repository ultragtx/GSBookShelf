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

static UIImage *shadingImage = nil;
static UIImage *woodImage = nil;
static UIImage *shelfImageProtrait = nil;
static UIImage *shelfImageLandscape = nil;

+ (UIImage *)shadingImage {
    if (shadingImage == nil) {
        CGFloat scale = isRetina ? 2.0f : 1.0f;
        
        UIGraphicsBeginImageContext(CGSizeMake(320 * scale, 139 * scale));
        UIImage *shadingImageToDraw = [UIImage imageNamed:@"Side Shading-iPhone.png"];
        [shadingImageToDraw drawInRect:CGRectMake(0, 0, shadingImageToDraw.size.width * scale, shadingImageToDraw.size.height * scale)];
        
        CGAffineTransform ctm1 = CGAffineTransformMakeScale(-1.0f, 1.0f);
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), ctm1);
        [shadingImageToDraw drawInRect:CGRectMake(-320 * scale, 0, shadingImageToDraw.size.width * scale, shadingImageToDraw.size.height * scale)];
        shadingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        shadingImage = [UIImage imageWithCGImage:shadingImage.CGImage scale:scale orientation:UIImageOrientationUp];
    }
    return shadingImage;
}

+ (UIImage *)woodImage {
    if (woodImage == nil) {
        CGFloat scale = isRetina ? 2.0f : 1.0f;
        
        UIGraphicsBeginImageContext(CGSizeMake(480 * scale, 139 * scale));
        UIImage *woodImageToDraw = [UIImage imageNamed:@"WoodTile.png"];
        [woodImageToDraw drawInRect:CGRectMake(0, 0, woodImageToDraw.size.width * scale, woodImageToDraw.size.width * scale)];
        woodImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        woodImage = [UIImage imageWithCGImage:woodImage.CGImage scale:scale orientation:UIImageOrientationUp];
    }
    return woodImage;
}

+ (UIImage *)shelfImageProtrait {
    if (shelfImageProtrait == nil) {
        shelfImageProtrait = [UIImage imageNamed:@"Shelf.png"];
    }
    return shelfImageProtrait;
}

+ (UIImage *)shelfImageLandscape {
    if (shelfImageLandscape == nil) {
        shelfImageLandscape = [UIImage imageNamed:@"Shelf-Landscape.png"];
    }
    return shelfImageLandscape;
}



- (UIImage *)partOfImage:(UIImage *)image rect:(CGRect)rect {
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.width));
    [image drawInRect:rect];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}



- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        //[self.layer setBorderWidth:2];
        //[self.layer setBorderColor:[[UIColor greenColor] CGColor]];
        
        /*// wood
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
         [self addSubview:_shelfImageView];*/
        
        _shelfImageView = [[UIImageView alloc] initWithImage:[BookShelfCellView shelfImageProtrait]];
        
        _shelfImageViewLandscape = [[UIImageView alloc] initWithImage:[BookShelfCellView shelfImageLandscape]];
        
        _woodImageView = [[UIImageView alloc] initWithImage:[BookShelfCellView woodImage]];
        
        _shadingImageView = [[UIImageView alloc] initWithImage:[BookShelfCellView shadingImage]];
        //[_shadingImageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        
        [self addSubview:_woodImageView];
        [self addSubview:_shadingImageView];
        [self addSubview:_shelfImageView];
        [self addSubview:_shelfImageViewLandscape];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_shadingImageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    if (self.frame.size.width <= 320) {
        [_shelfImageView setHidden:NO];
        [_shelfImageViewLandscape setHidden:YES];
    }
    else {
        [_shelfImageView setHidden:YES];
        [_shelfImageViewLandscape setHidden:NO];
    }
    [_shelfImageView setFrame:CGRectMake(0, 130 - 23, self.frame.size.width, _shelfImageView.frame.size.height)];
    [_shelfImageViewLandscape setFrame:CGRectMake(0, 130 - 23, self.frame.size.width, _shelfImageViewLandscape.frame.size.height)];

}

@end
