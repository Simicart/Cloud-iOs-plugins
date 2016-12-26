

#import "PosSection.h"

@implementation PosSection
@synthesize identifier = _identifier;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _headerTitle = nil;
        _footerTitle = nil;
        _rows = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    if (self = [self init]) {
        self.identifier = identifier;
    }
    return self;
}

- (instancetype)initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle rows:(NSMutableArray *)rows{
    self = [super init];
    if (self) {
        _headerTitle = headerTitle;
        _footerTitle = footerTitle;
        _rows = rows;
    }
    return self;
}

- (instancetype)initWithHeaderTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle{
    self = [super init];
    if (self) {
        _headerTitle = headerTitle;
        _footerTitle = footerTitle;
        _rows = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addRowWithIdentifier:(NSString *)identifier height:(double)height{
    PosRow *row = [[PosRow alloc] initWithIdentifier:identifier height:height];
    [self.rows addObject:row];
    row.sortOrder = [self.rows count] * 100;
}

- (PosRow *)objectAtIndex:(NSInteger)index{
    return [self.rows objectAtIndex:index];
}

- (void)removeRowsAtIndexes:(NSIndexSet *)indexes{
    [self.rows removeObjectsAtIndexes:indexes];
}

- (void)removeRowAtIndex:(NSUInteger)index{
    [self.rows removeObjectAtIndex:index];
}

- (void)insertObject:(PosRow *)object inRowsAtIndex:(NSUInteger)index{
    [self.rows insertObject:object atIndex:index];
}

- (void)addObject:(PosRow *)row{
    [self.rows addObject:row];
    PosRow *PosRow = [self.rows lastObject];
    if (!PosRow.sortOrder) {
        PosRow.sortOrder = [self.rows count] * 100;
    }
}

- (NSInteger)count{
    return self.rows.count;
}

- (NSMutableArray *)rows{
    return _rows;
}


- (PosRow *)addRowWithIdentifier:(NSString *)identifier height:(double)height sortOrder:(NSInteger)order
{
    PosRow *row = [[PosRow alloc] initWithIdentifier:identifier height:height sortOrder:order];
    [self.rows addObject:row];
    if (!row.sortOrder) {
        row.sortOrder = [self.rows count] * 100;
    }
    return row;
}

- (PosRow *)getRowByIdentifier:(NSString *)identifier
{
    for (PosRow *row in self.rows) {
        if ([row.identifier isEqual:identifier]) {
            return row;
        }
    }
    return nil;
}

- (NSUInteger)getRowIndexByIdentifier:(NSString *)identifier
{
    for (NSUInteger index = 0; index < self.rows.count; index++) {
        PosRow *row = [self.rows objectAtIndex:index];
        if ([row.identifier isEqual:identifier]) {
            return index;
        }
    }
    return NSNotFound;
}

- (void)addRow:(PosRow *)row
{
    [self.rows addObject:row];
    if (!row.sortOrder) {
        row.sortOrder = [self.rows count] * 100;
    }
}

- (void)removeRowByIdentifier:(NSString *)identifier
{
    for (NSInteger i = [self.rows count]; i > 0; ) {
        PosRow *row = [self.rows objectAtIndex:--i];
        if ([row.identifier isEqualToString:identifier]) {
            [self.rows removeObjectAtIndex:i];
        }
    }
}

- (void)removeRow:(PosRow *)row
{
    [self.rows removeObject:row];
}

- (void)removeAll
{
    [self.rows removeAllObjects];
}

- (void)sortItems
{
    [self.rows sortUsingComparator:^NSComparisonResult(PosRow *row1, PosRow *row2) {
        if (row2.sortOrder < row1.sortOrder) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
}

@end
