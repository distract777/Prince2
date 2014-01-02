//
//  PrSearchViewController.m
//  Prince2
//
//  Created by JJ  on 2013/12/27.
//  Copyright (c) 2013年 JJ Lai. All rights reserved.
//

#import "PrSearchViewController.h"

@interface PrSearchViewController ()

@end

@implementation PrSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   UIToolbar *toolbar = [[UIToolbar alloc] init];
   [toolbar setBarStyle:UIBarStyleBlackTranslucent];
   [toolbar sizeToFit];
   UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
   UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
   
   [toolbar setItems:[NSArray arrayWithObjects:buttonflexible,buttonDone, nil]];
   
   
   self.CountyPicker.dataSource=self;
   self.CountyPicker.delegate = self;
   
   
   _County.inputView=_CountyPicker;
   _County.inputAccessoryView = toolbar;
   self.CountyPicker.frame=CGRectMake(0, 480, 100, 216);
   NSString *path = [[NSBundle mainBundle] pathForResource:@"areaTW" ofType:@"plist"];
   self.citys = [NSArray arrayWithContentsOfFile:path];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)doneClicked:(UIBarButtonItem*)button
{
   [self.view endEditing:YES];
}




- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
   return  2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
   if (component == 0) return  self.citys.count;
   else return [[[self.citys objectAtIndex:self.rowInProvince] objectForKey:@"Cities"] count];
   
}
#pragma mark delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
   
   if (component == 0) {return [[self.citys objectAtIndex:row] objectForKey:@"State"];
   }
   else return [[[[self.citys objectAtIndex:self.rowInProvince] objectForKey:@"Cities"] objectAtIndex:row] objectForKey:@"city"];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
   if (component == 0){
      self.rowInProvince = row;
      [self.CountyPicker reloadComponent:1];
   }
   NSLog(@"component= %d ,row = %d",component,row);
   
   //NSInteger selectedRow0 = [self.CountyPicker selectedRowInComponent:0];
   // NSString *selectedPickerRow0=[self.citys objectAtIndex:selectedRow0];
   NSString *selectedRow0 = [NSString stringWithFormat:@"%@",[[self.citys objectAtIndex:[self.CountyPicker selectedRowInComponent:0]] objectForKey:@"State"]];
   self.County.text=selectedRow0;
   NSString *selectedRow1 = [NSString stringWithFormat:@"%@",[[[[self.citys objectAtIndex:self.rowInProvince] objectForKey:@"Cities"] objectAtIndex:[self.CountyPicker selectedRowInComponent:1]] objectForKey:@"city"]];
   self.CountyShip.text=selectedRow1;
   
   //NSInteger selectedRow1 = [self.CountyPicker selectedRowInComponent:1];
   // NSString *selectedPickerRow1=[self.citys objectAtIndex:selectedRow1];
   //self.CountyShip.text=selectedPickerRow1;
   
}

- (IBAction)PickerDone:(id)sender {
   
}
@end
