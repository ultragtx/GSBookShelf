/*
 AboveTopView.m
 BookShelf
 
 Created by Xinrong Guo on 12-3-11.
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

#import "AboveTopView.h"

#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

@implementation AboveTopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *woodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 139 * 2)];
        
        CGFloat scale = isRetina ? 2.0f : 1.0f;
        [woodImageView setImage:[UIImage imageWithCGImage:CGImageCreateWithImageInRect([[UIImage imageNamed:@"WoodTile-iPhone.png"] CGImage], CGRectMake(0, 0, 320 * scale, 139 * 2 * scale))]];
        [self addSubview:woodImageView];
        
        UIImageView *sideImageView_left1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 164)];
        [sideImageView_left1 setImage:[UIImage imageNamed:@"topshelf side shading-iPhone.png"]];
        
        UIImageView *sideImageView_left2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 139, 160, 139)];
        [sideImageView_left2 setImage:[UIImage imageNamed:@"SideShading-iPhone.png"]];
        
        [self addSubview:sideImageView_left1];
        //[self addSubview:sideImageView_left2];
        
        UIImageView *sideImageView_right1 = [[UIImageView alloc] initWithFrame:CGRectMake(160, 0, 160, 164)];
        [sideImageView_right1 setImage:[UIImage imageNamed:@"topshelf side shading-iPhone.png"]];
        [sideImageView_right1 setTransform:CGAffineTransformMakeScale(-1.0, 1.0)];
        
        UIImageView *sideImageView_right2 = [[UIImageView alloc] initWithFrame:CGRectMake(160, 139, 160, 139)];
        [sideImageView_right2 setImage:[UIImage imageNamed:@"SideShading-iPhone.png"]];
        [sideImageView_right2 setTransform:CGAffineTransformMakeScale(-1.0, 1.0)];
        
        [self addSubview:sideImageView_right1];
        //[self addSubview:sideImageView_right2];
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
