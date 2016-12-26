
#import <Foundation/Foundation.h>
#import "PosSection.h"
#import "PosRow.h"

@interface PosSection : NSObject
@property (strong, nonatomic) NSString *identifier;

@property (strong, nonatomic) NSString *headerTitle;
@property (strong, nonatomic) NSString *footerTitle;
@property (strong, nonatomic) NSMutableArray *rows;

- (instancetype)init;
- (instancetype)initWithIdentifier:(NSString *)identifier;
- (instancetype)initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle;
- (instancetype)initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle rows:(NSMutableArray *)rows;
- (void)addRowWithIdentifier:(NSString *)identifier height:(double)height; // auto generate sort order
- (void)insertObject:(PosRow *)object inRowsAtIndex:(NSUInteger)index;
- (void)removeRowsAtIndexes:(NSIndexSet *)indexes;
- (void)removeRowAtIndex:(NSUInteger)index;
- (void)addObject:(PosRow *)row;
- (PosRow *)objectAtIndex:(NSInteger)index;
- (NSInteger)count;
- (NSMutableArray *)rows;

- (PosRow *)addRowWithIdentifier:(NSString *)identifier height:(double)height sortOrder:(NSInteger)order;
- (PosRow *)getRowByIdentifier:(NSString *)identifier;
- (NSUInteger)getRowIndexByIdentifier:(NSString *)identifier;
- (void)addRow:(PosRow *)row;
- (void)removeRowByIdentifier:(NSString *)identifier;
- (void)removeRow:(PosRow *)row;
- (void)removeAll;

- (void)sortItems;

@end
