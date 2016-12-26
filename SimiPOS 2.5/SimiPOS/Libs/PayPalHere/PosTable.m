

#import "PosTable.h"

@implementation PosTable

- (PosSection *)addSectionWithIdentifier:(NSString *)identifier
{
    PosSection *section = [[PosSection alloc] initWithIdentifier:identifier];
    [self addObject:section];
    return section;
}

- (PosSection *)addSectionWithIdentifier:(NSString *)identifier atIndex:(NSUInteger)index
{
    PosSection *section = [[PosSection alloc] initWithIdentifier:identifier];
    [self insertObject:section atIndex:index];
    return section;
}

- (PosSection *)addSectionWithIdentifier:(NSString *)identifier headerTitle:(NSString *)headerTitle
{
    PosSection *section = [[PosSection alloc] initWithIdentifier:identifier];
    section.headerTitle = headerTitle;
    [self addObject:section];
    return section;
}

- (PosSection *)addSectionWithIdentifier:(NSString *)identifier headerTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle
{
    PosSection *section = [[PosSection alloc] initWithHeaderTitle:headerTitle footerTitle:footerTitle];
    section.identifier = identifier;
    [self addObject:section];
    return section;
}

- (PosSection *)getSectionByIdentifier:(NSString *)identifier
{
    for (PosSection *section in self) {
        if ([section.identifier isEqualToString:identifier]) {
            return section;
        }
    }
    return nil;
}

- (NSUInteger)getSectionIndexByIdentifier:(NSString *)identifier
{
    for (NSUInteger index = 0; index < self.count; index++) {
        PosSection *section = [self objectAtIndex:index];
        if ([section.identifier isEqualToString:identifier]) {
            return index;
        }
    }
    return NSNotFound;
}

- (void)removeSectionsByIdentifier:(NSString *)identifier
{
    for (NSUInteger index = self.count; index > 0; ) {
        PosSection *section = [self objectAtIndex:--index];
        if ([section.identifier isEqualToString:identifier]) {
            [self removeObjectAtIndex:index];
        }
    }
}

@end
