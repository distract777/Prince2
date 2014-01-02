//
//  FileSelectionInter.h
//  CarAnimationDemo
//
//  Created by Mahmood1 on 12/4/9.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FileSelectionInter <NSObject>

@required

- (bool)isInternalResource;

- (int)getCount;

- (NSString*)getFilePath:(int) aIndex;

@end
