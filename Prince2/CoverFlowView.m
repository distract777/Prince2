//
//  CoverFlowView.m
//  FunctionBarDemo
//
//  Created by Mahmood1 on 12/4/3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CoverFlowView.h"
#import <QuartzCore/QuartzCore.h>

#include <sys/time.h>

@implementation CoverFlowView

@synthesize mViewObserver;

@synthesize badgeColor = mBadgeColor;
@synthesize badbeGravity = mBadbeGravity;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mViewObserver = nil;
        mPhotos = [[NSMutableArray alloc] initWithCapacity:5];
        mPhotoNames = [[NSMutableArray alloc] initWithCapacity:5];
        mStartIndex = -1;
        mEndIndex = -1;
        mOriginTouchedPoint.x = 0;
        mOriginTouchedPoint.y = 0;
        mLastDragedPoint.x = 0;
        mLastDragedPoint.y = 0;
        mIsDragging = false;
        mLastDragedDirection = 0;
        mPaddingTop = 0;
        mPaddingBottom = 0;
        mControlDistance = 0;
        mControlWidth = 100;
        mControlHeight = 100;
        mScrollSpeed = 1.0f;
        m360Distance = 0;
        mScaledWidth = 0;
        mScaledHeight = 0;
        mBackground = nil;
        
        mPhotoBadgeIcons = [[NSMutableArray alloc] initWithCapacity:5];
        mPhotoBadgeTexts = [[NSMutableArray alloc] initWithCapacity:5];
        mBadgeNumbers = [[NSMutableArray alloc] initWithCapacity:5];
        mBadgeIcon = nil;
        mBadgeFontSize = 16;
        mBadbeGravity = COVER_BADGE_TOP_LEFT;
		mBadgeColor = [UIColor whiteColor] ;
        
        [self setClipsToBounds:TRUE];
    }
    return self;
}

- (void)reset
{
    [mBadgeNumbers removeAllObjects];
    
    while( [mPhotoBadgeIcons count] > 0 )
    {
        UIImageView* icon = [mPhotoBadgeIcons objectAtIndex:0];
        
        [mPhotoBadgeIcons removeObjectAtIndex:0];
        
      //  [icon release];
    }
    
    while( [mPhotoBadgeTexts count] > 0 )
    {
        [mPhotoBadgeTexts removeObjectAtIndex:0];
    }
    
    while( [mPhotos count] > 0 )
    {
        CALayer* photo = [mPhotos objectAtIndex:0];
        
        [mPhotos removeObjectAtIndex:0];
        
       // [photo release];
    }
    
    while( [mPhotoNames count] > 0 )
    {
        [mPhotoNames removeObjectAtIndex:0];
    }
    
    mStartIndex = -1;
    mEndIndex = -1;
}

- (bool)reachLeftMost
{
    /*
     * Return true if no more room for left slide.
     */
    
    if( [[self.layer sublayers] count] <= 0 ) return TRUE;
    
    CALayer *right_most = [[self.layer sublayers] objectAtIndex:[[self.layer sublayers] count]-1];
    
    return right_most.position.x < ( self.frame.size.width /*- mControlWidth*/ ) / 2;
}

- (bool)reachRightMost
{
    /*
     * Return true if no more room for left slide.
     */
    
    if( [[self.layer sublayers] count] <= 0 ) return TRUE;
    
    CALayer *left_most = [[self.layer sublayers] objectAtIndex:0];
    
    return left_most.position.x > ( self.frame.size.width ) / 2;
}

- (void)adjust360Transformations
{
    float most_point = ( self.frame.size.width ) / 2;
    
    CALayer *sub = nil;
    
    for( sub in [self.layer sublayers] )
    {
        float rdiff = 0.0f;
        
        if( m360Distance > 0 )
        {
            int xdiff = sub.position.x - most_point;
            
            rdiff = - ( int ) ( ( ( float ) xdiff / ( float ) m360Distance ) * 360.0f ) % 360;
        }
        
        CATransform3D t = CATransform3DIdentity;
        
        t.m34 = 1.0 / -500;
        
        t = CATransform3DRotate(t, rdiff * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
        
        [sub setTransform:t];
    }
}

- (void)slideBar:(int) aXDiff
{
    /*
     * Slide the position of each subView with specific diff.
     */
    
    if( [self reachLeftMost] && aXDiff > 0 ) return;
    
    if( [self reachRightMost] && aXDiff < 0 ) return;
    
    int most_point = ( self.frame.size.width ) / 2;
    
    if( aXDiff > 0 )
    {
        CALayer *left_most = [[self.layer sublayers] objectAtIndex:0];
        
        float adjusted = left_most.position.x + aXDiff;
        
        if( adjusted > most_point )
        {
            aXDiff -= adjusted - ( most_point );
        }
    }
    else if( aXDiff < 0 )
    {
        CALayer *right_most = [[self.layer sublayers] objectAtIndex:([[self.layer sublayers] count]-1)];
        
        float adjusted = right_most.position.x + aXDiff;
        
        if( adjusted < most_point )
        {
            aXDiff += most_point - adjusted;
        }
    }
    else
    {
        return;
    }
    
    CALayer *sub = nil;
    
    for( sub in [self.layer sublayers] )
    {
        CGPoint currentPos = [sub position];
        sub.position = CGPointMake(currentPos.x + aXDiff, currentPos.y);
        
        
        // adjust badge count position
        if (mBadbeGravity == COVER_BADGE_TOP_RIGHT)
        {
            CALayer *sub2 = nil;
            
            for( sub2 in [sub sublayers] )
            {
                CGPoint currentPos2 = [sub2 position];
                sub2.position = CGPointMake(sub.bounds.size.width - sub2.bounds.size.width - 5, currentPos2.y);
            }
        }
    }
    
    [self adjust360Transformations];
}

- (void)slideToLayerByAnimation:(CALayer*)aLayer
{
    int mid_point = [self frame].size.width / 2;
    int diff = mid_point - [aLayer position].x;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelay:0];
    
    CALayer *sub = nil;
    
    for( sub in [self.layer sublayers] )
    {
        CGPoint currentPos = [sub position];
        sub.position = CGPointMake(currentPos.x + diff, currentPos.y);
        
        
        // adjust badge count position
        if (mBadbeGravity == COVER_BADGE_TOP_RIGHT)
        {
            CALayer *sub2 = nil;
            
            for( sub2 in [sub sublayers] )
            {
                CGPoint currentPos2 = [sub2 position];
                sub2.position = CGPointMake(mScaledWidth - sub2.bounds.size.width - 5, currentPos2.y);
            }
        }
    }
    
    CGRect layer_bound = [aLayer bounds];
    
    aLayer.bounds = CGRectMake(layer_bound.origin.x, layer_bound.origin.y, mScaledWidth, mScaledHeight);
    
    [self adjust360Transformations];    
    
    [UIView commitAnimations];
}

- (void)scaleAllLayerToOriginalSize
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelay:0];
    
    CALayer *sub = nil;

    for( sub in [self.layer sublayers] )
    {
        CGRect layer_bound = [sub bounds];
        sub.bounds = CGRectMake(layer_bound.origin.x, layer_bound.origin.y, mControlWidth, mControlHeight);
        
        
        // adjust badge count position
        if (mBadbeGravity == COVER_BADGE_TOP_RIGHT)
        {
            CALayer *sub2 = nil;
            
            for( sub2 in [sub sublayers] )
            {
                CGRect layer_bound2 = [sub2 bounds];
                sub2.frame = CGRectMake(sub.frame.size.width - layer_bound2.size.width - 5, layer_bound2.origin.y, layer_bound2.size.width, layer_bound2.size.height);
            }
        }
    }
    
    [self adjust360Transformations];    
    
    [UIView commitAnimations];
}

- (void)adjustPositionsOfSubControls
{
    /*
     * Method to reposition all items if any property of the bar been changed.
     */
    
    @autoreleasepool
    {
        float frame_height = self.frame.size.height;
        float frame_width = self.frame.size.width;
        
        float max_item_height = mControlHeight;
        float max_item_width = mControlWidth;
        float min_item_distance = mControlDistance;
        
        int total_item_width = [[self.layer sublayers] count] * (max_item_width + min_item_distance) - min_item_distance;
        
        int start_origin_x = ( frame_width - total_item_width ) / 2 + ( max_item_width / 2 );
        
        if( [[self.layer sublayers] count] % 2 == 0 && [[self.layer sublayers] count] > 0 )
        {
            start_origin_x -= max_item_width + min_item_distance;
        }
        
        if( max_item_height < 1 )  max_item_height = frame_height > 0 ? 1 : 0;
        
        float idx = 0;
        CALayer *sub = nil;
        
        for( sub in [self.layer sublayers] )
        {
            float item_width = max_item_width;
            
            float item_height = max_item_height;
            
            float item_x = start_origin_x + ( idx * ( max_item_width + min_item_distance ) ) +
            ( item_width == max_item_width ? 0 : ( max_item_width - item_width ) / 2 );
            
            float item_y = (frame_height - max_item_height) / 2;        
            
            [sub setFrame:CGRectMake(item_x, item_y, item_width, item_height)];
            
            
            // adjust badge count position
            if (mBadbeGravity == COVER_BADGE_TOP_RIGHT)
            {
                CALayer *sub2 = nil;
                
                for( sub2 in [sub sublayers] )
                {
                    CGRect layer_bound2 = [sub2 bounds];
                    sub2.frame = CGRectMake(sub.frame.size.width - layer_bound2.size.width - 5, layer_bound2.origin.y, layer_bound2.size.width, layer_bound2.size.height);
                }
            }
            
            idx++;
        }
        

        for( int idx = 0; idx < mPhotoBadgeIcons.count; idx++ )
        {
            CALayer *badgeIcon = [mPhotoBadgeIcons objectAtIndex:idx];
            UILabel *badgeText = [mPhotoBadgeTexts objectAtIndex:idx];
            int badgeNumber = [self getBadgeNumber:idx];
            
            if( mBadgeIcon == nil || badgeNumber <= 0 )
            {
                if( badgeIcon != nil )
                {
                    badgeIcon.hidden = YES;
                }
                
                if( badgeText != nil )
                {
                    badgeText.hidden = YES;
                }
            }
            else
            {
                if( badgeIcon != nil )
                {
                    badgeIcon.hidden = NO;
                }
                
                if( badgeText != nil )
                {
                    badgeText.hidden = NO;
                    badgeText.text = [NSString stringWithFormat:@"%d", badgeNumber];
                }
            }
        }
    }
}

-(void) addBadgeView: (CALayer*) container
{
    @autoreleasepool
    {
        if (mBadgeIcon != nil)
        {
            UIImage* icon = [UIImage imageNamed: mBadgeIcon];
        
            CALayer* badge_layer = [CALayer layer];
            badge_layer.frame = CGRectZero;
            badge_layer.contents = (id)icon.CGImage;
     
            CGSize icon_size = icon.size;
            int icon_w = icon_size.width;
            int icon_h = icon_size.height;
            int icon_x, icon_y;
            int text_x, text_y;
            
            switch (mBadbeGravity)
            {
                case COVER_BADGE_TOP_LEFT:
                {
                    icon_x = 5;
                    icon_y = -10;
                    
                    text_x = 5;
                    text_y = 10;
                }
                    break;
                    
                case COVER_BADGE_TOP_RIGHT:
                default:
                {
                    icon_x = mControlWidth - icon_w - 5;
                    icon_y = -10;
                    
                    text_x = mControlWidth - icon_w - 5;
                    text_y = 10;
                }
                    break;
            }

            badge_layer.opaque = NO;
            badge_layer.frame = CGRectMake(icon_x, icon_y, icon_w, icon_h);
            [container addSublayer: badge_layer];

            UILabel* badge_text = [UILabel new];
            badge_text.frame = CGRectMake(text_x, text_y, icon_w, icon_y);
            badge_text.backgroundColor = [UIColor clearColor];
            badge_text.textColor = mBadgeColor;
            badge_text.font = [UIFont boldSystemFontOfSize: mBadgeFontSize];;
            badge_text.text = [NSString stringWithFormat:@"%d",0];
            badge_text.textAlignment = NSTextAlignmentCenter;
            [container addSublayer: badge_text.layer];
            
            /*
            CATextLayer* badge_text = [CATextLayer layer];
            badge_text.fontSize = mBadgeFontSize;
            badge_text.frame = CGRectMake(text_x, text_y, icon_w, icon_y);
            badge_text.string = [NSString stringWithFormat:@"%d",0];
            badge_text.alignmentMode = @"center";
            badge_text.foregroundColor = mBadgeColor.CGColor;
            badge_text.backgroundColor = [UIColor clearColor].CGColor;
            badge_text.zPosition = 1;
            [container addSublayer: badge_text];
            */
         
            [mPhotoBadgeIcons addObject: badge_layer];
            [mPhotoBadgeTexts addObject: badge_text];
            
           // [badge_text release];
        }
        
        NSNumber *badge = [NSNumber numberWithInt:0];
        [mBadgeNumbers addObject: badge];
    }
}

- (void)setFrame:(CGRect)aFrame
{
    [super setFrame:aFrame];
    
    /*
     * After the frame changed, all items should be repositioned.
     */
    
    [self adjustPositionsOfSubControls];
}

- (void)setSelectedIndex:(int)aIndex
{
    if( aIndex < 0 || aIndex >= mPhotos.count ) return;
    
    CALayer *selected = (CALayer*) [mPhotos objectAtIndex:aIndex];
    
    [self scaleAllLayerToOriginalSize];
    [self slideToLayerByAnimation:selected];
}

- (void)setPaddingTop:(int) aTop withBottom:(int) aBottom withControlDistance:(int) aDistance withControlWidth:(int) aWidth withControlHeight:(int) aHeight withScrollSpeed:(float) aScrollSpeed with360Distance:(int)a360Distance withScaledWidth:(int)aScaledWidth withScaledHeight:(int)aScaledHeight
{
    mPaddingTop = aTop < 0 ? 0 : aTop;
    mPaddingBottom = aBottom < 0 ? 0 : aBottom;
    mControlDistance = aDistance < 0 ? 0 : aDistance;
    mControlWidth = aWidth < 0 ? 100 : aWidth;
    mControlHeight = aHeight < 0 ? 100 : aHeight;
    mScaledWidth = aScaledWidth < 0 ? mControlWidth : aScaledWidth;
    mScaledHeight = aScaledHeight < 0 ? mControlHeight : aScaledHeight;
    m360Distance = a360Distance;
    mScrollSpeed = aScrollSpeed <= 0.0f ? 0.1f : aScrollSpeed;
    
    /*
     * After paddings changed, all items should be repositioned.
     */
    
    [self adjustPositionsOfSubControls];
    
    [self adjust360Transformations];
    
    int mid_point = [self frame].size.width / 2;
    
    CALayer* sub = nil;
    
    for( int idx = 0; idx < [[self.layer sublayers] count]; idx++ )
    {
        sub = [[self.layer sublayers]objectAtIndex:idx];
        
        CGPoint currentPos = [sub position];
        
        if( currentPos.x > mid_point )
        {
            [self scaleAllLayerToOriginalSize];
            [self slideToLayerByAnimation:sub];
            
            break;
        }
    }
}

- (void)setBackgroundIcon:(NSString*)aBackground
{
    /*
     * Set background
     */
    
    if( aBackground != nil )
    {
        mBackground = [NSString stringWithString:aBackground];
    }
    else if( mBackground != nil )
    {
       // [mBackground release];
        
        mBackground = nil;
    }
    
    [self adjustPositionsOfSubControls];    
}

- (void)setBadgeIcon:(NSString*)aBadge andBadgeFontSize:(float)aBadgeFontSize
{
    if (mBadgeIcon != nil)
    {
      //  [mBadgeIcon release];
        mBadgeIcon = nil;
    }
    
    if (aBadge != nil)
    {
        mBadgeIcon = [[NSString alloc] initWithString: aBadge];
        mBadgeFontSize = aBadgeFontSize;
    }
    
    [self adjustPositionsOfSubControls];
}

- (void)setBadgeNumber:(int)aNumber toControl:(int)aIndex
{
    [mBadgeNumbers removeObjectAtIndex:aIndex];
    
    NSNumber *badge = [NSNumber numberWithInt:aNumber];
    
    [mBadgeNumbers insertObject:badge atIndex:aIndex];
    
    [self adjustPositionsOfSubControls];
}

- (int)getBadgeNumber:(int)aControlIndex
{
    if( aControlIndex < 0 || aControlIndex >= mBadgeNumbers.count )
    {
        return -1;
    }
    
    NSNumber *number = ( NSNumber* ) [mBadgeNumbers objectAtIndex:aControlIndex];
    
    return [number intValue];
}

- (void)loadPhotoFromResourceWithPrefix:(NSString*)aPrefix withStartIndex:(int)aStartIndex withEndIndex:(int)aEndIndex withImageType:(NSString*)aType  
{
    [self reset];
    
    for( int idx = aStartIndex; idx <= aEndIndex; idx++ )
    {
        NSString* image_name = nil;
        
        image_name = aPrefix;
        image_name = [image_name stringByAppendingString:[NSString stringWithFormat:@"%d.",idx]];
        image_name = [image_name stringByAppendingString:aType];
        
        UIImage* icon = [UIImage imageNamed:image_name];
        
        CALayer *obj_layer = [CALayer layer];
        obj_layer.frame = CGRectZero;
        obj_layer.contents = (id)icon.CGImage;
        
        [self.layer addSublayer:obj_layer];
        [self addBadgeView: obj_layer];
        
        [mPhotos addObject:obj_layer];
        [mPhotoNames addObject:image_name];
    }
    
    mStartIndex = 0;
    mEndIndex = aEndIndex - aStartIndex;
    
    [self adjustPositionsOfSubControls];
    
    if( m360Distance > 0 )
    {
        [self adjust360Transformations];
    }    
}

- (void)loadPhotoFromStorageWithFolder:(NSString*)aFolder withPrefix:(NSString*)aPrefix withStartIndex:(int)aStartIndex withEndIndex:(int)aEndIndex withImageType:(NSString*)aType
{
    [self reset];
    
    for( int idx = aStartIndex; idx <= aEndIndex; idx++ )
    {
        NSString* image_name = nil;
        
        image_name = aFolder;
        
        if( ![image_name hasSuffix:@"/"] )
        {
            image_name = [image_name stringByAppendingString:@"/"];
        }
        
        image_name = [image_name stringByAppendingString:aPrefix];
        image_name = [image_name stringByAppendingString:[NSString stringWithFormat:@"%d.",idx]];
        image_name = [image_name stringByAppendingString:aType];
        
        UIImage* icon = [UIImage imageWithContentsOfFile:image_name];
        
        CALayer *obj_layer = [CALayer layer];
        obj_layer.frame = CGRectZero;
        obj_layer.contents = (id)icon.CGImage;
        
        [self.layer addSublayer:obj_layer];
        [self addBadgeView: obj_layer];
        
        [mPhotos addObject:obj_layer];
        [mPhotoNames addObject:image_name];
    }
    
    mStartIndex = 0;
    mEndIndex = aEndIndex - aStartIndex;
    
    [self adjustPositionsOfSubControls];
    
    if( m360Distance > 0 )
    {
        [self adjust360Transformations];
    }
}

- (void)loadPhotoFromFileSelection:(id<FileSelectionInter>) mSelection
{
    [self reset];
    
    for( int idx = 0; idx < [mSelection getCount]; idx++ )
    {
        NSString* image_name = [mSelection getFilePath:idx];
        
        UIImage* icon = nil;
        
        if( [mSelection isInternalResource] )
        {
            icon = [UIImage imageNamed:image_name];
        }
        else
        {
            icon = [UIImage imageWithContentsOfFile:image_name];
        }
        
        CALayer *obj_layer = [CALayer layer];
        obj_layer.frame = CGRectZero;
        obj_layer.contents = (id)icon.CGImage;
        
        [self.layer addSublayer:obj_layer];
        [self addBadgeView: obj_layer];
        
        [mPhotos addObject:obj_layer];
        [mPhotoNames addObject:image_name];
    }
    
    mStartIndex = 0;
    mEndIndex = [mSelection getCount]-1;  
    
    [self adjustPositionsOfSubControls];
    
    if( m360Distance > 0 )
    {
        [self adjust360Transformations];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*
     * To here, the touch event was began by the touch on CoverFlowView.
     */
    
    mOriginTouchedPoint = [[touches anyObject] locationInView:self];
    mLastDragedPoint = [[touches anyObject] locationInView:self];
    
    mIsDragging = false;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( mLastDragedPoint.x == 0 && mLastDragedPoint.y == 0 )
    {
        /*
         * To here, the touch event should pass through by other view.
         * Just ignore it and return.
         */
        
        return;
    }
    
    /*
     * Handle the slide if the diff over than 15 pixels.
     */
    
    if( !mIsDragging )
    {
        CGPoint currentTouchedPoint = [[touches anyObject] locationInView:self];
        
        int diff = currentTouchedPoint.x - mOriginTouchedPoint.x;
        
        if( abs( diff ) > 15 )
        {
            [self scaleAllLayerToOriginalSize];
            
            mIsDragging = true;
            
            mLastDragedPoint = currentTouchedPoint;
        }
    }
    else
    {
        CGPoint currentTouchedPoint = [[touches anyObject] locationInView:self];
    
        int diff = currentTouchedPoint.x - mLastDragedPoint.x;
    
        mLastDragedDirection = diff;
    
        diff = ( int ) ( ( ( float ) diff ) / mScrollSpeed );
    
        [self slideBar:diff];
    
        mLastDragedPoint = currentTouchedPoint;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( ( !mIsDragging && mOriginTouchedPoint.x == 0 && mOriginTouchedPoint.y == 0 ) ||
        ( mIsDragging && mLastDragedPoint.x == 0 && mLastDragedPoint.y == 0 ) )
    {
        /*
         * To here, the touch event should pass through by other view.
         * Just ignore it and return.
         */
        
        return;
    }
    
    if( !mIsDragging )
    {
        CALayer *sub = nil;
        
        for( int idx = [[self.layer sublayers] count] - 1; idx >= 0; idx-- )
        {
            sub = [[self.layer sublayers]objectAtIndex:idx];

            CGPoint currentPos = [sub position];
            CGRect currentBounds = [sub frame];
            
            currentPos.x -= currentBounds.size.width / 2;
            currentPos.y -= currentBounds.size.height / 2;
            
            if( mOriginTouchedPoint.x >= currentPos.x &&
                mOriginTouchedPoint.y >= currentPos.y &&
                mOriginTouchedPoint.x < currentPos.x + currentBounds.size.width &&
                mOriginTouchedPoint.y < currentPos.y + currentBounds.size.height )
            {
                if( mViewObserver != nil )
                {
                    [mViewObserver onCoverImageShifted:idx+mStartIndex withImagePath:[mPhotoNames objectAtIndex:idx]];
                    [mViewObserver onCoverImageSelected:idx+mStartIndex withImagePath:[mPhotoNames objectAtIndex:idx]];
                }
                
                [self scaleAllLayerToOriginalSize];
                [self slideToLayerByAnimation:sub];
                
                break;
            }
        }
    }
    else
    {
        int mid_point = [self frame].size.width / 2;
    
        if( mLastDragedDirection > 0 )
        {
            CALayer *sub = nil;
        
            for( int idx = [[self.layer sublayers] count] - 1; idx >= 0; idx-- )
            {
                sub = [[self.layer sublayers]objectAtIndex:idx];
            
                CGPoint currentPos = [sub position];
            
                if( currentPos.x <= mid_point )
                {
                    if( mViewObserver != nil )
                    {
                        [mViewObserver onCoverImageShifted:idx+mStartIndex withImagePath:[mPhotoNames objectAtIndex:idx]];
                    }
                
                    [self scaleAllLayerToOriginalSize];
                    [self slideToLayerByAnimation:sub];
                
                    break;
                }
            }
        }
        else if( mLastDragedDirection < 0 )
        {
            CALayer *sub = nil;
        
            for( int idx = 0; idx < [[self.layer sublayers] count]; idx++ )
            {
                sub = [[self.layer sublayers]objectAtIndex:idx];
            
                CGPoint currentPos = [sub position];
            
                if( currentPos.x >= mid_point )
                {
                    if( mViewObserver != nil )
                    {
                        [mViewObserver onCoverImageShifted:idx+mStartIndex withImagePath:[mPhotoNames objectAtIndex:idx]];
                    }
                
                    [self scaleAllLayerToOriginalSize];
                    [self slideToLayerByAnimation:sub];
                
                    break;
                }
            }
        }
        else
        {
            CALayer *sub = nil;
        
            for( int idx = 0; idx < [[self.layer sublayers] count]; idx++ )
            {
                sub = [[self.layer sublayers]objectAtIndex:idx];
            
                CGPoint currentPos = [sub position];
            
                if( currentPos.x >= mid_point )
                {
                    if( mViewObserver != nil )
                    {
                        [mViewObserver onCoverImageShifted:idx+mStartIndex withImagePath:[mPhotoNames objectAtIndex:idx]];
                    }
                
                    [self scaleAllLayerToOriginalSize];
                    [self slideToLayerByAnimation:sub];
                
                    break;
                }
            }    
        }
    }
    
    /*
     * Reset last drag point.
     */
    
    mOriginTouchedPoint.x = 0;
    mOriginTouchedPoint.y = 0;
    mIsDragging = false;
    mLastDragedPoint.x = 0;
    mLastDragedPoint.y = 0;
    mLastDragedDirection = 0;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)aRect
{
    /*
     * Draw the background.
     */
    
    UIImage *icon = nil;
    
    if( mBackground != nil )
    {
        icon = [UIImage imageNamed:mBackground];
        
        [icon drawInRect:aRect];
        
     //   [icon release];
        
        icon = nil;
    }
}

- (void)dealloc
{
    [self reset];
    
    mViewObserver = nil;
    
   // [mPhotos release];
    mPhotos = nil;
    
 //   [mPhotoNames release];
    mPhotoNames = nil;
    
   // [mBadgeNumbers release];
    mBadgeNumbers = nil;
    
  //  [mPhotoBadgeIcons release];
    mPhotoBadgeIcons = nil;
    
 //   [mPhotoBadgeTexts release];
    mPhotoBadgeTexts = nil;

	if (mBadgeColor != nil)
	{
	//	[mBadgeColor release];
		mBadgeColor = nil;
	}
    
    if (mBadgeIcon != nil)
	{
	//	[mBadgeIcon release];
		mBadgeIcon = nil;
	}
    
    if( mBackground != nil )
    {
      //  [mBackground release];
        mBackground = nil;
    }
    
  //  [super dealloc];
}

@end
