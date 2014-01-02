//
//  AppProperties.m
//  Xpert.AppFramework
//
//  Created by mike on 2010/9/15.
//  Copyright 2010 Xpert Consulting. All rights reserved.
//

#import "AppProperties.h"

//#import "XDtcUtility.h"


// declare private function
/*@interface AppProperties (Private)

+(NSString*) getStoragePath: (NSString*) basePath;

@end
*/

@implementation AppProperties


// override init
-(id) init
{
	// make the class can not be init 
	// (all functions are static, do not need to init)
	[self doesNotRecognizeSelector: _cmd];
	
	return nil;
}

/*+(NSString*) getAppHomePath
{
	return  NSHomeDirectory();
}

+(NSString*) getAppDocPath
{
	@synchronized (self)
	{
		if (_appDocPath == nil)
		{
			NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		
			_appDocPath = [[paths objectAtIndex: 0] retain];
		}
	}
	
	return _appDocPath;
}

+(NSString*) getAppCachesPath
{
	@synchronized (self)
	{
		if (_appCachesPath == nil)
		{
			NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES); 
			
			_appCachesPath = [[paths objectAtIndex: 0] retain];
		}
	}

	return _appCachesPath;
}

+(NSString*) getAppTempPath
{
	return [[self getAppHomePath] stringByAppendingPathComponent: @"tmp"];
}

+(NSString*) getAppStoragePath
{
	return [self getStoragePath: [self getAppDocPath]];
}

+(NSString*) getAppCachesStoragePath
{
	return [self getStoragePath: [self getAppCachesPath]];
}

// the temp path was different for every app session
+(NSString*) getTempPath
{
	return NSTemporaryDirectory();
}

+(NSString*) getAppName
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleName"];
}

+(NSString*) getDisplayName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleDisplayName"]; 
}

+(NSString*) getBundleIdentifier
{
	return [[NSBundle mainBundle] bundleIdentifier];
}

+(NSString*) getAppVersion
{    
	return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"];
}

+(NSString*) getAppInfoString
{    
	return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleGetInfoString"];
}

+(AppInfo*) createAppInfo
{
	return [[AppInfo alloc] initWithName: [self getAppName]  andVersion: [self getAppVersion]];
}

+(NSString*) getDeviceId
{
	//return [UIDevice currentDevice].uniqueIdentifier;
	return [XDtcUtility getDeviceId];
}

+(float) getOSVersion
{
	if (_osVersion == 0)
	{
		_osVersion = [[UIDevice currentDevice].systemVersion floatValue];
	}
	
	return _osVersion;
}

+(CGRect) getScreenSize
{
	CGRect rect = [[UIScreen mainScreen] bounds];
	UIInterfaceOrientation orientation = [self getOrientation];

	if (
	   orientation == UIInterfaceOrientationLandscapeLeft || 
	   orientation == UIInterfaceOrientationLandscapeRight
	   )
	{
		// in landscape mode, the width and height are resversed
		rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
	}
	
	return rect;
}

+(CGRect) getAppFrame
{
	// Frame of application screen area in points (i.e. entire screen minus status bar if visible)
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	UIInterfaceOrientation orientation = [self getOrientation];
	
	if (
	   orientation == UIInterfaceOrientationLandscapeLeft || 
	   orientation == UIInterfaceOrientationLandscapeRight
	   )
	{
		// in landscape mode, the width and height are resversed
		rect = CGRectMake(rect.origin.y, rect.origin.x, rect.size.height, rect.size.width);
	}
	
	return rect;
}

+(CGRect) getAppFrameWithoutNavigationBar
{
	int bar_height = 44;
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	UIInterfaceOrientation orientation = [self getOrientation];
	
	if (
	   orientation == UIInterfaceOrientationLandscapeLeft || 
	   orientation == UIInterfaceOrientationLandscapeRight
	   )
	{
		// in landscape mode, the width and height are resversed
		rect = CGRectMake(rect.origin.y, bar_height, rect.size.height, rect.size.width - bar_height);
	}
	else
	{
		rect = CGRectMake(rect.origin.x, bar_height, rect.size.width, rect.size.height - bar_height);
	}

	return rect;
}
*/
+(UIInterfaceOrientation) getOrientation
{
	return [[UIApplication sharedApplication] statusBarOrientation];
}

+(UIUserInterfaceIdiom) getUserInterfaceIdiom
{
	return UI_USER_INTERFACE_IDIOM();
}

+(BOOL) isRetina
{
    return [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0;
}

+(BOOL) is4InchResolution
{
    BOOL result = NO;
    
    // only iPhone has 4 inch
    if ([self getUserInterfaceIdiom] == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] bounds].size.height == 568)
    {
        result = YES;
    }
    
    return result;
}

/*+(void) release
{
	SAFE_DELETE(_appDocPath);
	SAFE_DELETE(_appCachesPath);
}
*/
@end


/*@implementation AppProperties (Private)

+(NSString*) getStoragePath: (NSString*) basePath
{
	NSString* path = [basePath stringByAppendingPathComponent: @"Storage"];
	if (![FileUtility isDirExisted: path])
	{
		// a singleton, do not need to release
		NSFileManager* fm = [NSFileManager defaultManager];
		
		[
		fm createDirectoryAtPath:
		path  
		withIntermediateDirectories: YES
		attributes: nil
		error: nil
		];
	}

	return path;
}

@end*/
