/*
 Copyright (c) 2010 Adam Kirk, http://www.mysterioustrousers.com
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@interface FakeContactsAppDelegate : NSObject <UIApplicationDelegate, UITextFieldDelegate> {
    UIWindow *window;
	UIButton *addButton;
	UIButton *removeAllButton;
	UITextField *howMany;
	UITextField *whatGroup;
	UIActivityIndicatorView *spinner;
	
	
	NSArray *fnArray;
	NSArray *lnArray;
	
	NSArray *prArray;
	NSArray *suArray;
	NSArray *nnArray;
	NSArray *orArray;
	NSArray *jtArray;
	NSArray *dpArray;
	NSArray *wdArray;
	
	
	NSArray *snArray;
	NSArray *cities;
	NSArray *states;
	NSArray *dotComArray;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NSArray *fnArray;
@property (nonatomic, retain) NSArray *lnArray;
@property (nonatomic, retain) NSArray *prArray;
@property (nonatomic, retain) NSArray *suArray;
@property (nonatomic, retain) NSArray *nnArray;
@property (nonatomic, retain) NSArray *orArray;
@property (nonatomic, retain) NSArray *jtArray;
@property (nonatomic, retain) NSArray *dpArray;
@property (nonatomic, retain) NSArray *wdArray;
@property (nonatomic, retain) NSArray *snArray;
@property (nonatomic, retain) NSArray *cities;
@property (nonatomic, retain) NSArray *states;
@property (nonatomic, retain) NSArray *dotComArray;

- (IBAction)addButtonWasHit:(id)sender;
- (IBAction)removeButtonWasHit:(id)sender;


- (void)generateRandomContacts:(NSDictionary *)uiDict;
- (void)removeAllContactsFromGroup:(NSDictionary *)uiDict;
- (void)operationComplete;
- (void)updateOperationProgress:(NSNumber *)n;
- (void)errorDuringOperation:(NSString *)error;
- (void)handleError:(CFErrorRef)e;

- (NSDictionary *)generateRandomName;

- (NSString *)generateRandomPhone;
- (CFStringRef)generateRandomPhoneLabel;

- (NSString *)generateRandomIMFromFirstName:(NSString *)fn lastName:(NSString *)ln;
- (NSString *)generateRandomIMService;
- (CFStringRef)generateRandomIMLabel;
- (NSString *)generateRandomNote;

- (NSString *)generateRandomStreet;
- (NSString *)generateRandomCity;
- (NSString *)generateRandomState;
- (NSString *)generateRandomZipCode;

@end

