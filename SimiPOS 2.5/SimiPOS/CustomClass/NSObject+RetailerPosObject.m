//
//  NSObject+RetailerPosObject.m

#import "NSObject+RetailerPosObject.h"

@implementation NSObject (RetailerPosObject)

- (void)postNotificationName:(NSString *)notificationName object:(id)anObject userInfo:(NSDictionary *)aUserInfo{
    notificationName = [NSString stringWithFormat:@"%@-%@", NSStringFromClass(self.class), notificationName];
    if (aUserInfo) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:anObject userInfo:aUserInfo];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:anObject];
    }
}

#pragma mark - singleton pattern
+ (instancetype)singleton
{
    static NSMutableDictionary *_singletons;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singletons = [NSMutableDictionary new];
    });
    // Check and create dictionary
    id _instance = nil;
    @synchronized(self) {
        NSString *klass = NSStringFromClass(self);
        _instance = [_singletons objectForKey:klass];
        if (_instance == nil) {
            _instance = [self new];
            [_singletons setValue:_instance forKey:klass];
        }
    }
    // Return singleton instance
    return _instance;
}

#pragma mark - notification
- (void)removeObserverForNotification:(NSNotification *)noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
}

- (void)didReceiveNotification:(NSNotification *)noti{
    [self removeObserverForNotification:noti];
    
}

#pragma mark - object identifier
- (void)setRetailerPosObjectIdentifier:(NSObject *)object {
    objc_setAssociatedObject(self, @selector(retailerPosObjectIdentifier), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSObject *)retailerPosObjectIdentifier {
    return objc_getAssociatedObject(self, @selector(retailerPosObjectIdentifier));
}

- (void)setRetailerPosObjectName:(NSString *)object {
    objc_setAssociatedObject(self, @selector(retailerPosObjectName), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)retailerPosObjectName {
    return objc_getAssociatedObject(self, @selector(retailerPosObjectName));
}

- (void)setIsDiscontinue:(BOOL)isDiscont{
    NSNumber *number = [NSNumber numberWithBool:isDiscont];
    objc_setAssociatedObject(self, @selector(isDiscontinue), number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isDiscontinue{
    NSNumber *number = objc_getAssociatedObject(self, @selector(isDiscontinue));
    return [number boolValue];
}

// IB Localized
- (void)setTextLocalized:(NSString *)key
{
//    if ([self isKindOfClass:[UIButton class]]) {
//        [(UIButton *)self setTitle:SCLocalizedString(key) forState:UIControlStateNormal];
//    } else if ([self isKindOfClass:[UITextField class]]) {
//        [(UITextField *)self setPlaceholder:SCLocalizedString(key)];
//    } else if ([self isKindOfClass:[UILabel class]]) {
//        [(UILabel *)self setText:SCLocalizedString(key)];
//    } else if ([self isKindOfClass:[UISearchBar class]]) {
//        [(UISearchBar *)self setPlaceholder:SCLocalizedString(key)];
//    } else if ([self isKindOfClass:[UIBarButtonItem class]]) {
//        [(UIBarButtonItem *)self setTitle:SCLocalizedString(key)];
//    }
}

@end
