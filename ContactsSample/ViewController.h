//
//  ViewController.h
//  ContactsSample
//
//  Created by 모바일보안팀 on 2016. 1. 7..
//  Copyright © 2016년 minjoongkim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ContactsUI/ContactsUI.h>

@interface ViewController : UIViewController <CNContactViewControllerDelegate, CNContactPickerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *contactList;
@property (nonatomic, strong) IBOutlet UITableView *contactTableView;


-(IBAction)loadContactPickerView;

@end

