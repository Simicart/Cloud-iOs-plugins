//
//  QueryManager.m
//  TestSQLite
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 7/12/16.
//  Copyright © 2016 TruePlus. All rights reserved.
//

#import "QueryManager.h"

@implementation QueryManager

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename{
    self = [super init];
    if (self) {
       self.dbManager = [[DBManager alloc] initWithDatabaseFilename:dbFilename];
    }
    return self;
}


#pragma mark InsertInto table

- (void)insertInto :(NSString*)tableName withTypeOfColumn:(NSMutableArray*)typeOfColumn values:(NSArray*)values{
    NSString *query = [self queryInsertInto:tableName withTypeOfColumn:typeOfColumn values:values];
    
    [self.dbManager executeQuery:query];
    if (self.dbManager.statusRunQuery) {
        DLog(@"insertInto %@ Success",tableName);
    }else{
        DLog(@"insertInto %@ Failure",tableName);
    }
    
}


- (NSString*)queryInsertInto:(NSString*)tableName withTypeOfColumn:(NSMutableArray*)typeOfColumn  values:(NSArray*)values{
    NSString *query = [NSString stringWithFormat:@"insert into %@ values(",tableName];
    NSString *strValues = @"";
    for (int i = 0; i < values.count; i++) {
        NSDictionary *dictTypeOfColumn = [[NSDictionary alloc]initWithDictionary:[typeOfColumn objectAtIndex:i]];
        if (i != values.count -1) {
            if ([[dictTypeOfColumn valueForKey:@"key"]isEqualToString:@"primary key"]) {
                strValues = [NSString stringWithFormat:@"null,"];
            }else if ([[dictTypeOfColumn valueForKey:@"type"]isEqualToString:@"text"]) {
                strValues = [NSString stringWithFormat:@"'%@',",[values objectAtIndex:i]];
            }else if ([[dictTypeOfColumn valueForKey:@"type"]isEqualToString:@"integer"]) {
                strValues = [NSString stringWithFormat:@"%@,",[values objectAtIndex:i]];
            }
        }else{
            if ([[dictTypeOfColumn valueForKey:@"key"]isEqualToString:@"primary key"]) {
                strValues = [NSString stringWithFormat:@"null"];
            }else if ([[dictTypeOfColumn valueForKey:@"type"]isEqualToString:@"text"]) {
                strValues = [NSString stringWithFormat:@"'%@'",[values objectAtIndex:i]];
            }else if ([[dictTypeOfColumn valueForKey:@"type"]isEqualToString:@"integer"]) {
                strValues = [NSString stringWithFormat:@"%@",[values objectAtIndex:i]];
            }
        }
        query = [NSString stringWithFormat:@"%@%@",query,strValues];
    }
    query = [NSString stringWithFormat:@"%@)",query];
    return query;
}


#pragma mark Update database
- (void)update : (NSString*)tableName withTypeOfColumn:(NSMutableArray*)typeOfColumn values:(NSArray*)values{
    NSString *query = [self queryUpdate:tableName withTypeOfColumn:typeOfColumn values:values];
    
    [self.dbManager executeQuery:query];
    if (self.dbManager.statusRunQuery) {
        DLog(@"update %@ Success",tableName);
    }else{
        DLog(@"update %@ Failure",tableName);
    }
}

- (NSString*)queryUpdate:(NSString*)tableName withTypeOfColumn:(NSMutableArray*)typeOfColumn  values:(NSArray*)values{
    NSString *query = [NSString stringWithFormat:@"update %@ set ",tableName];
    NSString *strValues = @"";
    NSString *primaryKey = @"";
    NSString *primaryKeyValue = @"";
    for (int i = 0; i < values.count; i++) {
        NSDictionary *dictTypeOfColumn = [[NSDictionary alloc]initWithDictionary:[typeOfColumn objectAtIndex:i]];
        if (![[dictTypeOfColumn valueForKey:@"key"]isEqualToString:@"primary key"]) {
            if (i != values.count -1) {
                if ([[dictTypeOfColumn valueForKey:@"type"]isEqualToString:@"text"]) {
                    strValues = [NSString stringWithFormat:@"%@='%@',",[dictTypeOfColumn valueForKey:@"name"],[values objectAtIndex:i]];
                }else if ([[dictTypeOfColumn valueForKey:@"type"]isEqualToString:@"integer"]) {
                    strValues = [NSString stringWithFormat:@"%@=%@,",[dictTypeOfColumn valueForKey:@"name"],[values objectAtIndex:i]];
                }
            }else{
                if ([[dictTypeOfColumn valueForKey:@"type"]isEqualToString:@"text"]) {
                    strValues = [NSString stringWithFormat:@"%@='%@'",[dictTypeOfColumn valueForKey:@"name"],[values objectAtIndex:i]];
                }else if ([[dictTypeOfColumn valueForKey:@"type"]isEqualToString:@"integer"]) {
                    strValues = [NSString stringWithFormat:@"%@=%@",[dictTypeOfColumn valueForKey:@"name"],[values objectAtIndex:i]];
                }
            }
        }
        else {
            primaryKey = [dictTypeOfColumn valueForKey:@"name"];
            primaryKeyValue = [values objectAtIndex:i];
        }
        query = [NSString stringWithFormat:@"%@%@",query,strValues];
    }
    query = [NSString stringWithFormat:@"%@ where %@=%@",query,primaryKey,primaryKeyValue];
    return query;
}



#pragma mark CreateTable in database
- (void)createTable:(NSString*)tableName withTypeOfColumn:(NSMutableArray*)typeOfColumn{
    NSString *query = [self queryCreateTable:tableName withTypeOfColumn:typeOfColumn];
    
    [self.dbManager executeQuery:query];
    if (self.dbManager.statusRunQuery) {
        DLog(@"Create Table %@ Success",tableName);
    }else{
        DLog(@"Create Table %@ Failure",tableName);
    }
    
    
}

- (NSString*)queryCreateTable:(NSString*)tableName withTypeOfColumn:(NSMutableArray*)typeOfColumn{
    NSString *query = [NSString stringWithFormat:@"create table %@(",tableName];
    NSString *strTypeColumn = @"";
    for (int i = 0; i < typeOfColumn.count; i++) {
        NSDictionary *dictTypeOfColumn = [[NSDictionary alloc]initWithDictionary:[typeOfColumn objectAtIndex:i]];
        if (i != typeOfColumn.count -1) {
            strTypeColumn = [NSString stringWithFormat:@"%@ %@ %@,",[dictTypeOfColumn valueForKey:@"name"],[dictTypeOfColumn valueForKey:@"type"],[dictTypeOfColumn valueForKey:@"key"]];
        }else{
            strTypeColumn = [NSString stringWithFormat:@"%@ %@ %@",[dictTypeOfColumn valueForKey:@"name"],[dictTypeOfColumn valueForKey:@"type"],[dictTypeOfColumn valueForKey:@"key"]];
        }
        query = [NSString stringWithFormat:@"%@%@",query,strTypeColumn];
    }
    
    query = [NSString stringWithFormat:@"%@)",query];
    return query;
}


#pragma mark DropTable in database
- (void)dropTable:(NSString*)tableName{
    NSString *query = [NSString stringWithFormat: @"DROP TABLE %@",tableName];
    
    [self.dbManager executeQuery:query];
    if (self.dbManager.statusRunQuery) {
        DLog(@"Drop table Success");
    }else{
        DLog(@"Drop table Failure");
    }
}


#pragma mark delete data Table in database
-(void)deleteFrom:(NSString*)tableName primaryKey:(NSString*)primaryKey primaryKeyValue:(NSString *)primaryKeyValue{
    
    NSString *query = [NSString stringWithFormat:@"delete from %@ where %@=%@",tableName, primaryKey,primaryKeyValue];
    
    // Execute the query.
    [self.dbManager executeQuery:query];
    
    if (self.dbManager.statusRunQuery) {
        DLog(@"deleteFrom Table %@ Success",tableName);
    }else{
        DLog(@"deleteFrom Table %@ Failure",tableName);
    }
    
}

#pragma mark select Data

-(NSArray*)selectAllDataFromTable: (NSString*)tableName{
    NSString *query = [NSString stringWithFormat: @"select * from %@",tableName];
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    NSLog(@"%@",results);
    return results;
}

-(NSArray*)selectDataUseKey:(NSString*)tableName primaryKey:(NSString*)primaryKey primaryKeyValue:(NSString *)primaryKeyValue{
    NSString *query = [NSString stringWithFormat:@"select * from %@ where %@=%@",tableName, primaryKey,primaryKeyValue];
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    NSLog(@"%@",results);
    return results;
}

- (NSArray*)selectDataUseLike:(NSString*)tableName column:(NSString*)column likeValue:(NSString*)likeValue {
    NSString *query = [NSString stringWithFormat:@"select * from %@ where %@ like '%@%@%@'",tableName,column,@"%",likeValue,@"%"];
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    NSLog(@"%@",results);
    return results;
}


- (NSArray*)loadNameTable{
    NSString *query = @"SELECT name FROM sqlite_master WHERE type='table'";
    NSArray *arrayName = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    NSLog(@"%@",arrayName);
    return arrayName;
}

@end
