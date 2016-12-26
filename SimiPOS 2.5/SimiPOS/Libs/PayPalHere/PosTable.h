
#import "PosSection.h"
#import "PosMutableArray.h"

@interface PosTable : PosMutableArray

- (PosSection *)addSectionWithIdentifier:(NSString *)identifier;
- (PosSection *)addSectionWithIdentifier:(NSString *)identifier atIndex:(NSUInteger)index;
- (PosSection *)addSectionWithIdentifier:(NSString *)identifier headerTitle:(NSString *)headerTitle;
- (PosSection *)addSectionWithIdentifier:(NSString *)identifier headerTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle;

- (PosSection *)getSectionByIdentifier:(NSString *)identifier;
- (NSUInteger)getSectionIndexByIdentifier:(NSString *)identifier;

- (void)removeSectionsByIdentifier:(NSString *)identifier;

@end
