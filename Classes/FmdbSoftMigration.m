//
//  FmdbSoftMigration.m
//  EEStorageFramework
//
//  Created by iowens on 5/24/10.
//  Copyright 2010 Epocrates. All rights reserved.
//

#import "FmdbSoftMigration.h"


@implementation FmdbSoftMigration

@synthesize schema, databaseMigrationVersion;

+ (id)migrationWithDatabaseVersion:(NSUInteger)migrationVersion 
{
	FmdbSoftMigration *migration = (FmdbSoftMigration *)[[[FmdbSoftMigration alloc] init] autorelease];
	[migration setDatabaseMigrationVersion : migrationVersion];
	[migration setSchema : [migration restoreMigrationDictionaryWithVersion:migration.databaseMigrationVersion]];
	if(migration.schema == nil)
	{
		NSException *myException = [NSException exceptionWithName:@"NoSchemaByThatVersionArchivedException" 
														   reason:@"The soft migration could not find a migration dictionary for the given version" 
														 userInfo:nil];
		[myException raise];
	}
	return migration;
}

- (id)initAndArchiveSchemaWithDatabase:(FMDatabase *)database andSchema:(NSDictionary *)dbSchema andVersion:(NSUInteger)migrationVersion
{
	if(self = [super initWithDatabase:database])
	{
		self.schema = dbSchema;
		NSLog(@"Schema: %@",self.schema);
		self.databaseMigrationVersion = migrationVersion;
		[self archiveMigrationWithDictionary:self.schema andVersion:self.databaseMigrationVersion];
	}
	return self;
}

- (NSInteger)getLatestMigrationVersion
{
	NSInteger migrationVersion = -1;
	FmdbMigrationManager *mgr = [[FmdbMigrationManager alloc] initWithDatabasePath:[self.db databasePath]];
	migrationVersion = [mgr currentVersion];
	[mgr release];
	return migrationVersion;
}

#pragma mark up/down methods

- (void)up
{
	// define op for later use basically everywhere
	FmdbSoftMigrationOperation *op = nil;
	if(self.schema == nil)
	{
		NSException* myException = [NSException
									exceptionWithName:@"SchemaNotDefinedException"
									reason:@"The schema was not defined.  The up migration can not continue"
									userInfo:nil];
		[myException raise];
	}
	NSInteger migrationVersion = [self getLatestMigrationVersion];
	if(migrationVersion > self.databaseMigrationVersion)
	{
		NSException *myException = [NSException
									exceptionWithName:@"VersionTooLowException" 
									reason:@"The migration you wish to run is below the current database migration level"
									userInfo:nil];
		[myException raise];
	}
	NSMutableArray *columnArray = [NSMutableArray arrayWithCapacity:5];
	NSString *tableName = nil;
	NSString *str = nil;
	if([self.schema objectForKey:@"tableName"] == nil ||
	   [self.schema objectForKey:@"tableName"] == [NSNull null])
	{
		NSException *myException = [NSException
									exceptionWithName:@"TableNameNotDefinedException" 
									reason:@"The table name for this migration is not defined" 
									userInfo:nil];
		[myException raise];
	}
	for(str in self.schema)
	{
		if([str isEqualToString:@"tableName"])
		{
			tableName = [self.schema objectForKey:str];
		}
		else if([str isEqualToString:@"columns"])
		{
			NSDictionary *columnDict = nil;
			for(columnDict in [self.schema objectForKey:str])
			{
				FmdbMigrationColumn *col = [FmdbMigrationColumn columnWithColumnName:[columnDict objectForKey:@"columnName"] 
																		  columnType:[columnDict objectForKey:@"columnType"] 
																		defaultValue:[columnDict objectForKey:@"defaultValue"]];
				op = [[FmdbSoftMigrationOperation alloc] init];
				[op setColumn:col];
				[op setDoCreateColumn:[[columnDict objectForKey:@"removeColumn"] boolValue]];
				[columnArray addObject:op];
				[op release];
			}
		}
	}
	if([[self.schema objectForKey:@"createTable"] boolValue] == YES)
	{
		NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
		for(op in columnArray)
		{
			[arr addObject:[op column]];
		}
		[self createTable:tableName withColumns:arr];
	}else{
		for(op in columnArray)
		{
			[self addColumn:[op column] forTableName:tableName];
		}
	}
	NSLog(@"Up migration against %@ completed",tableName);
	//NSLog([NSString stringWithFormat:@"%s: -up method not implemented", NSStringFromClass([self class])]);
}

- (void)down 
{
	if(self.schema == nil)
	{
		NSException* myException = [NSException
									exceptionWithName:@"SchemaNotDefinedException"
									reason:@"The schema was not defined.  The up migration can not continue"
									userInfo:nil];
		[myException raise];
	}
	NSInteger migrationVersion = [self getLatestMigrationVersion];
	if(migrationVersion < self.databaseMigrationVersion)
	{
		NSException *myException = [NSException
									exceptionWithName:@"VersionTooLowException" 
									reason:@"The migration you wish to run is below the current database migration level"
									userInfo:nil];
		[myException raise];
	}
	if([self.schema objectForKey:@"tableName"] == nil ||
	   [self.schema objectForKey:@"tableName"] == [NSNull null])
	{
		NSException *myException = [NSException
									exceptionWithName:@"TableNameNotDefinedException" 
									reason:@"The table name for this migration is not defined" 
									userInfo:nil];
		[myException raise];
	}
	NSArray *columns = nil;
	NSString *tableName = [self.schema objectForKey:@"tableName"];
	if([[self.schema objectForKey:@"createTable"] boolValue] == YES)
	{
		[self dropTable:tableName];
	}else{
		columns = [self.schema objectForKey:@"columns"];
		NSDictionary * column = nil;
		for(column in columns)
		{
			FmdbMigrationColumn *col = [FmdbMigrationColumn columnWithColumnName:[column objectForKey:@"columnName"] 
																	  columnType:[column objectForKey:@"columnType"] 
																	defaultValue:[column objectForKey:@"defaultValue"]];
			[self dropColumn:col forTableName:tableName];
		}
	}
	NSLog(@"Down Migration Against %@ completed",tableName);
	//NSLog([NSString stringWithFormat:@"%s: -down method not implemented", NSStringFromClass([self class])]);
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

#pragma mark Begin dictionary archiving methods

- (void)archiveMigrationWithDictionary:(NSDictionary *)dictionary andVersion:(NSUInteger)version
{
	// don't forget to use the NSKeyedUnarchiver below to get it out...
	NSString *pathKey = [NSString stringWithFormat:@"%@.migration",[[NSNumber numberWithInt:version] stringValue]];
	BOOL result = [NSKeyedArchiver archiveRootObject:dictionary
										 toFile:[[self safelyGetMigrationsFolder] stringByAppendingPathComponent:pathKey]];
	if(result == NO)
	{
		NSException *exc = [NSException exceptionWithName:@"ArchiveOperationFailedException" 
												   reason:@"We failed to create your archive, the migration was not persisted" 
												 userInfo:nil];
		[exc raise];
	}
}

- (NSDictionary *)restoreMigrationDictionaryWithVersion:(NSUInteger)version
{
	NSString *pathKey = [NSString stringWithFormat:@"%@.migration",[[NSNumber numberWithInt:version] stringValue]];
	NSDictionary *dict = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithFile:[[self safelyGetMigrationsFolder] stringByAppendingPathComponent:pathKey]];
	return dict;
}

- (void)createMigrationArchivingFolderIfNotExists
{
	NSString *userDocsFolderMigrations = [self safelyGetMigrationsFolder];
	BOOL migrationFolderExists = NO;
	if([[NSFileManager defaultManager] fileExistsAtPath:userDocsFolderMigrations isDirectory:&migrationFolderExists] && !migrationFolderExists)
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:userDocsFolderMigrations attributes:nil];
	}
}

- (NSString *)safelyGetMigrationsFolder
{
	NSArray *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *userDocsFolderMigrations = [[docsDir objectAtIndex:0] stringByAppendingPathComponent:@"migration_archive"];
	BOOL migrationArchiveDirectoryExists = NO;
	[[NSFileManager defaultManager] fileExistsAtPath:userDocsFolderMigrations isDirectory:&migrationArchiveDirectoryExists];
	if(migrationArchiveDirectoryExists == NO)
	{
		NSLog(@"Whoa! The docs directory you are looking for doesn't exist, let me create it for you");
		[[NSFileManager defaultManager] createDirectoryAtPath:userDocsFolderMigrations attributes:nil];
	}
	return userDocsFolderMigrations;
}

#pragma mark End dictionary archiving methods

#pragma mark -

- (void)dealloc
{
	[schema release];
	[super dealloc];
}

@end
