//
//  ViewController.m
//  testInputAccessoryView
//
//  Created by Ethan Neff on 1/26/15.
//  Copyright (c) 2015 ethanneff. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate>

@property (nonatomic) BOOL searchSubmitted;
@property (nonatomic) NSString *lastButtonTitle;
@property (nonatomic) UIButton *button;
@property (nonatomic) UITextField *fakeTextField;
@property (nonatomic) UITextField *inputTextField;

@end

@implementation ViewController

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchSubmitted = false;
    
    [self createScene];
    [self createNotifiers];
}

-(void)createNotifiers {
    // keyboard will show
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardDidShowNotification object:nil];
}

-(void)createScene {
    // frame
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    
    // button
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(40, 40, self.view.frame.size.width-80, 40)];
    [self.button setTag:10];
    [self.button setBackgroundColor:[UIColor darkGrayColor]];
    [self.button setTitle:@"button" forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonPressed:) forControlEvents: UIControlEventTouchUpInside];
    self.button.layer.borderWidth = 1;
    self.button.layer.borderColor = [UIColor whiteColor].CGColor;
    self.button.layer.cornerRadius = 15;
    [self.view addSubview:self.button];
    
    
    UITextField *randomTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, 200, self.view.frame.size.width-80, 32)];
    randomTextField.borderStyle = UITextBorderStyleRoundedRect;
    randomTextField.font = [UIFont systemFontOfSize:18.0];
    [randomTextField setBackgroundColor:[UIColor whiteColor]];
    [randomTextField setTintColor:[UIColor darkGrayColor]];
    [randomTextField setPlaceholder:@"Random textfield"];
    [randomTextField setTextColor:[UIColor darkGrayColor]];
    randomTextField.delegate = self;
    [randomTextField setReturnKeyType:UIReturnKeyDone];
    [self.view addSubview:randomTextField];
    
    // input accessory view
    UIView *inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
    inputAccessoryView.backgroundColor = [UIColor whiteColor];
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [cancel setTag:11];
    [cancel addTarget:self action:@selector(buttonPressed:) forControlEvents: UIControlEventTouchUpInside];
    [cancel setTitle:@"x" forState:UIControlStateNormal];
    cancel.titleLabel.font = [UIFont fontWithName:@"Menlo-Regular" size:35];
    [cancel setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 2, 0)];
    [cancel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [inputAccessoryView addSubview:cancel];
    
    UIButton *submit = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-40, 0, 40, 40)];
    [submit setTag:12];
    [submit addTarget:self action:@selector(buttonPressed:) forControlEvents: UIControlEventTouchUpInside];
    [submit setTitle:@"+" forState:UIControlStateNormal];
    submit.titleLabel.font = [UIFont fontWithName:@"Menlo-Regular" size:40];
    [submit setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [inputAccessoryView addSubview:submit];
    
    self.inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, 4, self.view.frame.size.width-80, 32)];
    self.inputTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.inputTextField.font = [UIFont systemFontOfSize:18.0];
    [self.inputTextField setBackgroundColor:[UIColor darkGrayColor]];
    [self.inputTextField setTintColor:[UIColor whiteColor]];
    [self.inputTextField setTextColor:[UIColor whiteColor]];
    [self.inputTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.inputTextField.delegate = self;
    [self.inputTextField setReturnKeyType:UIReturnKeyDone];
    [inputAccessoryView addSubview:self.inputTextField];
    
    // fake textfield
    self.fakeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.fakeTextField.inputAccessoryView = inputAccessoryView;
    [self.view addSubview:self.fakeTextField];
}

-(void)buttonPressed:(UIButton *)button {
    button.selected = !button.selected;
    
    if (button.tag == 10) {
        [self changeButtonColor:button];
        
        self.lastButtonTitle = button.titleLabel.text;
        
        // activate the fake textfield
        [self.fakeTextField becomeFirstResponder];
        
        // fill in the input textfield
        self.inputTextField.text = button.titleLabel.text;
    } else if (button.tag == 11 || button.tag == 12) {
        if (button.tag == 11) {
            [self.button setTitle:self.lastButtonTitle forState:UIControlStateNormal];
        }
        self.searchSubmitted = true;
        [self.inputTextField resignFirstResponder];
        [self resetButton];
        [self dismissKeyboard];
    }
}

-(void)changeButtonColor:(UIButton *)button {
    if (button.selected) {
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setEnabled:NO];
    } else {
        [button setBackgroundColor:[UIColor darkGrayColor]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setEnabled:YES];
    }
}

-(void)resetButton {
    // reset button
    [self.button setSelected:NO];
    [self changeButtonColor:self.button];
}

-(void)keyboardWillShow {
    // override the fake textfield with the input textfield
    [self.inputTextField becomeFirstResponder];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 *  NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        if (self.searchSubmitted) {
            self.searchSubmitted = false;
        } else {
            [self.button setTitle:self.lastButtonTitle forState:UIControlStateNormal];
            [self resetButton];
        }
    });
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    // deactivate the fake textfield and dismiss the keyboard
    [textField resignFirstResponder];
    
    self.searchSubmitted = true;
    [self resetButton];
    [self dismissKeyboard];
    
    return YES;
}

-(void)textFieldDidChange:(UITextField *)textField {
    // change button title
    [self.button setTitle:textField.text forState:UIControlStateNormal];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

@end