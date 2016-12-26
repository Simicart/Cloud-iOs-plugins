//
//  DBManager.h
//  TestSQLite
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 7/8/16.
//  Copyright © 2016 TruePlus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject
@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;

@property (nonatomic, strong) NSMutableArray *arrResults;
@property (nonatomic, strong) NSMutableArray *arrColumnNames;

@property (nonatomic) int affectedRows;

@property (nonatomic) long long lastInsertedRowID;
@property (nonatomic) Boolean statusRunQuery;

-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;
-(void)copyDatabaseIntoDocumentsDirectory;
-(NSArray *)loadDataFromDB:(NSString *)query;

-(void)executeQuery:(NSString *)query;

@end
