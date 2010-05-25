//
//  FmdbMigrationColumn.m
//  fmdb-migration-manager
//
//  Created by Dr Nic on 6/09/08.
//  Modified by Irvin Owens Jr on 5/25/10
//

#import "FmdbMigration.h"


@implementation FmdbMigration
@synthesize db=db_;

+ (id)migration {
	return [[[self alloc] init] autorelease];
}

#pragma mark -
#pragma mark up/down methods

- (void)up 
{
	NSLog([NSString stringWithFormat:@"%s: -up method not implemented", NSStringFromClass([self class])]);
}

- (void)down 
{
	NSLog([NSString stringWithFormat:@"%s: -down method not implemented", NSStringFromClass([self class])]);
}

- (void)upWithDatabase:(FMDatabase *)db 
{
	self.db = db;
	[self up];
}
- (void)downWithDatabase:(FMDatabase *)db 
{
	self.db = db;
	[self down];
}

#pragma mark -
#pragma mark Helper methods for manipulating database schema

- (void)createTable:(NSString *)tableName withColumns:(NSArray *)columns 
{
	[self createTable:tableName];
	for (FmdbMigrationColumn *migrationColumn in columns) {
		[self addColumn:migrationColumn forTableName:tableName];
	}
}

- (void)createTable:(NSString *)tableName 
{
	NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id integer primary key autoincrement)", tableName];
	[db_ executeUpdate:sql];
}

- (void)dropTable:(NSString *)tableName 
{
	NSString *sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", tableName];
	[db_ executeUpdate:sql];
}

- (void)addColumn:(FmdbMigrationColumn *)column forTableName:(NSString *)tableName 
{
	NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@", tableName, [column sqlDefinition]];
	[db_ executeUpdate:sql];
}

- (void)dropColumn:(FmdbMigrationColumn *)column forTableName:(NSString *)tableName
{
	/**
	 BEGIN TRANSACTION;
	 CREATE TEMPORARY TABLE t1_backup(a,b);
	 INSERT INTO t1_backup SELECT a,b FROM t1;
	 DROP TABLE t1;
	 CREATE TABLE t1(a,b);
	 INSERT INTO t1 SELECT a,b FROM t1_backup;
	 DROP TABLE t1_backup;
	 COMMIT;
	 */
	NSMutableString *cols = [NSMutableString stringWithCapacity:10];
	NSMutableArray* tempCols = [NSMutableArray arrayWithCapacity:20];
	NSString* sqlString = [NSString stringWithFormat:@"PRAGMA table_info('%@')", tableName];
	FMResultSet* rs = [db_ executeQuery:sqlString];
	if ( rs != nil)
	{
		while ([rs next] )
		{
			[tempCols addObject:[ rs nonNullStringForColumn: @"name"]];
		}
	}else {
		NSLog(@"No columns exist in table %@, so dropping the column is not possible", tableName);
		return void;
	}
	
	[rs close];
	NSUInteger i, count = [tempCols count];
	for(i=0;i<count;i++)
	{
		if([[tempCols objectAtIndex:i] isEqualToString:[column columnName]] == NO)
		{
			[cols appendString:[tempCols objectAtIndex:i]];
		}
		if(i < (count - 1))
		{
			[cols appendString:@","];
		}
	}
	NSLog(@"table: %@\n%@", tableName, cols);
	NSString * sql = [NSString stringWithFormat:@"BEGIN TRANSACTION; \
					  CREATE TEMPORARY TABLE %@_backup(%@); \
					  INSERT INTO %@_backup SELECT %@ FROM %@; \
					  DROP TABLE %@; \
					  CREATE TABLE %@(%@); \
					  INSERT INTO %@ SELECT %@ FROM %@_backup; \
					  DROP TABLE %@_backup; \
					  COMMIT;",tableName,cols,tableName,cols,tableName,tableName,tableName,cols,tableName,cols,tableName,tableName];
	[db_ executeUpdate:sql];
}


#pragma mark -
#pragma mark Unit testing helpers

- (id)initWithDatabase:(FMDatabase *)db 
{
	if ([super init]) {
		self.db = db;
		return self;
	}
	return nil;
}

- (void)dealloc
{
	[db_ release];
	
	[super dealloc];
}


@end
