//
//  CircleFlowView.h
//  CircleFlowView
//
//  Created by Mahmood1 on 12/4/19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CircleFlowViewObserver.h"

#import "FileSelectionInter.h"

@interface CircleFlowView : UIView
{    
@private
    
    NSMutableArray *mPhotos;
    NSMutableArray *mPhotoBadgeIcons;
    NSMutableArray *mPhotoBadgeTexts;
    NSMutableArray *mPhotoNames;
    NSMutableArray *mBadgeNumbers;
    int mStartIndex;
    int mEndIndex;
    int mYDiff;
    int mControlWidth;
    int mControlHeight;
    float mCurrentDegree;
    float mScrollingSpeed;
    int mCurrentFocusedIdx;
    
    bool mDragging;
    bool mScrolling;
    bool mScrollingClockWise;
    float mScrollingTarget;
    
    CGPoint mLastDragedPoint;
    NSTimeInterval mLastDragedTime;
    
    NSString *mBackground;
    NSString *mBadgeIcon;
    float mBadgeFontSize;
	UIColor* mBadgeColor;
    
    float mMaxAlpha; // must larger than mMinAlpha and less than 1.0
    float mMinAlpha; // must larger than 0.0 and less than mMaxAlpha
    float mSplitAlpha; // must between mMinAlpha ~ mMinAlpha
    float mSplitAngle; // must between 1 ~ 179;
}

@property (nonatomic, readwrite, retain) id<CircleFlowViewObserver> mViewObserver;

@property (nonatomic) float ScrollSpeeed;
@property (nonatomic, retain) UIColor* badgeColor;

- (void)setMaxAlpha:(float) aMaxAlpha withMinAlpha:(float) aMinAlpha withSplitAlpha:(float) aSplitAlpha atSplitAngle:(float) aSplitAngle;

- (void)setBadgeNumber:(int)aNumber toControl:(int)aIndex;

- (int)getBadgeNumber:(int)aControlIndex;

- (void)setControlWidth:(int)aWidth withControlHeight:(int)aHeight withYDiff:(int)aYDiff withScrollSpeed:(float)mScrollingSpeed;

- (void)setFocusedIndex:(int)aIndex;

- (void)setBackgroundIcon:(NSString*)aBackground andBadgeIcon:(NSString*)aBadge andBadgeFontSize:(float)aBadgeFontSize;

- (void)loadPhotoFromResourceWithPrefix:(NSString*)aPrefix withStartIndex:(int)aStartIndex withEndIndex:(int)aEndIndex withImageType:(NSString*)aType;

- (void)loadPhotoFromStorageWithFolder:(NSString*)aFolder withPrefix:(NSString*)aPrefix withStartIndex:(int)aStartIndex withEndIndex:(int)aEndIndex withImageType:(NSString*)aType;

- (void)loadPhotoFromFileSelection:(id<FileSelectionInter>) mSelection;

@end
