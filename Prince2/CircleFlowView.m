//
//  CircleFlowView.m
//  CircleFlowView
//
//  Created by Mahmood1 on 12/4/19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <unistd.h>

#import "CircleFlowView.h"

@implementation CircleFlowView

@synthesize mViewObserver;
@synthesize ScrollSpeeed;
@synthesize badgeColor = mBadgeColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mPhotos = [[NSMutableArray alloc] initWithCapacity:5];
        mPhotoBadgeIcons = [[NSMutableArray alloc] initWithCapacity:5];
        mPhotoBadgeTexts = [[NSMutableArray alloc] initWithCapacity:5];
        mPhotoNames = [[NSMutableArray alloc] initWithCapacity:5];
        mBadgeNumbers = [[NSMutableArray alloc] initWithCapacity:5];
        mStartIndex = -1;
        mEndIndex = -1;
        mYDiff = 0;
        mControlWidth = 100;
        mControlHeight = 100;
        mCurrentDegree = 0.0f;
        mScrollingSpeed = 1.0f;
        mLastDragedPoint.x = 0;
        mLastDragedPoint.y = 0;
        mLastDragedTime = 0;
        ScrollSpeeed = 1.0f;
        mBackground = nil;
        mBadgeIcon = nil;
        mBadgeFontSize = 20.0;
		mBadgeColor = [UIColor whiteColor];
        mDragging = false;
        mScrolling = false;
        mScrollingTarget = 0.0f;
        mScrollingClockWise = false;
        mCurrentFocusedIdx = -1;
        mSplitAngle = 140.0f;
        mSplitAlpha = 0.5;
        mMaxAlpha = 1.0f;
        mMinAlpha = 0.03;
        
        //[self setClipsToBounds:TRUE];
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
        UIImageView* photo = [mPhotos objectAtIndex:0];
        
        [mPhotos removeObjectAtIndex:0];
        
//[photo release];
    }
    
    while( [mPhotoNames count] > 0 )
    {
        NSString* name = [mPhotoNames objectAtIndex:0];
        
        [mPhotoNames removeObjectAtIndex:0];
        
        //[name release];
    }
    
    mStartIndex = -1;
    mEndIndex = -1;
    mCurrentFocusedIdx = -1;
}

- (float) calAngleFromPointToPoint:(float)aFromX withFromY:(float)aFromY withToX:(float)aToX withToY:(float)aToY withZeroDegreeBase:(int)aZeroDegreeBase
{
    int x_distance = 0;
    int y_distance = 0;
    
    if( aZeroDegreeBase == 0 )
    {
        x_distance = aToX - aFromX;
        y_distance = aToY - aFromY;
    }
    else if( aZeroDegreeBase == -90 )
    {
        x_distance = aToY - aFromY;
        y_distance = aToX - aFromX;
    }
    else if( aZeroDegreeBase == 90 )
    {
        x_distance = aFromY - aToY;
        y_distance = aFromX - aToX;
    }
    else if( aZeroDegreeBase == 180 )
    {
        x_distance = aFromX - aToX;
        y_distance = aFromY - aToY;
    }
    
    double cos_value = x_distance / sqrt( x_distance * x_distance + y_distance * y_distance );
    
    double angle = acos( cos_value ) / M_PI * 180.0f;
    
    if( aZeroDegreeBase == 0 )
    {
        if( aToY > aFromY ) angle = 360 - angle;
    }
    else if( aZeroDegreeBase == -90 )
    {
        if( aToX <= aFromX ) angle = 360 - angle;
    }
    else if( aZeroDegreeBase == 90 )
    {
        if( aToX > aFromX ) angle = 360 - angle;
    }
    else if( aZeroDegreeBase == 180 )
    {
        if( aToY <= aFromY ) angle = 360 - angle;
    }
    
    return ( float ) angle;
}

- (void)adjustPositionsOfSubControls
{
    if( mPhotos.count == 0 )
    {
        return;
    }
    
    
    float angle_diff = 360.0f / mPhotos.count;
    
    float frame_height = self.frame.size.height;
    float frame_width = self.frame.size.width;
    
    float frame_center_x = (frame_width / 2);
    float frame_center_y = (frame_height / 2);
    
    float max_item_height = mControlHeight;
    float max_item_width = mControlWidth;
    
    for( int idx = 0; idx < mPhotoBadgeIcons.count; idx++ )
    {
        UIImageView *badgeIcon = ( UIImageView* ) [mPhotoBadgeIcons objectAtIndex:idx];
        UILabel *badgeText = ( UILabel* ) [mPhotoBadgeTexts objectAtIndex:idx];
        int badgeNumber = [self getBadgeNumber:idx];
        
        if( mBadgeIcon == nil || badgeNumber <= 0 )
        {
            if( badgeIcon != nil )
            {
                [badgeIcon setHidden:true];
            }
            
            if( badgeText != nil )
            {
                [badgeText setHidden:true];
            }
        }
        else
        {
            if( badgeIcon != nil )
            {
                [badgeIcon setHidden:false];
            }
            
            if( badgeText != nil )
            {
                [badgeText setHidden:false];
                [badgeText setText:[NSString stringWithFormat:@"%d",badgeNumber]];
            }
        }
    }
    
    
    UIView *sub = nil;
    NSMutableArray *sortedPhotos1 = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray *sortedPhotos2 = [[NSMutableArray alloc] initWithCapacity:5];
    
    int   base_idx   = 0;
    float base_angle = 0;
    float min_angle  = 360;

    for( int idx = 0; idx < mPhotos.count; idx++ )
    {
        sub = [mPhotos objectAtIndex:idx];
        
        float view_angle = angle_diff * idx + mCurrentDegree;
        
        view_angle -= ( ( ( int ) ( view_angle / 360 ) ) * 360 );
        
        if( view_angle < 0 )
        {
            view_angle += 360;
        }
        else if( view_angle > 360 )
        {
            view_angle -= 360;
        }
        
        if( view_angle < min_angle ) min_angle = view_angle;
        
        [sub removeFromSuperview];

        if( sortedPhotos1.count == 0 )
        {
            [sortedPhotos1 addObject:sub];
            
            base_idx   = 0;
            base_angle = view_angle;
        }
        else if( view_angle > base_angle )
        {
            [sortedPhotos1 addObject:sub];
        }
        else
        {
            [sortedPhotos1 insertObject:sub atIndex:base_idx];

            base_idx++;
        }
    }
    
    int over180count = 0;
        
    for( int idx = 0; idx < sortedPhotos1.count; idx++ )
    {
        sub = [sortedPhotos1 objectAtIndex:idx];

        float view_angle = angle_diff * idx + min_angle;
        
        view_angle -= ( ( ( int ) ( view_angle / 360 ) ) * 360 );
        
        if( view_angle < 0 )
        {
            view_angle += 360;
        }
        else if( view_angle > 360 )
        {
            view_angle -= 360;
        }
        
        float item_width = max_item_width;
        float item_height = max_item_height;
        float item_x = frame_center_x;
        float item_y = frame_center_y;
        float round_circle_width  = frame_width - mControlWidth;
        float round_circle_height = frame_height - mControlHeight;
        
        if( view_angle <= 90.0f )
        {
            item_x += cosf( view_angle / 180.0f * M_PI ) * round_circle_width / 2;
            
            item_y -= sinf( view_angle / 180.0f * M_PI ) * round_circle_height / 2;
        }
        else if( view_angle <= 180.0f )
        {
            float angle = 180.0f - view_angle;
            
            item_x -= cosf( angle / 180.0f * M_PI ) * round_circle_width / 2;
            
            item_y -= sinf( angle / 180.0f * M_PI ) * round_circle_height / 2;
        }
        else if ( view_angle <= 270.0f && view_angle > 180)
        {
            float angle = 270.0f - view_angle;
            
            item_x -= sinf( angle / 180.0f * M_PI ) * round_circle_width / 2;
            
            item_y += cosf( angle / 180.0f * M_PI ) * round_circle_height / 2;
        }
        else
        {
            float angle = 360.0f - view_angle;
            
            item_x += cosf( angle / 180.0f * M_PI ) * round_circle_width / 2;
            
            item_y += sinf( angle / 180.0f * M_PI ) * round_circle_height / 2;
        }
        
        int abs_angle = view_angle;
        
        if( view_angle > 180 )
        {
            abs_angle = abs( 360 - view_angle );
        }
        
        float y_diff = mYDiff * ( abs_angle / 180.0f );
        
        item_y = item_y + ( mYDiff / 2 ) - y_diff;
        
        [sub setCenter:CGPointMake(item_x, item_y)];

        [sub setBounds:CGRectMake(0, 0, item_width, item_height)];
        
        float split_angle = mSplitAngle;
        float split_alpha = mSplitAlpha;
        float max_alpha = mMaxAlpha;
        float min_alpha = mMinAlpha;
        float alpha = max_alpha;
        
        if( abs_angle > split_angle )
        {
            alpha = ( max_alpha - split_alpha ) * ( ( abs_angle - split_angle ) / ( 180.0f - split_angle ) ) + split_alpha;
        }
        else
        {
            alpha = ( split_alpha - min_alpha ) * ( abs_angle / split_angle ) + min_alpha;
        }
        
        [sub setAlpha:alpha];
        
        if( ( ( int ) view_angle ) < 185 ) // + 5 degree to avoid difference of float type. Sometimes it is 180.XXXX, so can't just be <= 180
        {
            [sortedPhotos2 addObject:sub];
        }
        else
        {
            over180count++;
            
            int insertTo = sortedPhotos2.count - 1 - over180count;
            
            if( insertTo <= 0 ) insertTo = 0;

            [sortedPhotos2 insertObject:sub atIndex:insertTo];
        }
    }
    
    for( sub in sortedPhotos2 )
    {
        [self addSubview:sub];
    }
    
    sub = [sortedPhotos2 objectAtIndex:sortedPhotos2.count-1];

    mCurrentFocusedIdx = -1;
    
    for( int idx = 0; idx < mPhotos.count; idx++ )
    {
        if( sub == [mPhotos objectAtIndex:idx] )
        {
            mCurrentFocusedIdx = idx;

            break;
        }
    }

    [sortedPhotos1 removeAllObjects];
   // [sortedPhotos1 release];
    
    [sortedPhotos2 removeAllObjects];
   // [sortedPhotos2 release];
}

- (void)setMaxAlpha:(float) aMaxAlpha withMinAlpha:(float) aMinAlpha withSplitAlpha:(float) aSplitAlpha atSplitAngle:(float) aSplitAngle
{
    if( aMaxAlpha > 1.0f ) aMaxAlpha = 1.0f;
    
    if( aMaxAlpha < 0.0f ) aMaxAlpha = 0.0f;
    
    if( aMinAlpha > 1.0f ) aMinAlpha = 1.0f;
    
    if( aMinAlpha < 0.0f ) aMinAlpha = 0.0f;
    
    if( aMinAlpha > aMaxAlpha ) aMinAlpha = aMaxAlpha;
    
    if( aMinAlpha > aSplitAlpha ) aSplitAngle = aMinAlpha;
    
    if( aMaxAlpha < aSplitAlpha ) aSplitAlpha = aMaxAlpha;
    
    if( aSplitAngle < 0.0 ) aSplitAngle = 1.0f;
    
    if( aSplitAlpha >= 180.0 ) aSplitAngle = 179.0;
    
    mMaxAlpha = aMaxAlpha;
    mMinAlpha = aMinAlpha;
    mSplitAlpha = aSplitAlpha;
    mSplitAngle = aSplitAngle;
    
    [self adjustPositionsOfSubControls];
}

- (void)runScrollTask
{
	@autoreleasepool
    {
        while( mScrolling )
        {
            if( mScrollingTarget == 0 )
            {
                break;
            }
            
            
            float diff = 0.0f;
            
            if( abs( mScrollingTarget ) >= 1.0 )
            {
                diff = mScrollingTarget * 2 / 3;
            }
            else
            {
                diff = mScrollingTarget;
            }

            mCurrentDegree += diff;
            mScrollingTarget -= diff;

            // add by tao, to fix the duplicated circle item bug
            if (mCurrentDegree < 0)
            {
                mCurrentDegree += 360;
            }
            else if (mCurrentDegree >= 360)
            {
                mCurrentDegree -= 360;
            }

            [self performSelectorOnMainThread:@selector( adjustPositionsOfSubControls ) withObject:nil waitUntilDone:false];
            
            usleep( 20000 );
        }

        [self performSelectorOnMainThread:@selector( adjustPositionsOfSubControls ) withObject:nil waitUntilDone:false];
        
        mScrolling = false;
        mScrollingTarget = 0.0f;
    }
}

-(void) addBadgeView: (UIView*) container
{
    @autoreleasepool
    {
        if( mBadgeIcon != nil )
        {
            UIImageView *badge_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:mBadgeIcon]];
        
            CGRect icon_frame = badge_icon.frame;
            int icon_x = mControlWidth - 20 - icon_frame.size.width;
            int icon_y = -icon_frame.size.height / 2;
            int icon_w = icon_frame.size.width;
            int icon_h = icon_frame.size.height;
            
            badge_icon.opaque = NO;
            [badge_icon setFrame:CGRectMake(icon_x, icon_y, icon_w, icon_h)];
            [container addSubview:badge_icon];
            
            UILabel* badge_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, icon_w, icon_h)];
        
            UIFont *badge_font = [UIFont boldSystemFontOfSize: mBadgeFontSize];
            
            int text_x = mControlWidth - 20 - ( icon_frame.size.width );
            int text_y = badge_font.capHeight / 2;
            
            [badge_label setFrame:CGRectMake(text_x, text_y, icon_w, icon_y)];
            badge_label.text = [NSString stringWithFormat:@"%d",0];
            badge_label.font = [UIFont boldSystemFontOfSize: mBadgeFontSize];
            badge_label.textColor = mBadgeColor;
            badge_label.backgroundColor = [UIColor clearColor];
            badge_label.textAlignment = NSTextAlignmentCenter;
            [container addSubview:badge_label];
            
            [mPhotoBadgeIcons addObject:badge_icon];
            [mPhotoBadgeTexts addObject:badge_label];
        }
        
        NSNumber *badge = [NSNumber numberWithInt:0];
        [mBadgeNumbers addObject:badge];
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

- (void)setControlWidth:(int)aWidth withControlHeight:(int)aHeight withYDiff:(int)aYDiff withScrollSpeed:(float)aScrollingSpeed
{
    mYDiff = aYDiff;
    mControlWidth  = aWidth;
    mControlHeight = aHeight;
    mScrollingSpeed = aScrollingSpeed;
    
    if( mBadgeIcon != nil )
    {
        for( int idx = 0; idx < mPhotoBadgeIcons.count; idx++ )
        {
            UIImageView *badge_icon = ( UIImageView* ) [mPhotoBadgeIcons objectAtIndex:idx];
        
            CGRect icon_frame = badge_icon.frame;
        
            int icon_x = mControlWidth - 20 - icon_frame.size.width;
            int icon_y = -icon_frame.size.height / 2;
            int icon_w = icon_frame.size.width;
            int icon_h = icon_frame.size.height;
        
            [badge_icon setFrame:CGRectMake(icon_x, icon_y, icon_w, icon_h)];
        
            UILabel* badge_label = ( UILabel* ) [mPhotoBadgeTexts objectAtIndex:idx];
        
            UIFont *badge_font = [UIFont boldSystemFontOfSize: mBadgeFontSize];
        
            int text_x = mControlWidth - 20 - ( icon_frame.size.width );
            int text_y = badge_font.capHeight / 2;
        
            [badge_label setFrame:CGRectMake(text_x, text_y, icon_w, icon_y)];
        }
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

- (void)setBackgroundIcon:(NSString*)aBackground andBadgeIcon:(NSString *)aBadge andBadgeFontSize:(float)aBadgeFontSize
{
    /*
     * Set background
     */
    
	if( mBackground != nil )
    {
	//	[mBackground release];
        mBackground = nil;
    }
	
    if( aBackground != nil )
    {
        mBackground = [[NSString alloc] initWithString:aBackground];
    }	
    
    /*
     * Set badge
     */
    
    if( aBadge != nil )
    {
        mBadgeIcon = [NSString stringWithString:aBadge];
    }
    else if( mBadgeIcon != nil )
    {
       // [mBadgeIcon release];
        
        mBadgeIcon = nil;
    }
    
    mBadgeFontSize = aBadgeFontSize;
    
    [self adjustPositionsOfSubControls];    
}

- (void)setFocusedIndex:(int)aIndex
{
    if( aIndex < 0 || aIndex >= mPhotos.count ) return;
    
    mScrolling = true;
    mDragging = false;
    
    float angle_diff = 360.0f / mPhotos.count;
    float selected_view_angle = 0.0f;
    
    float target_angle = 180.0f;
    
    UIView *sub = nil;
        
    sub = [mPhotos objectAtIndex:aIndex];
            
    float view_angle = angle_diff * aIndex + mCurrentDegree;
            
    view_angle -= ( ( ( int ) ( view_angle / 360 ) ) * 360 );
            
    if( view_angle < 0 )
    {
        view_angle += 360;
    }
    else if( view_angle > 360 )
    {
        view_angle -= 360;
    }
            
    selected_view_angle = view_angle;
    
    [mViewObserver onCircleFlowShifted:aIndex+mStartIndex withIconPath:[mPhotoNames objectAtIndex:aIndex]];
    
    mScrollingTarget = target_angle - selected_view_angle;
    
    [NSThread detachNewThreadSelector:@selector(runScrollTask) toTarget:self withObject:nil];
}

- (void)loadPhotoFromResourceWithPrefix:(NSString*)aPrefix withStartIndex:(int)aStartIndex withEndIndex:(int)aEndIndex withImageType:(NSString*)aType 
{
    [self reset];
    
    CGRect frame = [self frame];
    
    for( int idx = aStartIndex; idx <= aEndIndex; idx++ )
    {
        NSString* image_name = nil;
        
        image_name = aPrefix;
        image_name = [image_name stringByAppendingString:[NSString stringWithFormat:@"%d.",idx]];
        image_name = [image_name stringByAppendingString:aType];
        
        UIImage* icon = [UIImage imageNamed:image_name];
        UIImageView *obj_image = [[UIImageView alloc] initWithImage:icon];
        
        obj_image.opaque = NO; // explicitly opaque for performance
        [obj_image setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        [mPhotos addObject:obj_image];
        [mPhotoNames addObject:image_name];
        
        [self addSubview:obj_image];
        [self addBadgeView: obj_image];
    }
    
    mStartIndex = 0;
    mEndIndex = aEndIndex - aStartIndex;
    
    [self adjustPositionsOfSubControls];
}

- (void)loadPhotoFromStorageWithFolder:(NSString*)aFolder withPrefix:(NSString*)aPrefix withStartIndex:(int)aStartIndex withEndIndex:(int)aEndIndex withImageType:(NSString*)aType
{
    [self reset];
    
    CGRect frame = [self frame];
    
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
        
        UIImageView *obj_image = [[UIImageView alloc] initWithImage:icon];
        
        obj_image.opaque = NO; // explicitly opaque for performance
        
        [obj_image setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        [mPhotos addObject:obj_image];
        [mPhotoNames addObject:image_name];
        
        [self addSubview:obj_image];
        [self addBadgeView: obj_image];
    }
    
    mStartIndex = 0;
    mEndIndex = aEndIndex - aStartIndex;  
    
    [self adjustPositionsOfSubControls];
}

- (void)loadPhotoFromFileSelection:(id<FileSelectionInter>) mSelection
{
    [self reset];
    
    CGRect frame = [self frame];
    int count = [mSelection getCount];
    
    for( int idx = 0; idx < count; idx++ )
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
        
        UIImageView *obj_image = [[UIImageView alloc] initWithImage:icon];
        obj_image.opaque = NO; // explicitly opaque for performance
        [obj_image setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        [mPhotos addObject:obj_image];
        [mPhotoNames addObject:image_name];
        
        [self addSubview:obj_image];
        [self addBadgeView: obj_image];
    }
    
    mStartIndex = 0;
    mEndIndex = count - 1; 
    
    [self adjustPositionsOfSubControls];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    mLastDragedPoint = [[touches anyObject] locationInView:self];
    mLastDragedTime = [(UITouch*)[touches anyObject] timestamp];
    
    mDragging = false;
    mScrolling = false;
    mScrollingTarget = 0.0f;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint currentDragedPoint = [[touches anyObject] locationInView:self];
    NSTimeInterval currentDragedTime = [(UITouch*)[touches anyObject] timestamp];
    
    UIImageView *focused_view = nil;
    
    if( mCurrentFocusedIdx >= 0 )
    {
        focused_view = (UIImageView*) [mPhotos objectAtIndex:mCurrentFocusedIdx];
        
        CGRect focused_frame = focused_view.frame;
        
        if( !mDragging &&
           mLastDragedPoint.x >= focused_frame.origin.x && mLastDragedPoint.x < focused_frame.origin.x+focused_frame.size.width &&
           mLastDragedPoint.y >= focused_frame.origin.y && mLastDragedPoint.y < focused_frame.origin.y+focused_frame.size.height )
        {
            int abs_x = abs( currentDragedPoint.x - mLastDragedPoint.x );
            int abs_y = abs( currentDragedPoint.y - mLastDragedPoint.y );
            
            if( abs_x <= 15 && abs_y <= 15 && ( currentDragedTime - mLastDragedTime ) < 0.5f )
            {
                return;
            }
        }
    }
    
    mDragging = true;
    
    bool clock_wise = FALSE;
    
    float frame_center_x = (self.frame.size.width / 2);
    float frame_center_y = (self.frame.size.height / 2);
    
    float prev_angle = [self calAngleFromPointToPoint:frame_center_x withFromY:frame_center_y withToX:mLastDragedPoint.x withToY:mLastDragedPoint.y withZeroDegreeBase:-90];
    
    float current_angle = [self calAngleFromPointToPoint:frame_center_x withFromY:frame_center_y withToX:currentDragedPoint.x withToY:currentDragedPoint.y withZeroDegreeBase:-90];
    
    float angle_diff = 0.0f;
    
    if( prev_angle > 270.0f && current_angle < 90.0f )
    {
        angle_diff = 360.0f + current_angle - prev_angle;
    }
    else if( current_angle > 270.0f && prev_angle < 90.0f )
    {
        angle_diff = current_angle - prev_angle - 360.0f;
    }
    else
    {
        angle_diff = current_angle - prev_angle;
    }
    
    if( angle_diff == 0 ) return;
    
    if( ScrollSpeeed > 0.0f )
    {
        angle_diff = angle_diff * ScrollSpeeed;
    }
    
    clock_wise = angle_diff < 0;
    
    mCurrentDegree += ( angle_diff * mScrollingSpeed );
    
    if( mCurrentDegree < 0 )
    {
        mCurrentDegree += 360;
    }
    else if( mCurrentDegree >= 360 )
    {
        mCurrentDegree = 0;
    }
    
    [self adjustPositionsOfSubControls];
    
    mLastDragedPoint = currentDragedPoint;
    
    mScrollingClockWise = clock_wise;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint currentDragedPoint = [[touches anyObject] locationInView:self];
    NSTimeInterval currentDragedTime = [(UITouch*)[touches anyObject] timestamp];
    
    UIImageView *focused_view = nil;

    if( mCurrentFocusedIdx >= 0 )
    {
        focused_view = (UIImageView*) [mPhotos objectAtIndex:mCurrentFocusedIdx];

        CGRect focused_frame = focused_view.frame;
    
        if( !mDragging &&
           mLastDragedPoint.x >= focused_frame.origin.x && mLastDragedPoint.x < focused_frame.origin.x+focused_frame.size.width &&
           mLastDragedPoint.y >= focused_frame.origin.y && mLastDragedPoint.y < focused_frame.origin.y+focused_frame.size.height )
        {
            int abs_x = abs( currentDragedPoint.x - mLastDragedPoint.x );
            int abs_y = abs( currentDragedPoint.y - mLastDragedPoint.y );
        
            if( abs_x <= 15 && abs_y <= 15 && ( currentDragedTime - mLastDragedTime ) < 0.5f )
            {
                if( mViewObserver != nil && mCurrentFocusedIdx >= 0 )
                {
                    [mViewObserver onCircleFlowSelected:mCurrentFocusedIdx withIconPath:[mPhotoNames objectAtIndex:mCurrentFocusedIdx]];
                }
                
                mLastDragedPoint.x = 0;
                mLastDragedPoint.y = 0;
                mLastDragedTime = 0;
                
                mScrolling = false;
                mDragging = false;
                
                return;
            }
        }
    }

    mLastDragedPoint.x = 0;
    mLastDragedPoint.y = 0;
    mLastDragedTime = 0;
    
    mScrolling = true;
    mDragging = false;
    
    float angle_diff = 360.0f / mPhotos.count;
    float selected_view_angle = 0.0f;
    int seleced_view_idx = -1;
    
    float target_angle = 180.0f;

    if( mScrollingClockWise )
    {
        UIView *sub = nil;
        
        for( int idx = 0; idx < mPhotos.count; idx++ )
        {
            sub = [mPhotos objectAtIndex:idx];
            
            float view_angle = angle_diff * idx + mCurrentDegree;
            
            view_angle -= ( ( ( int ) ( view_angle / 360 ) ) * 360 );
            
            if( view_angle < 0 )
            {
                view_angle += 360;
            }
            else if( view_angle > 360 )
            {
                view_angle -= 360;
            }

            if( view_angle >= target_angle && abs( target_angle - selected_view_angle ) > abs( target_angle - view_angle ) )
            {
                seleced_view_idx = idx;
                selected_view_angle = view_angle;
            }
        }
    }
    else
    {
        UIView *sub = nil;
        
        for( int idx = 0; idx < mPhotos.count; idx++ )
        {
            sub = [mPhotos objectAtIndex:idx];
            
            float view_angle = angle_diff * idx + mCurrentDegree;
            
            view_angle -= ( ( ( int ) ( view_angle / 360 ) ) * 360 );
            
            if( view_angle < 0 )
            {
                view_angle += 360;
            }
            else if( view_angle > 360 )
            {
                view_angle -= 360;
            }
            
            if( view_angle <= target_angle && abs( target_angle - selected_view_angle ) > abs( target_angle - view_angle ) )
            {
                seleced_view_idx = idx;
                selected_view_angle = view_angle;
            }
        }
    }
    
    if( seleced_view_idx >= 0 )
    {
        [mViewObserver onCircleFlowShifted:seleced_view_idx+mStartIndex withIconPath:[mPhotoNames objectAtIndex:seleced_view_idx]];
    }
    
    mScrollingTarget = target_angle - selected_view_angle;
    
    [NSThread detachNewThreadSelector:@selector(runScrollTask) toTarget:self withObject:nil];
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
        icon = [UIImage imageNamed: mBackground];
        [icon drawInRect:aRect];
        
        icon = nil;
    }
}

- (void)dealloc
{
    [self reset];
    
   // [mBadgeNumbers release];
    mBadgeNumbers = nil;
    
    //[mPhotoBadgeIcons release];
    mPhotoBadgeIcons = nil;
    
    //[mPhotoBadgeTexts release];
    mPhotoBadgeTexts = nil;
    
  //  [mPhotos release];
    mPhotos = nil;
    
    //[mPhotoNames release];
    mPhotoNames = nil;
	
	if (mBadgeColor != nil)
	{
	//	[mBadgeColor release];
		mBadgeColor = nil;
	}
    
    //[super dealloc];
}

@end
