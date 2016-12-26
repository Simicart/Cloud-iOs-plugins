//
//  NSObject+RetailerPosObject.h

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (RetailerPosObject)

// Object identifier
@property (strong, nonatomic) NSObject *retailerPosObjectIdentifier;
@property (strong, nonatomic) NSString *retailerPosObjectName;
@property (nonatomic) BOOL isDiscontinue;

// Notification methods
- (void)removeObserverForNotification:(NSNotification *)noti;
- (void)didReceiveNotification:(NSNotification *)noti;
- (void)postNotificationName:(NSString *)notificationName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

// Singleton pattern
+ (instancetype)singleton;

// IB Localized
/**
 * This method is used to translate strings in .xib files.
 * Using the "User Defined Runtime Attributes" set an entry like:
 * 
 * Key Path: textLocalized
 * Type: String
 * Value: {THE TRANSLATION KEY}
 * 
 */
- (void)setTextLocalized:(NSString *)key;

@end
