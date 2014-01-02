//
//  PrViewController.m
//  Prince2
//
//  Created by JJ  on 2013/12/26.
//  Copyright (c) 2013年 JJ Lai. All rights reserved.
//
#import "PrViewController.h"
#import "CoverFlowViewObserver.h"



@implementation PrViewController


-(void)viewDidLoad{


   [super viewDidLoad];
   
	
   _coverFlow = [
                 [CoverFlowView alloc] initWithFrame:
                 CGRectMake(0,  170, 320, 267)
                 ];
   
   [_coverFlow loadPhotoFromFileSelection: self];
	
	[
    _coverFlow setPaddingTop:
    10
    withBottom: 10
    withControlDistance: 10
    withControlWidth: 155
    withControlHeight: 230
    withScrollSpeed: 3.0f
    with360Distance: 3000
    withScaledWidth: 180
    withScaledHeight: 267
    ];
   
	[_coverFlow setSelectedIndex: 3];
	_coverFlow.backgroundColor = [UIColor clearColor];
   _coverFlow.mViewObserver = self;
   [self.view addSubview: _coverFlow];

}

-(bool) isInternalResource
{
	return YES;
}

-(int) getCount
{
	return 8;
}

-(NSString*) getFilePath: (int) aIndex
{
	switch (aIndex)
	{
		case 0:
			return @"tutorial.png";
			
		case 1:
			return @"poi.png";
			
		case 2:
			return @"news.png";
			
		case 3:
			return @"building.png";
         
		case 4:
			return @"activity.png";
         
		case 5:
			return @"dormitory.png";
         
		case 6:
			return @"office_web_site.png";
         
		case 7:
			return @"history_building.png";
	} 
   
	return @"";
}

-(void) onCoverImageShifted: (int) aIndex  withImagePath: (NSString*) aFilePath
{
	// nothing to do
}

-(void) onCoverImageSelected: (int) aIndex  withImagePath: (NSString*) aFilePath
{
   UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
 
   switch (aIndex) {
         
      case 3: // 實價登錄
      {
         
      }
         break;
   

         
         
     case 4: // 實價登錄
   {  UIViewController *next = [board instantiateViewControllerWithIdentifier:@"PrSearchViewController"];
      
     
    [self presentViewController:next animated:YES completion:nil];
      
     
   }
   break;
   }

   
   
   
}





@end






