# iOS9-Contacts.framework-AddressBook-Sample
AddressBook Sample

Ready
1. Add Contacts.framework
2. #import <Contacts/Contacts.h>

##1. Load Contact
```objective-c
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
```
##2. Load PickerView for CNContactPickerViewController
```objective-c
// Create a new contact view
CNContactViewController *contactController = [CNContactViewController viewControllerForContact:contact];
contactController.delegate = self;
contactController.allowsEditing = YES;
contactController.allowsActions = YES;

// Display the view
[self.navigationController pushViewController:contactController animated:YES];
```
##3. Add Contact
```objective-c
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
```
##4. Update Contact
```objective-c
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
```
##5. Delete Contact
```objective-c
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
```
##6. Detail Contact
```objective-c
-(void)loadContactView:(CNContact*)contact {
    // Create a new contact view
    CNContactViewController *contactController = [CNContactViewController viewControllerForContact:contact];
    contactController.delegate = self;
    contactController.allowsEditing = YES;
    contactController.allowsActions = YES;

    // Display the view
    [self.navigationController pushViewController:contactController animated:YES];
}
```


