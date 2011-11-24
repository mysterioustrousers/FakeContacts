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

#import "FakeContactsAppDelegate.h"


@implementation FakeContactsAppDelegate

@synthesize window;
@synthesize fnArray;
@synthesize lnArray;
@synthesize prArray;
@synthesize suArray;
@synthesize nnArray;
@synthesize orArray;
@synthesize jtArray;
@synthesize dpArray;
@synthesize wdArray;
@synthesize snArray;
@synthesize cities;
@synthesize states;
@synthesize dotComArray;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	srand(time(NULL));
    
    [self.window makeKeyAndVisible];
	window.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	UILabel *howManyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 35, 280, 20)];
	howManyLabel.text = @"How many contacts to add";
	howManyLabel.backgroundColor = [UIColor clearColor];
	[window addSubview:howManyLabel];
	
	howMany = [[UITextField alloc] initWithFrame:CGRectMake(20, 60, 280, 40)];
	howMany.delegate = self;
	howMany.returnKeyType = UIReturnKeyDone;
	howMany.backgroundColor = [UIColor clearColor];
	howMany.font = [UIFont systemFontOfSize:28];
	howMany.borderStyle = UITextBorderStyleRoundedRect;
	[window addSubview:howMany];

	
	UILabel *toGroupLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 280, 20)];
	toGroupLabel.text = @"Group";
	toGroupLabel.backgroundColor = [UIColor clearColor];
	[window addSubview:toGroupLabel];
	
	whatGroup = [[UITextField alloc] initWithFrame:CGRectMake(20, 135, 280, 40)];
	whatGroup.delegate = self;
	whatGroup.returnKeyType = UIReturnKeyDone;
	whatGroup.backgroundColor = [UIColor clearColor];
	whatGroup.font = [UIFont systemFontOfSize:28];
	whatGroup.borderStyle = UITextBorderStyleRoundedRect;
	[window addSubview:whatGroup];
	
	
	
	addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[addButton setFrame:CGRectMake(20, 200, 280, 40)];
	[addButton setTitle:@"Add Contacts" forState:UIControlStateNormal];
	[addButton addTarget:self action:@selector(addButtonWasHit:) forControlEvents:UIControlEventTouchUpInside];
	[window addSubview:addButton];
	
	
	spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
	spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	[window addSubview:spinner];
	
	removeAllButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[removeAllButton setFrame:CGRectMake(20, 250, 280, 40)];
	[removeAllButton setTitle:@"Delete all from group" forState:UIControlStateNormal];
	[removeAllButton addTarget:self action:@selector(removeButtonWasHit:) forControlEvents:UIControlEventTouchUpInside];
	[window addSubview:removeAllButton];
	
	return YES;
}


- (IBAction)addButtonWasHit:(id)sender
{
	[addButton setTitle:@"" forState:UIControlStateNormal];
	addButton.userInteractionEnabled = NO;
	removeAllButton.userInteractionEnabled = NO;
	[spinner setFrame:CGRectMake(20, addButton.frame.origin.y + 10, 20, 20)];
	[spinner startAnimating];
	NSString *howManyToAdd = howMany.text ? howMany.text : @"";
	NSString *whatGroupToAddTo = whatGroup.text ? whatGroup.text : @"";
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:howManyToAdd, @"HowMany", whatGroupToAddTo, @"WhatGroup", nil];
	[NSThread detachNewThreadSelector:@selector(generateRandomContacts:) toTarget:self withObject:dict];
}

- (IBAction)removeButtonWasHit:(id)sender
{
	[removeAllButton setTitle:@"" forState:UIControlStateNormal];
	[spinner setFrame:CGRectMake(20, removeAllButton.frame.origin.y + 10, 20, 20)];
	[spinner startAnimating];
	NSString *howManyToAdd = howMany.text ? howMany.text : @"";
	NSString *whatGroupToAddTo = whatGroup.text ? whatGroup.text : @"";
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:howManyToAdd, @"HowMany", whatGroupToAddTo, @"WhatGroup", nil];
	[NSThread detachNewThreadSelector:@selector(removeAllContactsFromGroup:) toTarget:self withObject:dict];	
}

- (void)updateOperationProgress:(NSNumber *)n
{
	float i = [n floatValue];
	CGRect r = spinner.frame;
	r.origin.x = 20 + (260 * i);
	[spinner setFrame:r];
}

- (void)operationComplete
{	
	addButton.userInteractionEnabled = YES;
	removeAllButton.userInteractionEnabled = YES;
	[spinner stopAnimating];
	[addButton setTitle:@"Add Contacts" forState:UIControlStateNormal];
	[removeAllButton setTitle:@"Delete all from group" forState:UIControlStateNormal];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Operation completed successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}


- (void)errorDuringOperation:(NSString *)error
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}


- (void)handleError:(CFErrorRef)e
{
	if (!e) return;
	
	NSError *error = (NSError *)e;
	[self performSelectorOnMainThread:@selector(errorDuringOperation:) withObject:[error localizedDescription] waitUntilDone:YES];
}


- (void)generateRandomContacts:(NSDictionary *)uiDict
{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	
	int numberOfContactsToGenerate = [[uiDict objectForKey:@"HowMany"] intValue];
    CFErrorRef error = NULL;
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	
	
	
	
	
	
	
	
	
	
	// GET THE GROUP
	ABRecordRef groupToUse;
	if (![[uiDict objectForKey:@"WhatGroup"] isEqualToString:@""]) {
		BOOL groupFound = NO;
		
		CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
		int numberOfContacts = ABAddressBookGetGroupCount(addressBook);
		for (CFIndex i = 0; i < numberOfContacts; i++) {
			ABRecordRef group = CFArrayGetValueAtIndex(groups, i);
			NSString *groupName = (NSString *)ABRecordCopyCompositeName(group);
			
			if ([groupName isEqualToString:[uiDict objectForKey:@"WhatGroup"]]) {
				groupToUse = group;
				groupFound = YES;
				break;
			}
		}
		
		if (!groupFound) {
			groupToUse = ABGroupCreate();
			ABRecordSetValue(groupToUse, kABGroupNameProperty, [uiDict objectForKey:@"WhatGroup"], &error);
			[self handleError:error];
		}
		
		CFRelease(groups);
		
		
		ABAddressBookAddRecord (addressBook, groupToUse, &error);
		[self handleError:error];
		ABAddressBookSave(addressBook, &error);
		[self handleError:error];
	}
	
	
	
	
	// GENERATE THE CONTACTS
	CFMutableArrayRef contactsToAddToGroup = CFArrayCreateMutable(NULL, 0, NULL);
	for (int i = 0; i < numberOfContactsToGenerate; i++) {
		
		// update progress
		NSNumber *n = [NSNumber numberWithFloat:((float)i/(float)numberOfContactsToGenerate)];
		[self performSelectorOnMainThread:@selector(updateOperationProgress:) withObject:n waitUntilDone:NO];
		
		
		// Create the person
		ABRecordRef aRecord = ABPersonCreate();
		
		
		
		
		
		// Generate a random name
		NSDictionary *dict = [self generateRandomName];
		ABRecordSetValue(aRecord, kABPersonFirstNameProperty, [dict objectForKey:@"fn"], &error);
		ABRecordSetValue(aRecord, kABPersonLastNameProperty, [dict objectForKey:@"ln"], &error);
		
		if ([dict objectForKey:@"mn"])
			ABRecordSetValue(aRecord, kABPersonMiddleNameProperty, [dict objectForKey:@"mn"], &error);
		[self handleError:error];
		if ([dict objectForKey:@"pr"])
			ABRecordSetValue(aRecord, kABPersonPrefixProperty, [dict objectForKey:@"pr"], &error);
		[self handleError:error];
		if ([dict objectForKey:@"su"])
			ABRecordSetValue(aRecord, kABPersonSuffixProperty, [dict objectForKey:@"su"], &error);
		[self handleError:error];
		if ([dict objectForKey:@"nn"])
			ABRecordSetValue(aRecord, kABPersonNicknameProperty, [dict objectForKey:@"nn"], &error);
		[self handleError:error];
		if ([dict objectForKey:@"or"])
			ABRecordSetValue(aRecord, kABPersonOrganizationProperty, [dict objectForKey:@"or"], &error);
		[self handleError:error];
		if ([dict objectForKey:@"jt"])
			ABRecordSetValue(aRecord, kABPersonJobTitleProperty, [dict objectForKey:@"jt"], &error);
		[self handleError:error];
		if ([dict objectForKey:@"dp"])
			ABRecordSetValue(aRecord, kABPersonDepartmentProperty, [dict objectForKey:@"dp"], &error);
		[self handleError:error];
		if (rand() % 10 == 1)
			ABRecordSetValue(aRecord, kABPersonNoteProperty, [self generateRandomNote], &error);
		[self handleError:error];
		if (rand() % 5 == 1) {
			double seconds = -(rand() % (50*365*24*60*60));
			CFDateRef bDay = CFDateCreate(NULL, seconds);
			ABRecordSetValue(aRecord, kABPersonBirthdayProperty, bDay, &error);
			[self handleError:error];
		}
		
		

		// is an organization
		if (rand() % 20 == 1) {
			ABRecordSetValue(aRecord, kABPersonKindProperty, kABPersonKindOrganization, &error);
			[self handleError:error];
		} else {
			ABRecordSetValue(aRecord, kABPersonKindProperty, kABPersonKindPerson, &error);
			[self handleError:error];
		}

		
		

		
		
		// generate email addresses
		int howManyEmails = rand() % 4;
		ABMutableMultiValueRef emailMulti = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		for (int i = 0; i < howManyEmails; i++) {
			NSString *emailAddress	= [[self generateRandomIMFromFirstName:[dict objectForKey:@"fn"] lastName:[dict objectForKey:@"ln"]] lowercaseString];
			CFStringRef emailLabel	= [self generateRandomIMLabel];
			ABMultiValueAddValueAndLabel(emailMulti, emailAddress, emailLabel, NULL);
			ABRecordSetValue(aRecord, kABPersonEmailProperty, emailMulti, &error);
			[self handleError:error];
		}		
		CFRelease(emailMulti);	
		
		
		
		
		
		// generate phone numbers
		int howManyNumbers = rand() % 4;
		ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		for (int i = 0; i < howManyNumbers; i++) {
			NSString *phoneNumber	= [self generateRandomPhone];
			CFStringRef phoneLabel	= [self generateRandomPhoneLabel];
			ABMultiValueAddValueAndLabel(multi, phoneNumber, phoneLabel, NULL);
			ABRecordSetValue(aRecord, kABPersonPhoneProperty, multi, &error);
			[self handleError:error];
		}		
		CFRelease(multi);
		
		
		
		// generate instant message accounts
		int howManyAccounts = rand() % 4;
		ABMutableMultiValueRef im = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
		for (int i = 0; i < howManyAccounts; i++) {
			
			NSString *IMAccount		= [[self generateRandomIMFromFirstName:[dict objectForKey:@"fn"] lastName:[dict objectForKey:@"ln"]] lowercaseString];
			NSString *IMService		= [self generateRandomIMService];
			CFStringRef IMLabel		= [self generateRandomIMLabel];
			
			NSMutableDictionary *imDict = [[NSMutableDictionary alloc] init];
			[imDict setObject:IMService	forKey:(NSString*)kABPersonInstantMessageServiceKey];
			[imDict setObject:IMAccount	forKey:(NSString*)kABPersonInstantMessageUsernameKey];
			
			ABMultiValueAddValueAndLabel(im, imDict, IMLabel, NULL);
			ABRecordSetValue(aRecord, kABPersonInstantMessageProperty, im, &error);
			[self handleError:error];
		}		
		CFRelease(im);
		
		

		
		
		
		
		// Generate an address
		ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABDictionaryPropertyType);
		CFStringRef keys[5];
		CFStringRef values[5];
		keys[0] = kABPersonAddressStreetKey;
		keys[1] = kABPersonAddressCityKey;
		keys[2] = kABPersonAddressStateKey;
		keys[3] = kABPersonAddressZIPKey;
		keys[4] = kABPersonAddressCountryKey;
		values[0] = CFStringCreateWithCString(NULL, [[self generateRandomStreet] UTF8String], kCFStringEncodingMacRoman);
		values[1] = CFStringCreateWithCString(NULL, [[self generateRandomCity] UTF8String], kCFStringEncodingMacRoman);
		values[2] = CFStringCreateWithCString(NULL, [[self generateRandomState] UTF8String], kCFStringEncodingMacRoman);
		values[3] = CFStringCreateWithCString(NULL, [[self generateRandomZipCode] UTF8String], kCFStringEncodingMacRoman);
		values[4] = CFSTR("USA");		
		CFDictionaryRef aDict = CFDictionaryCreate( kCFAllocatorDefault, (void *)keys, (void *)values, 5, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		ABMultiValueAddValueAndLabel(address, aDict, kABHomeLabel, NULL);
		ABRecordSetValue(aRecord, kABPersonAddressProperty, address, &error);
		[self handleError:error];
		CFRelease(aDict);
		CFRelease(address);
		
		
		
		ABAddressBookAddRecord (addressBook, aRecord, &error);
		CFArrayAppendValue(contactsToAddToGroup, aRecord);
		[self handleError:error];	
		
		CFRelease(aRecord);
	}
	
	
	// add contacts to group
	if (![[uiDict objectForKey:@"WhatGroup"] isEqualToString:@""]) {
		ABAddressBookSave(addressBook, &error);
		[self handleError:error];
		
		int numContacts = CFArrayGetCount(contactsToAddToGroup);
		for (CFIndex i = 0; i < numContacts; i++) {
			
			ABRecordRef r = CFArrayGetValueAtIndex(contactsToAddToGroup, i);
			ABGroupAddMember(groupToUse, r, &error);
			[self handleError:error];
		}
	}

	
	
	ABAddressBookSave(addressBook, &error);
	[self handleError:error];
	
	
	
	CFRelease(addressBook);
	
	[self performSelectorOnMainThread:@selector(operationComplete) withObject:nil waitUntilDone:YES];
	[pool release];
}

- (void)removeAllContactsFromGroup:(NSDictionary *)uiDict
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	
    CFErrorRef error = NULL;
	ABAddressBookRef addressBook = ABAddressBookCreate();
	
	
	// GET THE GROUP
	ABRecordRef groupToUse = NULL;
	if (![[uiDict objectForKey:@"WhatGroup"] isEqualToString:@""]) {
		
		CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
		int numberOfGroups = ABAddressBookGetGroupCount(addressBook);
		for (CFIndex i = 0; i < numberOfGroups; i++) {
			ABRecordRef group = CFArrayGetValueAtIndex(groups, i);
			NSString *groupName = (NSString *)ABRecordCopyCompositeName(group);
			
			if ([[groupName lowercaseString] isEqualToString:[[uiDict objectForKey:@"WhatGroup"] lowercaseString]]) {
				groupToUse = group;
				break;
			}
		}
		
		CFRelease(groups);
	}
	
	
	// IF A VALID GROUP, REMOVE EVERY CONTACT IN THE GROUP, THEN THE GROUP
	if (groupToUse) {
		CFArrayRef people = ABGroupCopyArrayOfAllMembers(groupToUse);
		if (people) {
			CFIndex nPeople = CFArrayGetCount(people);
			
			for (int i = 0; i < nPeople; i++) {
				ABRecordRef aRecord = CFArrayGetValueAtIndex(people, i);
				ABAddressBookRemoveRecord(addressBook, aRecord, &error);
				[self handleError:error];
			}
		}
		
		ABAddressBookRemoveRecord(addressBook, groupToUse, &error);
		[self handleError:error];
		
		ABAddressBookSave(addressBook, &error);
		[self handleError:error];
	} else {
		[self performSelectorOnMainThread:@selector(errorDuringOperation:) withObject:@"Entered group not found, records not deleted" waitUntilDone:YES];
	}
	
	
	CFRelease(addressBook);
	
	[self performSelectorOnMainThread:@selector(operationComplete) withObject:nil waitUntilDone:YES];
	[pool release];
	
}






- (NSDictionary *)generateRandomName
{
	if (!fnArray) {
		NSString *firstNames = @"Jacob,Isabella,Ethan,Emma,Michael,Olivia,Alexander,Sophia,William,Ava,Joshua,Emily,Daniel,Madison,Jayden,Abigail,Noah,Chloe,Anthony,Mia,Christopher,Elizabeth,Aiden,Addison,Matthew,Alexis,David,Ella,Andrew,Samantha,Joseph,Natalie,Logan,Grace,James,Lily,Ryan,Alyssa,Benjamin,Ashley,Elijah,Sarah,Gabriel,Taylor,Christian,Hannah,Nathan,Brianna,Jackson,Hailey,John,Kaylee,Samuel,Lillian,Tyler,Leah,Dylan,Anna,Jonathan,Allison,Caleb,Victoria,Nicholas,Avery,Gavin,Gabriella,Mason,Nevaeh,Evan,Kayla,Landon,Sofia,Angel,Brooklyn,Brandon,Riley,Lucas,Evelyn,Isaac,Savannah,Isaiah,Aubrey,Jack,Alexa,Jose,Peyton,Kevin,Makayla,Jordan,Layla,Justin,Lauren,Brayden,Zoe,Luke,Sydney,Liam,Audrey,Carter,Julia,Owen,Jasmine,Connor,Arianna,Zachary,Claire,Aaron,Brooke,Robert,Amelia,Hunter,Morgan,Thomas,Destiny,Adrian,Bella,Cameron,Madelyn,Wyatt,Katherine,Chase,Kylie,Julian,Maya,Austin,Aaliyah,Charles,Madeline,Jeremiah,Sophie,Jason,Kimberly,Juan,Kaitlyn,Xavier,Charlotte,Luis,Alexandra,Sebastian,Jocelyn,Henry,Maria,Aidan,Valeria,Ian,Andrea,Adam,Trinity,Diego,Zoey,Nathaniel,Gianna,Brody,Mackenzie,Jesus,Jessica,Carlos,Camila,Tristan,Faith,Dominic,Autumn,Cole,Ariana,Alex,Genesis,Cooper,Payton,Ayden,Bailey,Carson,Angelina,Josiah,Caroline,Levi,Mariah,Blake,Katelyn,Eli,Rachel,Hayden,Vanessa,Bryan,Molly,Colton,Melanie,Brian,Serenity,Eric,Khloe,Parker,Gabrielle,Sean,Paige,Oliver,Mya,Miguel,Eva,Kyle,Isabelle,Jaden,Lucy,Kaden,Mary,Caden,Natalia,Max,Michelle,Antonio,Megan,Steven,Sara,Riley,Naomi,Kaleb,Ruby,Brady,Jennifer,Timothy,Isabel,Bryce,Sadie,Colin,Stephanie,Jesse,Jada,Richard,Kennedy,Joel,Gracie,Ashton,Rylee,Victor,Lilly,Micah,Lydia,Vincent,Nicole,Preston,Liliana,Alejandro,London,Nolan,Jenna,Marcus,Haley,Devin,Jordyn,Jake,Adriana,Jaxon,Stella,Damian,Jayla,Eduardo,Reagan,Patrick,Jade,Santiago,Amy,Oscar,Hayden,Giovanni,Rebecca,Maxwell,Kendall,Collin,Giselle,Cody,Laila,Ivan,Daniela,Edward,Melissa,Kayden,Valerie,Jeremy,Gabriela,Seth,Keira,Gage,Violet,Alan,Angela,Cayden,Katie,Grant,Reese,Ryder,Ellie,Emmanuel,Ashlyn,Peyton,Piper,Jonah,Kylee,Trevor,Marley,Hudson,Jordan,Bryson,Briana,Kenneth,Lyla,Omar,Daisy,Mark,Juliana,Jorge,Mckenzie,Conner,Annabelle,Nicolas,Jillian,Elias,Aliyah,Tanner,Kate,Paul,Leslie,Cristian,Brooklynn,Miles,Jacqueline,George,Izabella,Leonardo,Vivian,Asher,Diana,Jace,Amanda,Malachi,Shelby,Ricardo,Lila,Kaiden,Scarlett,Derek,Danielle,Jaiden,Adrianna,Grayson,Makenzie,Andres,Alana,Braxton,Harper,Jaylen,Summer,Wesley,Angel,Travis,Catherine,Fernando,Alivia,Shane,Mikayla,Maddox,Aniyah,Francisco,Miranda,Jude,Ana,Abraham,Marissa,Garrett,Cheyenne,Braden,Skylar,Alexis,Amber,Javier,Margaret,Lincoln,Jayden,Damien,Miley,Erick,Julianna,Peter,Delilah,Josue,Malia,Edwin,Eliana,Camden,Erin,Rylan,Elena,Manuel,Sienna,Bradley,Nora,Mario,Sierra,Cesar,Clara,Edgar,Alexandria,Stephen,Josephine,Sawyer,Amaya,Jaxson,Valentina,Hector,Breanna,Johnathan,Eden,Roman,Ariel,Landen,Alicia,Trenton,Tessa,Leo,Jazmin,Shawn,Kelsey,Israel,Elise,Brendan,Haylee,Jared,Mckenna,Kai,Sabrina,Donovan,Kathryn,Jeffrey,Carly,Braylon,Aurora,Spencer,Eleanor,Andy,Mariana,Andre,Alexia,Raymond,Lola,Ty,Cadence,Avery,Alondra,Sergio,Jazmine,Kingston,Melody,Tucker,Addyson,Ezekiel,Alison,Keegan,Kayleigh,Mateo,Karen,Drake,Christina,Calvin,Chelsea,Erik,Maggie,Griffin,Hope,Martin,Allie,Zane,Laura,Chance,Bianca,Troy,Jayda,Tyson,Leila,Dalton,Kendra,Zion,Kara,Marco,Delaney,Harrison,Ryleigh,Brennan,Makenna,Xander,Cassidy,Lukas,Brielle,Dominick,Camryn,Roberto,Nadia,Gregory,Alina,Maximus,Callie,Cash,Alaina,Dakota,Allyson,Easton,Penelope,Aden,Kaydence,Silas,Harmony,Malik,Caitlyn,Rafael,Fernanda,Johnny,Abby,Quinn,Alice,Ezra,Lexi,Caiden,Kelly,Skyler,Sasha,Graham,Kyla,Simon,Caylee,Axel,Leilani,Myles,Cecilia,Emanuel,Caitlin,Kyler,Esther,Pedro,Presley,Weston,Ashlynn,Emiliano,Mallory,Aaden,Kyra,Drew,Alejandra,Clayton,Fatima,Charlie,Teagan,Kameron,Heaven,Theodore,Dakota,Devon,Alayna,Corbin,Eliza,Marcos,Veronica,Amir,Tiffany,Ruben,Maddison,Luca,Crystal,Fabian,Jasmin,Colby,Aubree,Dawson,Kiara,Angelo,Macy,Grady,Camille,Anderson,Genevieve,Frank,Madilyn,Zander,Nina,Dante,Kamryn,Dillon,Angelica,Adan,Karina,Joaquin,Hazel,Corey,Karla,Derrick,Maliyah,Elliot,Heidi,Taylor,Esmeralda,Brock,Guadalupe,Amari,Kira,Armando,Joanna,Trent,Carmen,Tristen,Cora,Julio,Aniya,Dean,Lucia,Lane,Daniella,Enrique,Courtney,Declan,Jamie,Bennett,Kyleigh,Braydon,Miriam,Emilio,Ximena,Allen,Emely,Raul,Fiona,Trey,Josie,Julius,Willow,Gael,Katelynn,Danny,Iris,Dustin,Paisley,Jameson,Juliet,Everett,Ivy,Randy,Emerson,Gerardo,Luna,Cohen,Selena,Cade,Anastasia,Jakob,Phoebe,Judah,Lindsey,Paxton,Cassandra,Abel,Savanna,Jaime,Analia,Payton,Kailey,Keith,Madeleine,Emmett,Angie,Holden,Kaelyn,Darius,Janiyah,Lorenzo,Joselyn,Rowan,Emery,Jasper,Georgia,Dallas,Madalyn,Felix,Rylie,Phillip,Monica,Ronald,Kiera,Scott,Bethany,Finn,Brynn,Pablo,Norah,Jayson,Dulce,Cruz,Isla,Greyson,Jaelyn,Reid,Erica,Leland,Julissa,Elliott,Kaylie,Brayan,Adeline,Brenden,Rose,Ryker,April,Louis,Julie,Saul,Audrina,Ismael,Cameron,Jayce,Ruth,Chris,Tatiana,Mitchell,Madisyn,Nehemiah,Kiley,Jalen,Hadley,Gustavo,Cynthia,Dennis,Anya,Donald,Rebekah,Zackary,Ciara,Casey,Lilah,Phoenix,Talia,Dane,Londyn,Jimmy,Adalyn,Colt,Michaela,Jerry,Nayeli,Ali,Kaylin,Rodrigo,Lia,Braeden,Erika,Quentin,Madelynn,Arthur,Lilliana,Tony,Raegan,Arturo,Baylee,Jonas,Danica,Keaton,Holly,Esteban,Paola,Mathew,Annie,Mauricio,Lizbeth,Desmond,Jazlyn,Larry,Janiya,Alberto,Jane,Walter,Carolina,Moises,Rihanna,Rocco,Helen,Jett,Danna,Brett,Jimena,Colten,Nyla,Curtis,Serena,Darren,Shayla,Philip,Tatum,Beau,Sage,Landyn,Ayla,Izaiah,Itzel,Zayden,Sarai,Gunner,Emilia,Byron,Marlee,Uriel,Kadence,Marshall,Brenda,Albert,Janelle,Alec,Adelyn,Jamari,Madyson,Kade,Natasha,Bryant,Lyric,Hugo,Kimora,Orlando,Imani,Romeo,Macie,Braylen,Paris,Beckett,Amiyah,Jay,Estrella,Marvin,Priscilla,Ramon,Annika,Ricky,Ainsley,Jaydon,Lena,Yahir,Skyler,Kobe,Nataly,Issac,Dayana,Reed,Hayley,Alfredo,Harley,Salvador,Bridget,Eddie,Brylee,Jax,Lillie,Davis,Melany,Justice,Kinsley,Kellen,Evangeline,Mohamed,Athena,Reece,Lacey,Zachariah,Addisyn,August,Viviana,Russell,Noelle,Kristopher,Cali,Talon,Lilian,Emerson,Aubrie,Lance,Emilee,Titus,Juliette,Lawrence,Hanna,Maurice,Kayden,Tate,Elle,Nikolas,Kassidy,Jacoby,Brenna,Leon,Kailyn,Mekhi,Desiree,Nickolas,Arabella,River,Lana,Karson,Kenzie,Camron,Denise,Milo,Kinley,Gary,Jadyn,Joe,Logan,Matteo,Alissa,Nasir,Aileen,Brycen,Melina,Morgan,Abbigail,Solomon,Anahi,Walker,Celeste,Maximiliano,Brittany,Ernesto,Annabella,King,Elaina,Warren,Miracle,Douglas,Mila,Bruce,Kennedi,Davion,Lauryn,Kolton,Cara,Sam,Danika,Chandler,Nancy,Leonel,Francesca,Porter,Anaya,Nathanael,Marisol,Alijah,Alessandra,Jaylin,Johanna,Reese,Alanna,Johan,Daphne,Kelvin,Asia,Waylon,Yaretzi,Maximilian,Yasmin,Ahmad,Amira,Pierce,Alyson,Isaias,Claudia,Terrance,Braelyn,Braiden,Amari,Cullen,Nathalie,Kason,Quinn,Jamarion,Jaylynn,Brooks,Meredith,Noel,Nia,Brodie,Jaliyah,Deandre,Skye,Khalil,Isabela,Abram,Rosa,Javon,Meghan,Rodney,Gloria,Roger,Rowan,Skylar,Journey,Shaun,Lexie,Micheal,Kali,Cory,Zariah,Guillermo,Diamond,Kane,Parker,Jonathon,Lesly,Moses,Saniyah,Jadon,Wendy,Tobias,Whitney,Adriel,Aylin,Chad,Mikaela,Dorian,Kaylynn,Kristian,Samara,Melvin,Hailee,Conor,Yareli,Kale,Aria,Keagan,Kamila,Cristopher,Elliana,Kieran,Sandra,London,Amya,Bentley,Perla,Damon,Aleah,Cyrus,Jaida,Dayton,Liberty,Nelson,Lilyana,Carl,Kristina,Quincy,Lindsay,Yandel,Natalee,Ari,Finley,Chace,Joy,Quinton,Casey,Orion,Sidney,Franklin,Dana,Rohan,Cindy,Kamari,Vivienne,Trace,Anika,Isiah,Kristen,Julien,Hallie,Frederick,Myla,Kendrick,Laney,Dominik,Jaden,Wilson,Jaelynn,Boston,Madalynn,Cason,Patricia,Gianni,Sherlyn,Maverick,Sylvia,Noe,Anne,Dexter,Saniya,Jamison,Janessa,Demetrius,Kiana,Finnegan,Skyla,Gideon,Jayleen,Triston,Madilynn,Gunnar,Camilla,Armani,Halle,Asa,Linda,Terry,Elisabeth,Jeffery,Tori,Ariel,Dylan,Allan,Justice,Roy,Heather,Aldo,America,Marc,Anabelle,Tommy,Arielle,Ezequiel,Jaiden,Felipe,Bailee,Ibrahim,Kathleen,Jermaine,Shannon,Ronan,Haven,Barrett,Adelaide,Karter,Gemma,Ryland,Kassandra,Alvin,Lucille,Brendon,Marie,Harley,Gracelyn,Jessie,Ada,Tomas,Brisa,Madden,Helena,Will,Aryanna,Rhys,Kaitlin,Terrence,Taryn,Bobby,Amani,Brennen,Aleena,Giovani,Ryan,Terrell,Eve,Remington,Liana,Ahmed,Marilyn,Nico,Gwendolyn,Xzavier,Amara,Jefferson,Haleigh,Tristin,Olive,Billy,Aspen,Branden,Gia,Kamden,Maeve,Enzo,Maia,Jon,Maleah,Uriah,Myah,Kian,Kaia,Kody,Yesenia,Kole,Catalina,Reginald,Kaliyah,Ulises,Cheyanne,Kendall,Deanna,Omari,Lorelei,Malcolm,Clarissa,Muhammad,Giana,Lucian,Shiloh,Memphis,Zoie,Javion,Alisson,Mohammad,Aiyana,Ace,Bryanna,Atticus,Tiana,Steve,Scarlet,Alonzo,Jaylee,Jamal,Marina,Rene,Rachael,Marquis,Isis,Joey,Allisson,Moshe,Charlie,Kenny,Virginia,Rashad,Jaylin,Urijah,Jaycee,Kasen,Simone,Bradyn,Briley,Aydan,Amiya,Cannon,Christine,Wade,Ashlee,Gerald,Siena,Willie,Irene,Neil,Abril,Toby,Kenya,Brent,Destinee,Jase,Julianne,Jaylon,Kaleigh,Kellan,Paulina,Malakai,Ayanna,Raphael,Kaitlynn,Jadiel,Elisa,Jaeden,Raven,Blaine,Adrienne,Lawson,Carlee,Zachery,Arely,Davin,Jaidyn,Johnathon,Raquel,Markus,Sariah,Mohammed,Mercedes,Jairo,Haylie,Draven,Kailee,Aydin,Nylah,Alfonso,Tabitha,Teagan,Annalise,Alessandro,Kirsten,Harry,Krystal,Amare,Elyse,Sullivan,Jaylene,Ben,Aliya,Layne,Teresa,Luciano,Taliyah,Marlon,Barbara,Aron,Maci,Rhett,Ansley,Alonso,Kenley,Kolby,Dahlia,Lee,Jazlynn,Giovanny,June,Messiah,Mariam,Ronnie,Gisselle,Craig,Carla,Damion,Bristol,Darian,Jakayla,Cale,Mckayla,Jamie,Leighton,Raiden,Jaslene,Tripp,Lea,Ray,Adalynn,Nash,Jolie,Semaj,Karlee,Makai,Amelie,Stanley,Brynlee,Giancarlo,Joslyn,Trevon,Mariyah,Archer,Elsie,Francis,Paityn,Jerome,Kaylen,Deven,Martha,Tyrone,Luciana,Vicente,Maritza,Deacon,Sonia,Heath,Lisa,Santino,Noemi,Layton,Tara,Osvaldo,Carolyn,Rogelio,Adyson,Prince,Elsa,Deshawn,Greta,Jovani,Mollie,Rolando,Cherish,Adrien,Jessie,Camren,Kaya,Dwayne,Lainey,Tristian,Jaqueline,Gavyn,Macey,Sincere,Ellen,Alexzander,Miah,Cedric,Selah,Jorden,Kaylyn,Zechariah,Reyna,Hamza,Giuliana,Knox,Marisa,Davian,Cristina,Clark,Jenny,Elisha,Leanna,Ramiro,Paloma,Zackery,Averie,Jordyn,Cailyn,Kylan,Regina,Matias,Alena,Junior,Emilie,Kaeden,Tania,Gilberto,Carlie,Gauge,Clare,Kash,Iliana,Damarion,Phoenix,Ellis,Rosemary,Finley,Annabel,Quintin,Evie,Aidyn,Regan,Lewis,Tamia,Konner,Charlee,Leonard,Campbell,Rudy,Janae,Arjun,Jaylah,Frankie,Jazmyn,Jamir,Sanaa,Duncan,Zion,Darrell,Amina,Harper,Carley,Maxim,Emmalee,Valentin,Chaya,Darwin,Leyla,Kareem,Cecelia,Korbin,Lilianna,Soren,Marlene,Jasiah,Zaniyah,Samir,Aisha,Daxton,Britney,Eugene,Kallie,Brice,Angelique,Keenan,Natalya,Conrad,Patience,Misael,Yazmin,Randall,Alani,Franco,Kenna,Killian,Luz,Rex,Araceli,Rodolfo,Aryana,Roland,Giada,Jamar,Malaya,Rory,Celia,Aditya,Corinne,Davon,Mara,Wayne,Larissa,Jovanni,Mckinley,Sage,Moriah,Yusuf,Matilda,Zaiden,Susan,Jagger,Abbie,Matthias,Alisha,Nikolai,Armani,Alvaro,Elaine,Valentino,Karma,Van,Judith,Zain,Milagros,Zayne,Alia,Aryan,Kiersten,Dominique,Sharon,Vance,Shaniya,Donte,Milan,Luka,Zara,Lamar,Aliza,Camryn,Brinley,Emery,Lailah,Freddy,Lorelai,Irvin,Renee,Bo,Felicity,Justus,Precious,Adonis,Keyla,Devan,Kierra,Mathias,Paula,Maximo,Yoselin,Yosef,Anabella,Dax,Ayana,Marley,Kaiya,Darnell,Salma,Dillan,Azul,Efrain,Kendal,Antoine,Monserrat,Rayan,Ryann,Rylee,Chanel,Augustus,Giovanna,Jair,Ingrid,Jaydin,Kasey,Tyree,Maliah,Tyrell,Zaria,Agustin,Frances,Kymani,Jamya,Jadyn,Libby,Gilbert,Dayanara,Hassan,Marianna,Jaidyn,Mira,Ean,Shyla,Gaige,Ally,Niko,Eileen,Ronin,Janet,Coleman,Shyanne,Seamus,Yaritza,Aarav,Deborah,Branson,Katrina,Deangelo,Nathaly,Isai,Yuliana,Blaze,Micah,Cael,Aimee,Demarcus,Alma,Talan,Ireland,Vaughn,Leia,Ayaan,Akira,Winston,Amirah,Jeramiah,Stacy,Derick,Belinda,Harold,Isabell,Alfred,Lylah,Deon,Tess,Mike,Chana,Carmelo,Jayde,Jensen,Calleigh,Izayah,Hana,Kadyn,Raina,Abdullah,Karissa,Ignacio,Kourtney,Yair,Angeline,Aedan,Janice,Kadin,Raelynn,Kamron,Rosalie,Fisher,Saige,Marcelo,Shania,Broderick,Adelynn,Cristofer,India,Santos,Pamela,Sidney,Edith,Sylas,Mayra,Beckham,Jacey,Ernest,Kelsie,Yadiel,Laylah,Kael,Marely,Kayson,Tianna,Case,Mylee,Elian,Aracely,Jaxton,Jaylyn,Jaydan,Rubi,Sonny,Taniyah,Elvis,Carissa,Tyrese,Rylan,Nigel,Beatrice,Bruno,Alyvia,Nikhil,Mina,Zavier,Ariella,Kolten,Lillianna,Ishaan,Meadow,Addison,Yadira,Bridger,Hayleigh,Devyn,Millie,Alden,Livia,Arnav,Carina,Callum,Damaris,Jaxen,Elianna,Leandro,Evelin,Adolfo,Jocelynn,Dilan,Bria,Jabari,Charity,Keon,Belen,Hezekiah,Cristal,Krish,Emelia,Lyric,Rayna,Quinten,Taraji,Samson,Abbey,Malaki,Demi,Chaim,Diya,Darien,Ember,Darryl,Jaylen,Keshawn,Payten,Zaire,Karsyn,Marcel,Rayne,Ethen,Marlie,Salvatore,Maryjane,Todd,Jordin,Brenton,Vera,Dangelo,Alexus,Reuben,Destiney,Abdiel,Mattie,Bronson,Sloane,Camilo,Taniya,Dario,Evelynn,Roderick,Savanah,Sterling,Shaylee,Eden,Harlow,Humberto,Alaya,Rey,Jacquelyn,Casen,Caydence,Pranav,Myra,Brogan,Princess,Cortez,Tamara,Dashawn,Xiomara,Demarion,Charlize,Haiden,Sarahi,Kyson,Abagail,Marquise,Aliana,Dale,Emmy,Rigoberto,Janiah,Antwan,Lilia,Jarrett,Eloise,Ross,Yamilet,Braedon,Avah,Jordon,Averi,Kenyon,Kylah,Clinton,Raelyn,Damari,Roselyn,Jovan,Caleigh,Elmer,Karly,Jayvion,Ann,Konnor,Frida,Trystan,Kayley,Vincenzo,Unique,Yael,Yasmine,Fletcher,Jewel,Jaquan,Kamari,Octavio,Keely,Westin,Lara,Houston,Dixie,Isaak,Lorena,Slade,Rory,Zack,Ali,Landin,Hadassah,Royce,Joyce,Bailey,Alisa,Koen,Cayla,Jaron,Rebeca,German,Taya,Howard,Maryam,Kamryn,Nola,Keyon,Theresa,Reynaldo,Aiyanna,Hayes,Charley,Jean,Makena,Lennon,Tia,Ralph,Ashleigh,Garrison,Ashly,Jakobe,Azaria,Jamarcus,Kaelynn,Jovanny,Kamya,Makhi,Lina,Maxx,Maribel,Carsen,Neveah,Clay,River,Dereon,Sanai,Nathen,Dominique,Reagan,Lizeth,Karl,Cassie,Kasey,Ivanna,Savion,Esperanza,Jamel,Thalia,Anton,Ayleen,Geovanni,Devyn,Jaycob,Leona,Josh,Riya,Juelz,Abigale,Kalel,Dalia,Jerimiah,Jaslyn,Mack,Mariela,Remy,Marleigh,Blaise,Miya,Carlo,Reina,Deegan,Deja,Denzel,Heidy,Odin,Kayleen,Leonidas,Magdalena,Maddux,Stephany,Antony,Tiara,Stefan,Azariah,Zavion,Karley,Cain,Reece,Hugh,Karlie,Nick,Sydnee,Zaid,Tanya,Chaz,Alannah,Fredrick,Amiah,Ronaldo,Cambria,Stone,Samiyah,Trevin,Valery,Tyshawn,Gretchen,Amos,Karli,Cassius,Kloe,Eliezer,Lilyanna,Mustafa,Mireya";
		NSString *lastNames = @"SMITH,JOHNSON,WILLIAMS,JONES,BROWN,DAVIS,MILLER,WILSON,MOORE,TAYLOR,ANDERSON,THOMAS,JACKSON,WHITE,HARRIS,MARTIN,THOMPSON,GARCIA,MARTINEZ,ROBINSON,CLARK,RODRIGUEZ,LEWIS,LEE,WALKER,HALL,ALLEN,YOUNG,HERNANDEZ,KING,WRIGHT,LOPEZ,HILL,SCOTT,GREEN,ADAMS,BAKER,GONZALEZ,NELSON,CARTER,MITCHELL,PEREZ,ROBERTS,TURNER,PHILLIPS,CAMPBELL,PARKER,EVANS,EDWARDS,COLLINS,STEWART,SANCHEZ,MORRIS,ROGERS,REED,COOK,MORGAN,BELL,MURPHY,BAILEY,RIVERA,COOPER,RICHARDSON,COX,HOWARD,WARD,TORRES,PETERSON,GRAY,RAMIREZ,JAMES,WATSON,BROOKS,KELLY,SANDERS,PRICE,BENNETT,WOOD,BARNES,ROSS,HENDERSON,COLEMAN,JENKINS,PERRY,POWELL,LONG,PATTERSON,HUGHES,FLORES,WASHINGTON,BUTLER,SIMMONS,FOSTER,GONZALES,BRYANT,ALEXANDER,RUSSELL,GRIFFIN,DIAZ,HAYES,MYERS,FORD,HAMILTON,GRAHAM,SULLIVAN,WALLACE,WOODS,COLE,WEST,JORDAN,OWENS,REYNOLDS,FISHER,ELLIS,HARRISON,GIBSON,MCDONALD,CRUZ,MARSHALL,ORTIZ,GOMEZ,MURRAY,FREEMAN,WELLS,WEBB,SIMPSON,STEVENS,TUCKER,PORTER,HUNTER,HICKS,CRAWFORD,HENRY,BOYD,MASON,MORALES,KENNEDY,WARREN,DIXON,RAMOS,REYES,BURNS,GORDON,SHAW,HOLMES,RICE,ROBERTSON,HUNT,BLACK,DANIELS,PALMER,MILLS,NICHOLS,GRANT,KNIGHT,FERGUSON,ROSE,STONE,HAWKINS,DUNN,PERKINS,HUDSON,SPENCER,GARDNER,STEPHENS,PAYNE,PIERCE,BERRY,MATTHEWS,ARNOLD,WAGNER,WILLIS,RAY,WATKINS,OLSON,CARROLL,DUNCAN,SNYDER,HART,CUNNINGHAM,BRADLEY,LANE,ANDREWS,RUIZ,HARPER,FOX,RILEY,ARMSTRONG,CARPENTER,WEAVER,GREENE,LAWRENCE,ELLIOTT,CHAVEZ,SIMS,AUSTIN,PETERS,KELLEY,FRANKLIN,LAWSON,FIELDS,GUTIERREZ,RYAN,SCHMIDT,CARR,VASQUEZ,CASTILLO,WHEELER,CHAPMAN,OLIVER,MONTGOMERY,RICHARDS,WILLIAMSON,JOHNSTON,BANKS,MEYER,BISHOP,MCCOY,HOWELL,ALVAREZ,MORRISON,HANSEN,FERNANDEZ,GARZA,HARVEY,LITTLE,BURTON,STANLEY,NGUYEN,GEORGE,JACOBS,REID,KIM,FULLER,LYNCH,DEAN,GILBERT,GARRETT,ROMERO,WELCH,LARSON,FRAZIER,BURKE,HANSON,DAY,MENDOZA,MORENO,BOWMAN,MEDINA,FOWLER,BREWER,HOFFMAN,CARLSON,SILVA,PEARSON,HOLLAND,DOUGLAS,FLEMING,JENSEN,VARGAS,BYRD,DAVIDSON,HOPKINS,MAY,TERRY,HERRERA,WADE,SOTO,WALTERS,CURTIS,NEAL,CALDWELL,LOWE,JENNINGS,BARNETT,GRAVES,JIMENEZ,HORTON,SHELTON,BARRETT,OBRIEN,CASTRO,SUTTON,GREGORY,MCKINNEY,LUCAS,MILES,CRAIG,RODRIQUEZ,CHAMBERS,HOLT,LAMBERT,FLETCHER,WATTS,BATES,HALE,RHODES,PENA,BECK,NEWMAN,HAYNES,MCDANIEL,MENDEZ,BUSH,VAUGHN,PARKS,DAWSON,SANTIAGO,NORRIS,HARDY,LOVE,STEELE,CURRY,POWERS,SCHULTZ,BARKER,GUZMAN,PAGE,MUNOZ,BALL,KELLER,CHANDLER,WEBER,LEONARD,WALSH,LYONS,RAMSEY,WOLFE,SCHNEIDER,MULLINS,BENSON,SHARP,BOWEN,DANIEL,BARBER,CUMMINGS,HINES,BALDWIN,GRIFFITH,VALDEZ,HUBBARD,SALAZAR,REEVES,WARNER,STEVENSON,BURGESS,SANTOS,TATE,CROSS,GARNER,MANN,MACK,MOSS,THORNTON,DENNIS,MCGEE,FARMER,DELGADO,AGUILAR,VEGA,GLOVER,MANNING,COHEN,HARMON,RODGERS,ROBBINS,NEWTON,TODD,BLAIR,HIGGINS,INGRAM,REESE,CANNON,STRICKLAND,TOWNSEND,POTTER,GOODWIN,WALTON,ROWE,HAMPTON,ORTEGA,PATTON,SWANSON,JOSEPH,FRANCIS,GOODMAN,MALDONADO,YATES,BECKER,ERICKSON,HODGES,RIOS,CONNER,ADKINS,WEBSTER,NORMAN,MALONE,HAMMOND,FLOWERS,COBB,MOODY,QUINN,BLAKE,MAXWELL,POPE,FLOYD,OSBORNE,PAUL,MCCARTHY,GUERRERO,LINDSEY,ESTRADA,SANDOVAL,GIBBS,TYLER,GROSS,FITZGERALD,STOKES,DOYLE,SHERMAN,SAUNDERS,WISE,COLON,GILL,ALVARADO,GREER,PADILLA,SIMON,WATERS,NUNEZ,BALLARD,SCHWARTZ,MCBRIDE,HOUSTON,CHRISTENSEN,KLEIN,PRATT,BRIGGS,PARSONS,MCLAUGHLIN,ZIMMERMAN,FRENCH,BUCHANAN,MORAN,COPELAND,ROY,PITTMAN,BRADY,MCCORMICK,HOLLOWAY,BROCK,POOLE,FRANK,LOGAN,OWEN,BASS,MARSH,DRAKE,WONG,JEFFERSON,PARK,MORTON,ABBOTT,SPARKS,PATRICK,NORTON,HUFF,CLAYTON,MASSEY,LLOYD,FIGUEROA,CARSON,BOWERS,ROBERSON,BARTON,TRAN,LAMB,HARRINGTON,CASEY,BOONE,CORTEZ,CLARKE,MATHIS,SINGLETON,WILKINS,CAIN,BRYAN,UNDERWOOD,HOGAN,MCKENZIE,COLLIER,LUNA,PHELPS,MCGUIRE,ALLISON,BRIDGES,WILKERSON,NASH,SUMMERS,ATKINS,WILCOX,PITTS,CONLEY,MARQUEZ,BURNETT,RICHARD,COCHRAN,CHASE,DAVENPORT,HOOD,GATES,CLAY,AYALA,SAWYER,ROMAN,VAZQUEZ,DICKERSON,HODGE,ACOSTA,FLYNN,ESPINOZA,NICHOLSON,MONROE,WOLF,MORROW,KIRK,RANDALL,ANTHONY,WHITAKER,OCONNOR,SKINNER,WARE,MOLINA,KIRBY,HUFFMAN,BRADFORD,CHARLES,GILMORE,DOMINGUEZ,ONEAL,BRUCE,LANG,COMBS,KRAMER,HEATH,HANCOCK,GALLAGHER,GAINES,SHAFFER,SHORT,WIGGINS,MATHEWS,MCCLAIN,FISCHER,WALL,SMALL,MELTON,HENSLEY,BOND,DYER,CAMERON,GRIMES,CONTRERAS,CHRISTIAN,WYATT,BAXTER,SNOW,MOSLEY,SHEPHERD,LARSEN,HOOVER,BEASLEY,GLENN,PETERSEN,WHITEHEAD,MEYERS,KEITH,GARRISON,VINCENT,SHIELDS,HORN,SAVAGE,OLSEN,SCHROEDER,HARTMAN,WOODARD,MUELLER,KEMP,DELEON,BOOTH,PATEL,CALHOUN,WILEY,EATON,CLINE,NAVARRO,HARRELL,LESTER,HUMPHREY,PARRISH,DURAN,HUTCHINSON,HESS,DORSEY,BULLOCK,ROBLES,BEARD,DALTON,AVILA,VANCE,RICH,BLACKWELL,YORK,JOHNS,BLANKENSHIP,TREVINO,SALINAS,CAMPOS,PRUITT,MOSES,CALLAHAN,GOLDEN,MONTOYA,HARDIN,GUERRA,MCDOWELL,CAREY,STAFFORD,GALLEGOS,HENSON,WILKINSON,BOOKER,MERRITT,MIRANDA,ATKINSON,ORR,DECKER,HOBBS,PRESTON,TANNER,KNOX,PACHECO,STEPHENSON,GLASS,ROJAS,SERRANO,MARKS,HICKMAN,ENGLISH,SWEENEY,STRONG,PRINCE,MCCLURE,CONWAY,WALTER,ROTH,MAYNARD,FARRELL,LOWERY,HURST,NIXON,WEISS,TRUJILLO,ELLISON,SLOAN,JUAREZ,WINTERS,MCLEAN,RANDOLPH,LEON,BOYER,VILLARREAL,MCCALL,GENTRY,CARRILLO,KENT,AYERS,LARA,SHANNON,SEXTON,PACE,HULL,LEBLANC,BROWNING,VELASQUEZ,LEACH,CHANG,HOUSE,SELLERS,HERRING,NOBLE,FOLEY,BARTLETT,MERCADO,LANDRY,DURHAM,WALLS,BARR,MCKEE,BAUER,RIVERS,EVERETT,BRADSHAW,PUGH,VELEZ,RUSH,ESTES,DODSON,MORSE,SHEPPARD,WEEKS,CAMACHO,BEAN,BARRON,LIVINGSTON,MIDDLETON,SPEARS,BRANCH,BLEVINS,CHEN,KERR,MCCONNELL,HATFIELD,HARDING,ASHLEY,SOLIS,HERMAN,FROST,GILES,BLACKBURN,WILLIAM,PENNINGTON,WOODWARD,FINLEY,MCINTOSH,KOCH,BEST,SOLOMON,MCCULLOUGH,DUDLEY,NOLAN,BLANCHARD,RIVAS,BRENNAN,MEJIA,KANE,BENTON,JOYCE,BUCKLEY,HALEY,VALENTINE,MADDOX,RUSSO,MCKNIGHT,BUCK,MOON,MCMILLAN,CROSBY,BERG,DOTSON,MAYS,ROACH,CHURCH,CHAN,RICHMOND,MEADOWS,FAULKNER,ONEILL,KNAPP,KLINE,BARRY,OCHOA,JACOBSON,GAY,AVERY,HENDRICKS,HORNE,SHEPARD,HEBERT,CHERRY,CARDENAS,MCINTYRE,WHITNEY,WALLER,HOLMAN,DONALDSON,CANTU,TERRELL,MORIN,GILLESPIE,FUENTES,TILLMAN,SANFORD,BENTLEY,PECK,KEY,SALAS,ROLLINS,GAMBLE,DICKSON,BATTLE,SANTANA,CABRERA,CERVANTES,HOWE,HINTON,HURLEY,SPENCE,ZAMORA,YANG,MCNEIL,SUAREZ,CASE,PETTY,GOULD,MCFARLAND,SAMPSON,CARVER,BRAY,ROSARIO,MACDONALD,STOUT,HESTER,MELENDEZ,DILLON,FARLEY,HOPPER,GALLOWAY,POTTS,BERNARD,JOYNER,STEIN,AGUIRRE,OSBORN,MERCER,BENDER,FRANCO,ROWLAND,SYKES,BENJAMIN,TRAVIS,PICKETT,CRANE,SEARS,MAYO,DUNLAP,HAYDEN,WILDER,MCKAY,COFFEY,MCCARTY,EWING,COOLEY,VAUGHAN,BONNER,COTTON,HOLDER,STARK,FERRELL,CANTRELL,FULTON,LYNN,LOTT,CALDERON,ROSA,POLLARD,HOOPER,BURCH,MULLEN,FRY,RIDDLE,LEVY,DAVID,DUKE,ODONNELL,GUY,MICHAEL,BRITT,FREDERICK,DAUGHERTY,BERGER,DILLARD,ALSTON,JARVIS,FRYE,RIGGS,CHANEY,ODOM,DUFFY,FITZPATRICK,VALENZUELA,MERRILL,MAYER,ALFORD,MCPHERSON,ACEVEDO,DONOVAN,BARRERA,ALBERT,COTE,REILLY,COMPTON,RAYMOND,MOONEY,MCGOWAN,CRAFT,CLEVELAND,CLEMONS,WYNN,NIELSEN,BAIRD,STANTON,SNIDER,ROSALES,BRIGHT,WITT,STUART,HAYS,HOLDEN,RUTLEDGE,KINNEY,CLEMENTS,CASTANEDA,SLATER,HAHN,EMERSON,CONRAD,BURKS,DELANEY,PATE,LANCASTER,SWEET,JUSTICE,TYSON,SHARPE,WHITFIELD,TALLEY,MACIAS,IRWIN,BURRIS,RATLIFF,MCCRAY,MADDEN,KAUFMAN,BEACH,GOFF,CASH,BOLTON,MCFADDEN,LEVINE,GOOD,BYERS,KIRKLAND,KIDD,WORKMAN,CARNEY,DALE,MCLEOD,HOLCOMB,ENGLAND,FINCH,HEAD,BURT,HENDRIX,SOSA,HANEY,FRANKS,SARGENT,NIEVES,DOWNS,RASMUSSEN,BIRD,HEWITT,LINDSAY,LE,FOREMAN,VALENCIA,ONEIL,DELACRUZ,VINSON,DEJESUS,HYDE,FORBES,GILLIAM,GUTHRIE,WOOTEN,HUBER,BARLOW,BOYLE,MCMAHON,BUCKNER,ROCHA,PUCKETT,LANGLEY,KNOWLES,COOKE,VELAZQUEZ,WHITLEY,NOEL,VANG";
		NSString *prefixes = @"Mr.,Mrs.,Ms.,Dr.";
		NSString *suffixes = @"Jr.,Sr.,PhD,III";
		NSString *nicknames = @"Mom,Dad,Nanna,Mommy,Daddy,Grandma,Grandpa,Grandmother,Grandfather";
		NSString *organizations = @"WalMart Stores,Exxon Mobil,Chevron,General Motors,ConocoPhillips,General Electric,Ford Motor,Citigroup,Bank of America Corp,AT&amp;T,Berkshire Hathaway,JP Morgan Chase &amp; Co,American International Group,HewlettPackard,International Business Machines,Valero Energy,Verizon Communications,McKesson,Cardinal Health,Goldman Sachs Group,Morgan Stanley,Home Depot,Procter &amp; Gamble,CVS Caremark,UnitedHealth Group,Kroger,Boeing,AmerisourceBergen,Costco Wholesale,Merrill Lynch,Target,State Farm Insurance Cos,WellPoint,Dell,Johnson &amp; Johnson,Marathon Oil,Lehman Brothers Holdings,Wachovia Corp,United Technologies,Walgreen,Wells Fargo,Dow Chemical,MetLife,Microsoft,Sears Holdings,United Parcel Service,Pfizer,Lowe's,Time Warner,Caterpillar,Medco Health Solutions,Archer Daniels Midland,Fannie Mae,Freddie Mac,Safeway,Sunoco,Lockheed Martin,Sprint Nextel,PepsiCo,Intel,Altria Group,Supervalu,Kraft Foods,Allstate,Motorola,Best Buy,Walt Disney,FedEx,Ingram Micro,Sysco,Cisco Systems,Johnson Controls,Honeywell International,Prudential Financial,American Express,Northrop Grumman,Hess,GMAC,Comcast,Alcoa,DuPont,New York Life Insurance,CocaCola,News Corp,Aetna,TIAACREF,General Dynamics,Tyson Foods,HCA,Enterprise GP Holdings,Macy's,Delphi,Travelers Cos,Liberty Mutual Insurance Group,Hartford Financial Services,Abbott Laboratories,Washington Mutual,Humana,Massachusetts Mutual Life Insurance";
		NSString *jobTitles = @"Account Executive,Account Manager,Accountant,Accounting Intern,Actuarial Intern,Administrative Assistant,Analyst Intern,Analyst,Applications Engineer Intern,Architect Intern,Architectural Intern,Art Director,Assistant Manager,Assistant Store Manager,Assistant Vice President,Associate,Associate Intern,Associate Consultant Intern,Associate Director,Attorney,Audit Intern,Audit Associate,Audit Associate Intern,Audit Staff Intern,Auditor Intern,Branch Manager,Business Intern,Business Analyst Intern,Business Analyst,Business Development Manager,Cashier,Civil Engineer Intern,Civil Engineering Intern,Co-Op Intern,Co-Op Engineer Intern,Co-Op Student Intern,College Intern,Communications Intern,Consultant,Consultant Intern,Customer Service,Customer Service Representative,Data Analyst Intern,Design Engineer,Design Engineer Intern,Developer Intern,Developer,Director,Editorial Intern,EID Intern,Electrical Engineer,Electrical Engineer Intern,Engineer Intern,Engineer,Engineering Intern,Engineering Co-Op Intern,Engineering Manager,Executive Intern,Executive Assistant,Finance Intern,Finance Manager,Financial Advisor,Financial Analyst Intern,Financial Analyst,Financial Representative Intern,Flight Attendant,General Manager,Graduate Intern,Graduate Research Intern,Graduate Research Assistant Intern,Graduate Technical Intern,Graphic Designer Intern,Graphic Designer,Hardware Engineer Intern,Human Resources Intern,Interim Engineering Intern,Intern,Investment Banking Analyst Intern,Investment Banking Summer Analyst Intern,IT Intern,IT Analyst Intern,IT Analyst,It Manager,IT Specialist,Law Clerk Intern,Management Trainee Intern,Manager,Manager Intern,Marketing Intern,Marketing Assistant Intern,Marketing Director,Marketing Manager,MBA Intern,Mechanical Engineer,Mechanical Engineer Intern,Mechanical Engineering Intern,Member of Technical Staff,Member of Technical Staff Intern,Network Engineer,Office Manager,Operations Analyst Intern,Operations Manager,Personal Banker,Pharmacist,Pharmacist Intern,Pharmacy Intern,Principal Consultant,Principal Engineer,Principal Software Engineer,Process Engineer Intern,Process Engineer,Product Manager,Product Manager Intern,Product Marketing Manager Intern,Program Manager,Program Manager Intern,Programmer Intern,Programmer,Programmer Analyst,Programmer Analyst Intern,Project Engineer Intern,Project Engineer,Project Manager,Project Manager Intern,Public Relations Intern,QA Intern,QA Engineer Intern,R&amp;D Intern,Recruiter,Registered Nurse,Research Intern,Research Analyst Intern,Research Assistant Intern,Research Assistant,Research Associate,Research Associate Intern,Sales,Sales Intern,Sales Associate,Sales Engineer,Sales Manager,Sales Representative,Senior Accountant,Senior Analyst,Senior Associate,Senior Business Analyst,Senior Consultant,Senior Director,Senior Engineer,Senior Financial Analyst";
		NSString *departments = @"Marketing,Administation,Accounting,Human Resources,Public Relations,Advertising,Research & Development,Product Development";
		NSString *words = @"Apple,today,introduced,iCloud,a,breakthrough,set,of,free,new,cloud,services,that,work,seamlessly,with,applications,on,your,iPhone,iPad,iPod,touch,Mac,or,PC,to,automatically,and,wirelessly,store,your,content,in,iCloud,and,automatically,and,wirelessly,push,it,to,all,your,devices,When,anything,changes,on,one,of,your,devices,all,of,your,devices,are,wirelessly,updated,almost,instantly,Today,it,is,a,real,hassle,and,very,frustrating,to,keep,all,your,information,and,content,up-to-date,across,all,your,devices,said,Steve,Jobs,Apple's,CEO,iCloud,keeps,your,important,information,and,content,up,to,date,across,all,your,devices,All,of,this,happens,automatically,and,wirelessly,and,because,it's,integrated,into,our,apps,you,don't,even,need,to,think,about,it—it,all,just,works,The,free,iCloud,services,include,The,former,MobileMe,services—Contacts,Calendar,and,Mail—all,completely,re-architected,and,rewritten,to,work,seamlessly,with,iCloud,Users,can,share,calendars,with,friends,and,family,and,the,ad-free,push,Mail,account,is,hosted,at,Your,inbox,and,mailboxes,are,kept,up-to-date,across,all,your,iOS,devices,and,computers,The,App,Store™,and,iBookstore℠,now,download,purchased,iOS,apps,and,books,to,all,your,devices,not,just,the,device,they,were,purchased,on,In,addition,the,App,Store,and,iBookstore,now,let,you,see,your,purchase,history,and,simply,tapping,the,iCloud,icon,will,download,any,apps,and,books,to,any,iOS,device,up,to,10,devices,at,no,additional,cost,iCloud,Backup,automatically,and,securely,backs,up,your,iOS,devices,to,iCloud,daily,over,Wi-Fi,when,you,charge,your,iPhone,iPad,or,iPod,touch,Backed,up,content,includes,purchased,music,apps,and,books,Camera,Roll,photos,and,videos,device,settings,and,app,data,If,you,replace,your,iOS,device,just,enter,your,Apple,ID,and,password,during,setup,and,iCloud,restores,your,new,device,iCloud,Storage,seamlessly,stores,all,documents,created,using,iCloud,Storage,APIs,and,automatically,pushes,them,to,all,your,devices,When,you,change,a,document,on,any,device,iCloud,automatically,pushes,the,changes,to,all,your,devices,Apple's,Pages,Numbers,and,Keynote,apps,already,take,advantage,of,iCloud,Storage,Users,get,up,to,5GB,of,free,storage,for,their,mail,documents,and,backup—which,is,more,amazing,since,the,storage,for,music,apps,and,books,purchased,from,Apple,and,the,storage,required,by,Photo,Stream,doesn't,count,towards,this,5GB,total,Users,will,be,able,to,buy,even,more,storage,with,details,announced,when,iCloud,ships,this,fall,iCloud's,innovative,Photo,Stream,service,automatically,uploads,the,photos,you,take,or,import,on,any,of,your,devices,and,wirelessly,pushes,them,to,all,your,devices,and,computers,So,you,can,use,your,iPhone,to,take,a,dozen,photos,of,your,friends,during,the,afternoon,baseball,game,and,they,will,be,ready,to,share,with,the,entire,group,on,your,iPad,or,even,Apple,TV,when,you,return,home,Photo,Stream,is,built,into,the,photo,apps,on,all,iOS,devices,iPhoto,on,Macs,and,saved,to,the,Pictures,folder,on,a,PC,To,save,space,the,last,1000,photos,are,stored,on,each,device,so,they,can,be,viewed,or,moved,to,an,album,to,save,forever,Macs,and,PCs,will,store,all,photos,from,the,Photo,Stream,since,they,have,more,storage,iCloud,will,store,each,photo,in,the,cloud,for,30,days,which,is,plenty,of,time,to,connect,your,devices,to,iCloud,and,automatically,download,the,latest,photos,from,Photo,Stream,via,Wi-Fi,iTunes,in,the,Cloud,lets,you,download,your,previously,purchased,iTunes,music,to,all,your,iOS,devices,at,no,additional,cost,and,new,music,purchases,can,be,downloaded,automatically,to,all,your,devices,In,addition,music,not,purchased,from,iTunes,can,gain,the,same,benefits,by,using,iTunes,Match,a,service,that,replaces,your,music,with,a,256,kbps,AAC,DRM-free,version,if,we,can,match,it,to,the,over,18,million,songs,in,the,iTunes,Store,it,makes,the,matched,music,available,in,minutes,instead,of,weeks,to,upload,your,entire,music,library,and,uploads,only,the,small,percentage,of,unmatched,music,iTunes,Match,will,be,available,this,fall,for,a,$2499,annual,fee,Apple,today,is,releasing,a,free,beta,version,of,iTunes,in,the,Cloud,without,iTunes,Match,for,iPhone,iPad,and,iPod,touch,users,running,iOS,43,iTunes,in,the,Cloud,will,support,all,iPhones,that,iOS,5,supports,this,fall,Apple,is,ready,to,ramp,iCloud,in,its,three,data,centers,including,the,third,recently,completed,in,Maiden,NC,Apple,has,invested,over,$500,million,in,its,Maiden,data,center,to,support,the,expected,customer,demand,for,the,free,iCloud,services,Pricing,&,Availability,The,iCloud,beta,and,Cloud,Storage,APIs,are,available,immediately,to,iOS,and,Mac,Developer,Program,members,at,iCloud,will,be,available,this,fall,concurrent,with,iOS,5,Users,can,sign,up,for,iCloud,for,free,on,an,iPhone,iPad,or,iPod,touch,running,iOS,5,or,a,Mac,running,Mac,OS,X,Lion,with,a,valid,Apple,ID,iCloud,includes,5GB,of,free,cloud,storage,for,Mail,Document,Storage,and,Backup,Purchased,music,apps,books,and,Photo,Stream,do,not,count,against,the,storage,limit,iTunes,Match,will,be,available,for,$2499,per,year,US,only,iTunes,in,the,Cloud,is,available,today,in,the,US,and,requires,iTunes,103,and,iOS,433,Automatic,download,of,apps,and,books,is,available,today,Using,iCloud,with,a,PC,requires,Windows,Vista,or,Windows,7;,Outlook,2010,or,2007,is,recommended,for,accessing,contacts,and,calendars,Apple,designs,Macs,the,best,personal,computers,in,the,world,along,with,OS,X,iLife,iWork,and,professional,software,Apple,leads,the,digital,music,revolution,with,its,iPods,and,iTunes,online,store,Apple,has,reinvented,the,mobile,phone,with,its,revolutionary,iPhone,and,App,Store,and,has,recently,introduced,iPad,2,which,is,defining,the,future,of,mobile,media,and,computing,devices";
		
		self.fnArray = [firstNames componentsSeparatedByString:@","];
		self.lnArray = [lastNames componentsSeparatedByString:@","];
		self.prArray = [prefixes componentsSeparatedByString:@","];
		self.suArray = [suffixes componentsSeparatedByString:@","];
		self.nnArray = [nicknames componentsSeparatedByString:@","];
		self.orArray = [organizations componentsSeparatedByString:@","];
		self.jtArray = [jobTitles componentsSeparatedByString:@","];
		self.dpArray = [departments componentsSeparatedByString:@","];
		self.wdArray = [words componentsSeparatedByString:@","];
	}
	
	int fnRandNumber = rand() % fnArray.count;
	int lnRandNumber = rand() % lnArray.count;
	
	NSString *randomFn = [fnArray objectAtIndex:fnRandNumber];
	NSString *randomLn = [lnArray objectAtIndex:lnRandNumber];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary]; 
	[dict setObject:randomFn forKey:@"fn"];
	[dict setObject:[[randomLn lowercaseString] capitalizedString] forKey:@"ln"];
	
	
	if (rand() % 10 == 1) {
		int i = rand() % fnArray.count;
		NSString *randomObj = [fnArray objectAtIndex:i];
		[dict setObject:randomObj forKey:@"mn"];
	}
	
	if (rand() % 10 == 1) {
		int i = rand() % prArray.count;
		NSString *randomObj = [prArray objectAtIndex:i];
		[dict setObject:randomObj forKey:@"pn"];
	}
	
	if (rand() % 10 == 1) {
		int i = rand() % suArray.count;
		NSString *randomObj = [suArray objectAtIndex:i];
		[dict setObject:randomObj forKey:@"su"];
	}
	
	if (rand() % 10 == 1) {
		int i = rand() % nnArray.count;
		NSString *randomObj = [nnArray objectAtIndex:i];
		[dict setObject:randomObj forKey:@"nn"];
	}
	
	if (rand() % 10 == 1) {
		int i = rand() % orArray.count;
		NSString *randomObj = [orArray objectAtIndex:i];
		[dict setObject:randomObj forKey:@"or"];
	}	
	
	if (rand() % 10 == 1) {
		int i = rand() % jtArray.count;
		NSString *randomObj = [jtArray objectAtIndex:i];
		[dict setObject:randomObj forKey:@"jt"];
	}	
	
	if (rand() % 10 == 1) {
		int i = rand() % dpArray.count;
		NSString *randomObj = [dpArray objectAtIndex:i];
		[dict setObject:randomObj forKey:@"dp"];
	}
	
	return dict;
}


- (NSString *)generateRandomPhone
{
	int n1 = (rand() % 5) + 5;
	int n2 = rand() % 10;
	int n3 = rand() % 10;
	int n4 = rand() % 10;
	
	int n5 = rand() % 10;
	int n6 = rand() % 10;
	int n7 = rand() % 10;
	
	int n8 = rand() % 10;
	int n9 = rand() % 10;
	int n10 = rand() % 10;
	
	return [NSString stringWithFormat:@"(%d%d%d) %d%d%d-%d%d%d%d",n1,n2,n3,n4,n5,n6,n7,n8,n9,n10];
}

- (CFStringRef)generateRandomPhoneLabel
{
	int label = rand() % 6;
	CFStringRef array[6];
	array[0] = kABPersonPhoneMobileLabel;
	array[1] = kABPersonPhoneIPhoneLabel;
	array[2] = kABPersonPhoneMainLabel;
	array[3] = kABPersonPhoneHomeFAXLabel;
	array[4] = kABPersonPhoneWorkFAXLabel;
	array[5] = kABPersonPhonePagerLabel;
	return array[label];
}




- (NSString *)generateRandomIMFromFirstName:(NSString *)fn lastName:(NSString *)ln
{
	if (!dotComArray) {
		NSString *dotComs = @"gmail.com,hotmail.com,me.com,authorize.net,utah.edu,stophumantrafficking.org,gladis.org";
		self.dotComArray = [dotComs componentsSeparatedByString:@","];
	}
	
	int randDotCom = rand() % dotComArray.count;
	NSString *dotCom = [dotComArray objectAtIndex:randDotCom];
	
	return [NSString stringWithFormat:@"%@_%@@%@",fn,ln,dotCom];
}


- (NSString *)generateRandomIMService
{
	int label = rand() % 7;
	CFStringRef array[7];
	array[0] = kABPersonInstantMessageServiceKey;
	array[1] = kABPersonInstantMessageServiceYahoo;
	array[2] = kABPersonInstantMessageServiceJabber;
	array[3] = kABPersonInstantMessageServiceMSN;
	array[4] = kABPersonInstantMessageServiceICQ;
	array[5] = kABPersonInstantMessageServiceAIM;
	array[6] = kABPersonInstantMessageUsernameKey;
	return (NSString *)array[label];
}


- (CFStringRef)generateRandomIMLabel
{
	int label = rand() % 3;
	CFStringRef array[3];
	array[0] = kABWorkLabel;
	array[1] = kABHomeLabel;
	array[2] = kABOtherLabel;
	return array[label];
}


- (NSString *)generateRandomNote
{
	NSString *note = @"";
	int words = rand() % 40;
	for (int i = 0; i < words; i++) {
		int i = rand() % wdArray.count;
		NSString *randomWord = [wdArray objectAtIndex:i];
		note = [note stringByAppendingFormat:@" %@", randomWord];
	}
	return note;
}








			
			
- (NSString *)generateRandomStreet
{
	NSString *streetNames = @"Main Street,Church Street,High Street,Chestnut Street,Broad Street,Elm Street,Walnut Street,2nd Street,Maple Avenue,Maple Street,Washington Street,River Road,Center Street,Main Street North,Pine Street,Main Street South,Union Street,Park Avenue,Water Street,South Street,Main Street East,Main Street West,Market Street,Oak Street,Spring Street,School Street,Front Street,Prospect Street,3rd Street,Park Street,Washington Avenue,North Street,Cedar Street,Court Street,Highland Avenue,Spruce Street,Central Avenue,Franklin Street,Church Road,Pleasant Street,Ridge Road,State Street,West Street,Locust Street,Winding Way,4th Street,Cherry Street,Cherry Lane,Lincoln Avenue,Mill Street,1st Street,Bridge Street,Dogwood Drive,East Street,Holly Drive,Park Place,Pennsylvania Avenue,2nd Avenue,5th Street,Adams Street,Arch Street,Green Street,Heather Lane,Liberty Street,Meadow Lane,Pearl Street,River Street,Route 32,Route 6,Valley Road,3rd Avenue,Academy Street,Canterbury Court,Hickory Lane,Jefferson Avenue,Railroad Street,Route 1,Route 30,Beech Street,Clinton Street,Creek Road,Division Street,Durham Road,Fairview Avenue,Lincoln Street,Madison Avenue,Windsor Drive,Woodland Drive,1st Avenue,4th Avenue,5th Avenue,Buckingham Drive,College Avenue,Colonial Drive,Delaware Avenue,Devon Road,Garfield Avenue,Grove Street,Hamilton Street,Jackson Street,Jefferson Street,John Street,Lake Street,Laurel Lane,Mill Road,New Street,Oxford Court,12th Street,Broadway,Canal Street,Cedar Lane,Cottage Street,Eagle Road,Elizabeth Street,Forest Drive,Franklin Avenue,Franklin Court,Heritage Drive,Hillside Avenue,Jefferson Court,Prospect Avenue,Railroad Avenue,Route 29,Route 44,Summit Avenue,Valley View Drive,York Road,11th Street,13th Street,5th Street North,Brook Lane,Buttonwood Drive,Cambridge Court,Devonshire Drive,Dogwood Lane,Elm Avenue,Elmwood Avenue,Fairway Drive,Garden Street,Grove Avenue,Hillside Drive,King Street,Lantern Lane,Laurel Drive,Locust Lane,Madison Street,Mulberry Court,Oak Avenue,Oak Lane,Penn Street,Ridge Avenue,Route 20,Sherwood Drive,Smith Street,Street Road,Surrey Lane,Tanglewood Drive,Vine Street,Walnut Avenue,Willow Street,10th Street,4th Street North,Andover Court,Ashley Court,Aspen Court,Belmont Avenue,Bridle Lane,Brookside Drive,Cambridge Road,Cedar Avenue,Cobblestone Court,Durham Court,Essex Court,Fawn Lane,Front Street North,George Street,Grant Avenue,Hawthorne Lane,Henry Street,Highland Drive,Hillcrest Avenue,Lafayette Avenue,Lake Avenue,Laurel Street,Lilac Lane,Magnolia Court,Old York Road,Orchard Avenue,Orchard Street,Pheasant Run,Pin Oak Drive,Rosewood Drive,Route 11,Route 9,Sheffield Drive,Sunset Drive,Victoria Court,Wall Street,Westminster Drive,Windsor Court,Woodland Avenue,Woodland Road";
	self.snArray = [streetNames componentsSeparatedByString:@","];
	
	int snRandNumber = rand() % snArray.count;
	
	NSString *randomSn = [snArray objectAtIndex:snRandNumber];
	
	int houseNumber = rand() % 1000;
	
	return [NSString stringWithFormat:@"%d %@", houseNumber, randomSn];
}

- (NSString *)generateRandomCity
{
	if (!cities) {
		NSString *citiesString = @"New York,Los Angeles,Chicago,Houston,Phoenix,Philadelphia,San Antonio,San Diego,Dallas,San Jose,Detroit,San Francisco,Jacksonville,Indianapolis,Austin,Columbus,Fort Worth,Charlotte,Memphis,Boston,Baltimore,El Paso,Seattle,Denver,Nashville,Milwaukee,Washington,Las Vegas,Louisville,Portland,Oklahoma City,Tucson,Atlanta,Albuquerque,Kansas City,Fresno,Mesa,Sacramento,Long Beach,Omaha,Virginia Beach,Miami,Cleveland,Oakland,Raleigh,Colorado Springs,Tulsa,Minneapolis,Arlington,Honolulu,Wichita,St. Louis,New Orleans,Tampa,Santa Ana,Anaheim,Cincinnati,Bakersfield,Aurora,Toledo,Pittsburgh,Riverside,Lexington,Stockton,Corpus Christi,Anchorage,St. Paul,Newark,Plano,Buffalo,Henderson,Fort Wayne,Greensboro,Lincoln,Glendale,Chandler,St. Petersburg,Jersey City,Scottsdale,Orlando,Madison,Norfolk,Birmingham,Winston-Salem,Durham,Laredo,Lubbock,Baton Rouge,North Las Vegas,Chula Vista,Chesapeake,Gilbert,Garland,Reno,Hialeah,Arlington,Irvine,Rochester,Akron,Boise,Irving,Fremont,Richmond,Spokane,Modesto,Montgomery,Yonkers,Des Moines,Tacoma,Shreveport,San Bernardino,Fayetteville,Glendale,Augusta,Grand Rapids,Huntington Beach,Mobile,Newport News,Little Rock,Moreno Valley,Columbus,Amarillo,Fontana,Oxnard,Knoxville,Fort Lauderdale,Salt Lake City,Worcester,Huntsville,Tempe,Brownsville,Jackson,Overland Park,Aurora,Oceanside,Tallahassee,Providence,Rancho Cucamonga,Ontario,Chattanooga,Santa Clarita,Garden Grove,Vancouver,Grand Prairie,Peoria,Sioux Falls,Springfield,Santa Rosa,Rockford,Springfield,Salem,Port St. Lucie,Cape Coral,Dayton,Eugene,Pomona,Corona,Alexandria,Joliet,Pembroke Pines,Paterson,Pasadena,Lancaster,Hayward,Salinas,Hampton,Palmdale,Pasadena,Naperville,Kansas City,Hollywood,Lakewood,Torrance,Escondido,Fort Collins,Syracuse,Bridgeport,Orange,Cary,Elk Grove,Savannah,Sunnyvale,Warren,Mesquite,Fullerton,McAllen,Columbia,Carrollton,Cedar Rapids,McKinney,Sterling Heights,Bellevue,Coral Springs,Waco,Elizabeth,West Valley City,Clarksville,Topeka,Hartford,Thousand Oaks,New Haven,Denton,Concord,Visalia,Olathe,El Monte,Independence,Stamford,Simi Valley,Provo,Killeen,Springfield,Thornton,Abilene,Gainesville,Evansville,Roseville,Charleston,Peoria,Athens,Lafayette,Vallejo,Lansing,Ann Arbor,Inglewood,Santa Clara,Flint,Victorville,Costa Mesa,Beaumont,Miami Gardens,Manchester,Westminster,Miramar,Norman,Cambridge,Midland,Arvada,Allentown,Elgin,Waterbury,Downey,Clearwater,Billings,West Covina,Round Rock,Murfreesboro,Lewisville,West Jordan,Pueblo,San Buenaventura (Ventura),Lowell,South Bend,Fairfield,Erie,Rochester,High Point,Richardson,Richmond,Burbank,Berkeley,Pompano Beach,Norwalk,Frisco,Columbia,Gresham,Daly City,Green Bay,Wilmington,Davenport,Wichita Falls,Antioch,Palm Bay,Odessa,Centennial,Boulder,Colorado";
		self.cities = [citiesString componentsSeparatedByString:@","];
	}
	
	int cityRandNumber = rand() % cities.count;
	return [cities objectAtIndex:cityRandNumber];
}

- (NSString *)generateRandomState
{
	if (!states) {
		NSString *statesString = @"AL,AK,AZ,AR,CA,CO,CT,DE,FL,GA,HI,ID,IL,IN,IA,KS,KY,LA,ME,MD,MA,MI,MN,MS,MO,MT,NE,NV,NH,NJ,NM,NY,NC,ND,OH,OK,OR,PA,RI,SC,SD,TN,TX,UT,VT,VA,WA,WV,WI,WY";
		self.states = [statesString componentsSeparatedByString:@","];
	}
	
	int stateRandNumber = rand() % states.count;
	return [states objectAtIndex:stateRandNumber];
}

- (NSString *)generateRandomZipCode
{
	int n1 = rand() % 10;
	int n2 = rand() % 10;
	int n3 = rand() % 10;
	int n4 = rand() % 10;
	int n5 = rand() % 10;
	
	return [NSString stringWithFormat:@"%d%d%d%d%d",n1,n2,n3,n4,n5];
}







- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if ([string isEqualToString:@"\n"]) {
		[textField resignFirstResponder];
		return NO;
	}
	return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
}


- (void)dealloc {
    [window release];
	[addButton release];
	[removeAllButton release];
	[howMany release];
	[whatGroup release];
	[spinner release];
	self.fnArray = nil;
	self.lnArray = nil;
	self.prArray = nil;
	self.suArray = nil;
	self.nnArray = nil;
	self.orArray = nil;
	self.jtArray = nil;
	self.dpArray = nil;
	self.wdArray = nil;
	self.snArray = nil;
	self.cities = nil;
	self.states = nil;
	self.dotComArray = nil;
    [super dealloc];
}


@end
