//
//  PrSearchViewController.h
//  Prince2
//
//  Created by JJ  on 2013/12/27.
//  Copyright (c) 2013年 JJ Lai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrSearchViewController : UIViewController<UIPickerViewDelegate, UITextFieldDelegate,UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UIPickerView *CountyPicker;
@property (strong, nonatomic) IBOutlet UITextField *County;
@property (strong, nonatomic) IBOutlet UITextField *CountyShip;
@property (strong, nonatomic) IBOutlet UITextField *BuildingType;
//@property (strong, nonatomic) IBOutlet UIToolbar *DoneToolBar;

- (IBAction)PickerDone:(id)sender;


@property (retain ,nonatomic) NSArray *citys;
@property (assign ,nonatomic) NSInteger rowInProvince;







@end
