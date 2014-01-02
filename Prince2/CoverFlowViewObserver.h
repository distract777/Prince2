//
//  CoverFlowViewObserver.h
//  FunctionBarDemo
//
//  Created by Mahmood1 on 12/4/5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CoverFlowViewObserver <NSObject>

@required

- (void)onCoverImageShifted:(int)aIndex withImagePath:(NSString*)aFilePath;

- (void)onCoverImageSelected:(int)aIndex withImagePath:(NSString*)aFilePath;

@end
