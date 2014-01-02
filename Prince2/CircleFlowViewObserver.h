//
//  CircleFlowViewObserver.h
//  CircleFlowViewDemo
//
//  Created by Mahmood1 on 12/4/2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CircleFlowViewObserver <NSObject>

@required

- (void)onCircleFlowShifted:(int)aIndex withIconPath:(NSString*)aFilePath;

- (void)onCircleFlowSelected:(int)aIndex withIconPath:(NSString*)aFilePath;

@end
