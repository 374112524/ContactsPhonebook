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
    self.textView.text = @"";
    [self.view addSubview:self.textView];
    self.textView.editable = NO;
    
    UIButton * btn3 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn3.frame = CGRectMake(0, 50, self.view.frame.size.width, 50);
    [btn3 setTitle: @"新建联系人" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    
}

-(void)addButtonAction:(UIButton *)sender{
    [self addContactsImage:nil givenName:@"名" familyName:@"姓" email:@"email" phoneNumber:@"111-1111-1111" streetAddress:@"street" cityAddress:@"city" stateAddress:@"state"];
}

-(void)getPhonebookWithSystemUI:(UIButton *)sender{
    
    CNContactPickerViewController * picker = [[CNContactPickerViewController alloc]init];
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

//判断授权
-(BOOL)authStatus{
    __block BOOL auth = NO;
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined || [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] ==  CNAuthorizationStatusAuthorized) {
        //信号量
        dispatch_semaphore_t sema=dispatch_semaphore_create(0);
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            auth = granted;
            //发送一次信号
            dispatch_semaphore_signal(sema);
        }];
        //等待信号触发
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    if (!auth) {
        //iOS8之后新的alert
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:@"获取授权失败，请在在设置中允许程序访问通讯录" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    return auth;
}

-(void)getPhonebookData:(UIButton *)sender{
    if (![self authStatus]) {
        return;
    }
    
    // 获取联系人
    CNContactStore * store = [[CNContactStore alloc] init];
    //创建请求对象
    NSArray * keys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
    CNContactFetchRequest * request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
    
    [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        //主线程刷新ui
        dispatch_async(dispatch_get_main_queue(),^{
            self.textView.text = [self.textView.text stringByAppendingFormat:@"\n%@-%@\n",contact.givenName, contact.familyName];
        });
        
        for (CNLabeledValue * labelValue in contact.phoneNumbers) {
            CNPhoneNumber * number = labelValue.value;
            dispatch_async(dispatch_get_main_queue(),^{
                self.textView.text = [self.textView.text stringByAppendingFormat:@"%@\n",number.stringValue];
            });
        }
    }];
}

-(void)addContactsImage:(NSString *)imageName givenName:(NSString *)givenName familyName:(NSString *)familyName  email:(NSString *)email phoneNumber:(NSString *)phoneNumber streetAddress:(NSString *)streetAddress cityAddress:(NSString *)cityAddress stateAddress:(NSString *)stateAddress{
    if (![self authStatus]) {
        return;
    }
    CNMutableContact * contact = [[CNMutableContact alloc] init];
    //名字
    contact.givenName = givenName;
    //姓氏
    contact.familyName = familyName;
    //邮箱
    CNLabeledValue * cHomeEmail = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:email];
    contact.emailAddresses = @[cHomeEmail];
    //电话号码
    contact.phoneNumbers = @[[CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberiPhone value:[CNPhoneNumber phoneNumberWithStringValue:phoneNumber]]];
    //头像
    contact.imageData = UIImagePNGRepresentation([UIImage imageNamed:imageName]);
    //住址
    CNMutablePostalAddress * homeAddress = [[CNMutablePostalAddress alloc] init];
    homeAddress.street = streetAddress;
    homeAddress.city = cityAddress;
    homeAddress.state = stateAddress;
    contact.postalAddresses = @[[CNLabeledValue labeledValueWithLabel:CNLabelHome value:homeAddress]];
    //保存请求
    CNSaveRequest * saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest addContact:contact toContainerWithIdentifier:nil];
    
    CNContactStore * store = [[CNContactStore alloc] init];
    [store executeSaveRequest:saveRequest error:nil];
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


@end
