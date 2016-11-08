//
//  ViewController.m
//  ContactsDemo
//
//  Created by JZY on 16/11/8.
//  Copyright © 2016年 CZ. All rights reserved.
//

#import "ViewController.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

#import "Contacts.h"


@interface ViewController ()<CNContactPickerDelegate>

@property (nonatomic,strong)UITextView * textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton * btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn1.frame = CGRectMake(0, 100, self.view.frame.size.width/2, 50);
    [btn1 setTitle: @"获取通讯录页面" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(getPhonebookWithSystemUI:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton * btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn2.frame = CGRectMake(self.view.frame.size.width/2, 100, self.view.frame.size.width/2, 50);
    [btn2 setTitle: @"获取通讯录数据" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(getPhonebookData:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    self.textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, self.view.frame.size.height - 200)];
    [self.view addSubview:self.textView];
    self.textView.editable = NO;
    
}

-(void)getPhonebookWithSystemUI:(UIButton *)sender{
    
    CNContactPickerViewController * picker = [[CNContactPickerViewController alloc]init];
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}
-(void)getPhonebookData:(UIButton *)sender{
    
    
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker{
    
}

#pragma mark contactPickerDelegate

//单选联系人
//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
//    
//    for (CNLabeledValue * phoneLabel in contact.phoneNumbers) {
//        CNPhoneNumber * phone = phoneLabel.value;
//        self.textView.text = [self.textView.text stringByAppendingFormat:@"%@\n",phone.stringValue];
//    }
//}

//单选联系人详情
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty{
    CNPhoneNumber * phone = contactProperty.value;
    self.textView.text = [NSString stringWithFormat:@"%@",phone.stringValue];
}

/*!
 //多选联系人
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact*> *)contacts{
    
}
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperties:(NSArray<CNContactProperty*> *)contactProperties{
    
}
 */


#pragma mark phonebookDelegate
-(void)choosePerson:(NSString *)phone{
    self.textView.text = [self.textView.text stringByAppendingFormat:@"%@\n",phone];
}


@end
