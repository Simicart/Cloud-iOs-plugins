//
//  SimiPOSTests.m
//  SimiPOSTests
//
//  Created by Nguyen Dac Doan on 10/18/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "SimiPOSTests.h"
#import "MagentoAbstract.h"
#import "Configuration.h"

#import "CategoryCollection.h"
#import "Price.h"

#import "NSData+AES256.h"

@implementation SimiPOSTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    // Test Login Method
//    MagentoAbstract *obj = [[MagentoAbstract alloc] init];
//    [obj login];
//    
//    NSString *session = [[Configuration globalConfig] objectForKey:@"session"];
//    NSLog(@"%@", session);
    
    // Test Logout Method
//    [obj logout];
    
    // Test Load Product Method
//    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
//    [obj post:[[NSDictionary alloc] initWithObjectsAndKeys:@"product.info", @"method", @"16", @"params", nil] target:result finished:nil async:NO];
//    NSLog(@"%@", [result description]);
    
//    [obj post:[[NSDictionary alloc] initWithObjectsAndKeys:@"category.tree", @"method", nil] target:result finished:nil async:NO];
//    NSLog(@"%@", [result description]);
    
    
    // Test category collection
//    CategoryCollection *collection = [[CategoryCollection alloc] init];
//    [collection load];
//    Category *cat = [collection objectAtIndex:2];
//    NSLog(@"%@", [cat description]);
}

- (void)testFormatPrice
{
//    Price *price = (Price *)[Configuration getSingleton:@"Price"];
//    [price loadSuccess];
//    [price setValue:@"$%s" forKey:@"pattern"];
//    [price setValue:[NSNumber numberWithInt:2] forKey:@"precision"];
//    [price setValue:@"." forKey:@"decimalSymbol"];
//    [price setValue:@"," forKey:@"groupSymbol"];
//    [price setValue:[NSNumber numberWithInt:3] forKey:@"groupLength"];
//    
//    NSLog(@"\nFormated Price: %@\n", [price formatPrice:1234567.899]);
//    NSLog(@"\nFormated Price: %@\n", [Price format:[NSNumber numberWithFloat:81234567.899]]);
//    NSLog(@"\nFormated Price: %@\n", [Price format:[NSNumber numberWithFloat:0.454]]);
}

- (void)testAES
{
    NSDictionary *input = @{@"david": @"magestore.com"};
    
    NSData *inputData = [NSKeyedArchiver archivedDataWithRootObject:input];
    NSLog(@"%@", inputData);
    
    NSData *encryptedData = [inputData AES256EncryptWithKey:@"newKey"];
    NSLog(@"%@", encryptedData);
    
    // Store encrypted data to file
    // Load encrypted data from file
    
    NSData *decryptedData = [encryptedData AES256DecryptWithKey:@"otherKey"];
    NSLog(@"%@", decryptedData); // Error Data
//    NSDictionary *output = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
//    NSLog(@"%@", output);
    
    decryptedData = [encryptedData AES256DecryptWithKey:@"newKey"];
    NSLog(@"%@", decryptedData); // Success
    
    NSDictionary *output = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
    NSLog(@"%@", output);
}

@end
