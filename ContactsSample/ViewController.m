//
//  ViewController.m
//  ContactsSample
//
//  Created by 모바일보안팀 on 2016. 1. 7..
//  Copyright © 2016년 minjoongkim. All rights reserved.
//

#import "ViewController.h"
#import <Contacts/Contacts.h>
#import "ContactCell.h"


@interface ViewController ()

@end

@implementation ViewController
@synthesize contactList, contactTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    contactList = [[NSMutableArray alloc] init];
    [self loadContactList];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadContactList {
    [contactList removeAllObjects];
    [self loadContactList];
}

-(void)loadContactList {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if( status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted)
    {
        NSLog(@"access denied");
    }
    else
    {
        //Create repository objects contacts
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        
        //Select the contact you want to import the key attribute  ( https://developer.apple.com/library/watchos/documentation/Contacts/Reference/CNContact_Class/index.html#//apple_ref/doc/constant_group/Metadata_Keys )
        
        NSArray *keys = [[NSArray alloc]initWithObjects:CNContactIdentifierKey, CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey, CNContactPhoneNumbersKey, CNContactViewController.descriptorForRequiredKeys, nil];
        
        // Create a request object
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
        request.predicate = nil;
        
        [contactStore enumerateContactsWithFetchRequest:request
                                                  error:nil
                                             usingBlock:^(CNContact* __nonnull contact, BOOL* __nonnull stop)
         {
             // Contact one each function block is executed whenever you get
             NSString *phoneNumber = @"";
             if( contact.phoneNumbers)
                 phoneNumber = [[[contact.phoneNumbers firstObject] value] stringValue];
             
             NSLog(@"phoneNumber = %@", phoneNumber);
             NSLog(@"givenName = %@", contact.givenName);
             NSLog(@"familyName = %@", contact.familyName);
             NSLog(@"email = %@", contact.emailAddresses);
             
             
             [contactList addObject:contact];
         }];
        
        [contactTableView reloadData];
    }
    
}

#pragma mark -
#pragma mark Contact Method


-(IBAction)newContact:(id)sender {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Add"
                                          message:@"New Contact"
                                          preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Firstname";
     }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"PhoneNumber";
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *firstname = alertController.textFields.firstObject;
                                   UITextField *phonenumber = alertController.textFields.lastObject;
                                   
                                   [self saveContact:firstname.text givenName:@"" phoneNumber:phonenumber.text];
                               }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}


-(void)saveContact:(NSString*)familyName givenName:(NSString*)givenName phoneNumber:(NSString*)phoneNumber {
    CNMutableContact *mutableContact = [[CNMutableContact alloc] init];
    
    mutableContact.givenName = givenName;
    mutableContact.familyName = familyName;
    CNPhoneNumber * phone =[CNPhoneNumber phoneNumberWithStringValue:phoneNumber];
    
    mutableContact.phoneNumbers = [[NSArray alloc] initWithObjects:[CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberiPhone value:phone], nil];
    CNContactStore *store = [[CNContactStore alloc] init];
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest addContact:mutableContact toContainerWithIdentifier:store.defaultContainerIdentifier];
    
    NSError *error;
    if([store executeSaveRequest:saveRequest error:&error]) {
        NSLog(@"save");
        [self reloadContactList];
    }else {
        NSLog(@"save error");
    }
}



-(void)updateContact:(CNContact*)contact memo:(NSString*)memo{
    CNMutableContact *mutableContact = contact.mutableCopy;
    
    mutableContact.note = memo;

    CNContactStore *store = [[CNContactStore alloc] init];
    CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
    [saveRequest updateContact:mutableContact];
    
    NSError *error;
    if([store executeSaveRequest:saveRequest error:&error]) {
        NSLog(@"save");
    }else {
        NSLog(@"save error : %@", [error description]);
    }
}


-(void)deleteContact:(CNContact*)contact {
    CNMutableContact *mutableContact = contact.mutableCopy;
    
    CNContactStore *store = [[CNContactStore alloc] init];
    CNSaveRequest *deleteRequest = [[CNSaveRequest alloc] init];
    [deleteRequest deleteContact:mutableContact];
    
    NSError *error;
    if([store executeSaveRequest:deleteRequest error:&error]) {
        NSLog(@"delete complete");
        [self reloadContactList];
    }else {
        NSLog(@"delete error : %@", [error description]);
    }
    
}
#pragma mark -
#pragma mark Load Contact Method

-(void)loadContactView:(CNContact*)contact {
    // Create a new contact view
    CNContactViewController *contactController = [CNContactViewController viewControllerForContact:contact];
    contactController.delegate = self;
    contactController.allowsEditing = YES;
    contactController.allowsActions = YES;

    // Display the view
    [self.navigationController pushViewController:contactController animated:YES];
}


//To allow the user to select an email address from the contacts in their database, you could use the following code
-(IBAction)loadContactPickerView{
    // Create a new picker
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
    // Select property to pick
    [contactPicker setDisplayedPropertyKeys:[[NSArray alloc] initWithObjects:CNContactEmailAddressesKey, nil] ];
    [contactPicker setPredicateForEnablingContact:[NSPredicate predicateWithFormat:@"emailAddresses.@count > 0"]];
    [contactPicker setPredicateForSelectionOfContact:[NSPredicate predicateWithFormat:@"emailAddresses.@count == 1"]];
    // Respond to selection
    contactPicker.delegate = self;
    // Display picker
    [self presentViewController:contactPicker animated:YES completion:nil];

}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"contactList count = %d", (int)[contactList count]);
    return [contactList count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    CNContact* contact = [contactList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@", contact.familyName, contact.givenName];
    
    return  cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CNContact* contact = [contactList objectAtIndex:indexPath.row];
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"ContactsSample"
                                          message:@""
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *detailAction = [UIAlertAction
                                actionWithTitle:@"Detail"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action)
                                {
                                    [self loadContactView:contact];
                                }];
    
    UIAlertAction *updateAction = [UIAlertAction
                               actionWithTitle:@"Update"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UIAlertController *alertController = [UIAlertController
                                                                         alertControllerWithTitle:@"Update"
                                                                         message:@"Add Memo"
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                                   [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
                                   {
                                        textField.placeholder = @"Memo";
                                   }];
                                   
                                   UIAlertAction *okAction = [UIAlertAction
                                                              actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action)
                                                              {
                                                                  UITextField *memo = alertController.textFields.firstObject;
                                                                  NSLog(@"memo = %@", memo.text);
                                                                  [self updateContact:contact memo:memo.text];
                                                              }];
                                   
                                   [alertController addAction:okAction];
                                   [self presentViewController:alertController animated:YES completion:nil];
                               }];
    
    UIAlertAction *deleteAction = [UIAlertAction
                                  actionWithTitle:@"Delete"
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction *action)
                                  {
                                      NSLog(@"Reset action");
                                      [self deleteContact:contact];

                                  }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:detailAction];
    [alertController addAction:updateAction];
    [alertController addAction:deleteAction];
    
    [self presentViewController:alertController animated:YES completion:nil];

}
#pragma mark -
#pragma mark CNContactPickerDelegate
/*!
 * @abstract Invoked when the picker is closed.
 * @discussion The picker will be dismissed automatically after a contact or property is picked.
 */
- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    NSLog(@"User canceled picker");
}

/*!
 * @abstract Singular delegate methods.
 * @discussion These delegate methods will be invoked when the user selects a single contact or property.
 */
/*
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    NSLog(@"Selected: %@", [contact description]);
}
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    NSLog(@"Selected Property: %@", [contactProperty description]);
}
*/
#pragma mark -
@end
