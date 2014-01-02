//
//  CoverFlowView.h
//  FunctionBarDemo
//
//  Created by Mahmood1 on 12/4/3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "CoverFlowViewObserver.h"
#import "FileSelectionInter.h"


typedef short CoverBadgeGravity; enum
{
    COVER_BADGE_TOP_LEFT,
    COVER_BADGE_TOP_RIGHT
};


@interface CoverFlowView : UIView
{
@private
    NSMutableArray *mPhotos;
    NSMutableArray *mPhotoNames;
    int mStartIndex;
    int mEndIndex;

    CGPoint mOriginTouchedPoint;
    CGPoint mLastDragedPoint;
    bool mIsDragging;
    int mLastDragedDirection;
    
    int mPaddingTop;
    int mPaddingBottom;
    int mControlDistance;
    int mControlWidth;
    int mControlHeight;
    int m360Distance;
    int mScaledWidth;
    int mScaledHeight;
    float mScrollSpeed;

    NSString *mBackground;
    
    NSMutableArray *mPhotoBadgeIcons;
    NSMutableArray *mPhotoBadgeTexts;
    NSMutableArray *mBadgeNumbers;
    
    NSString *mBadgeIcon;
    float mBadgeFontSize;
	UIColor* mBadgeColor;
    CoverBadgeGravity mBadbeGravity;
}

@property (nonatomic, readwrite, retain) id<CoverFlowViewObserver> mViewObserver;

@property (nonatomic, retain) UIColor* badgeColor;
@property (nonatomic) CoverBadgeGravity badbeGravity;

- (void)setSelectedIndex:(int)aIndex;

- (void)setPaddingTop:(int) aTop withBottom:(int) aBottom withControlDistance:(int) aDistance withControlWidth:(int) aWidth withControlHeight:(int) aHeight withScrollSpeed:(float) aScrollSpeed with360Distance:(int) a360Distance withScaledWidth:(int) aScaledWidth withScaledHeight:(int) aScaledHeight;

- (void)setBackgroundIcon:(NSString*)aBackground;

- (void)setBadgeIcon:(NSString*)aBadge andBadgeFontSize:(float)aBadgeFontSize;

- (void)setBadgeNumber:(int)aNumber toControl:(int)aIndex;

- (int)getBadgeNumber:(int)aControlIndex;

- (void)loadPhotoFromResourceWithPrefix:(NSString*)aPrefix withStartIndex:(int)aStartIndex withEndIndex:(int)aEndIndex withImageType:(NSString*)aType;

- (void)loadPhotoFromStorageWithFolder:(NSString*)aFolder withPrefix:(NSString*)aPrefix withStartIndex:(int)aStartIndex withEndIndex:(int)aEndIndex withImageType:(NSString*)aType;

- (void)loadPhotoFromFileSelection:(id<FileSelectionInter>) mSelection;

@end
