//
//  QueryManager.h
//  TestSQLite
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 7/12/16.
//  Copyright © 2016 TruePlus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"

@interface QueryManager : NSObject



@property (nonatomic, strong) DBManager *dbManager;

/*
 * Example typeOfColumn and values
 NSMutableArray *typeOfColumn = [NSMutableArray new];
 [typeOfColumn addObject:@{@"name":@"peopleInfoID",@"type":@"integer",@"key":@"primary key"}];
 [typeOfColumn addObject:@{@"name":@"firstname"   ,@"type":@"text"   ,@"key":@""}];
 [typeOfColumn addObject:@{@"name":@"lastname"    ,@"type":@"text"   ,@"key":@""}];
 [typeOfColumn addObject:@{@"name":@"age"         ,@"type":@"integer",@"key":@""}];
 NSMutableArray *values = [[NSMutableArray alloc]initWithObjects:@"",@"ravi",@"nguyen",@"25", nil];
 */

- (instancetype)initWithDatabaseFilename:(NSString *)dbFilename;

- (void)createTable :(NSString*)tableName withTypeOfColumn:(NSMutableArray*)typeOfColumn;
- (void)dropTable   :(NSString*)tableName;
- (void)insertInto  :(NSString*)tableName withTypeOfColumn:(NSMutableArray*)typeOfColumn values:(NSArray*)values;
- (void)update      :(NSString*)tableName withTypeOfColumn:(NSMutableArray*)typeOfColumn values:(NSArray*)values;
- (void)deleteFrom  :(NSString*)tableName primaryKey:(NSString*)primaryKey primaryKeyValue:(NSString *)primaryKeyValue;
- (NSArray*)selectAllDataFromTable: (NSString*)tableName;
- (NSArray*)selectDataUseKey:       (NSString*)tableName primaryKey:(NSString*)primaryKey primaryKeyValue:(NSString *)primaryKeyValue;
- (NSArray*)selectDataUseLike:      (NSString*)tableName column:(NSString*)column likeValue:(NSString*)likeValue;
- (NSArray*)loadNameTable;

@end
