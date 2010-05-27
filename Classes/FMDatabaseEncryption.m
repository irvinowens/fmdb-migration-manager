//
//  FMDatabaseEncryption.m
//  iChartv1
//
//  Created by Eden, Peter on 10/22/09.
//  Copyright 2009 Epocrates. All rights reserved.
//

#import "FMDatabaseEncryption.h"
#import "IChartConstants.h"
#import "EEStorageManager.h"

@implementation FMResultSet(NonNullAdditions)

- (NSString*) nonNullStringForColumnIndex:(int)columnIdx
{
	NSString* ret = [self stringForColumnIndex: columnIdx];
	if ( ret == nil)
		ret = kEmptyString;
	return ret;
}
- (NSString*) nonNullStringForColumn:(NSString*)columnName
{
	NSString* ret = [self stringForColumn: columnName];
	if ( ret == nil)
		ret = kEmptyString;
	return ret;
}



@end


@implementation FMDatabase(EncryptionAdditions)

/**
 * Open a new database that is encrypted
 * @param pathToDb The path to the encrypted database on the filesystem, should be an absolute path
 * @returns a boolean value true indicating a successful open, false indicating a failed opening
 */
- (BOOL)openWithEncryptionAtPath:(NSString *)pathToDb
{
	databasePath = pathToDb;
	BOOL bRet = [self open];
	
	if ( bRet)
	{
		[self setBusyRetryTimeout: 25]; // in seconds
	}
	NSString* key = [[EEStorageManager sharedStorageManager] getDatabaseEncryptionKey];
	NSString* pragma = [NSString stringWithFormat:@"PRAGMA key = \"x'%@'\";", key];
	sqlite3_exec(db, [pragma UTF8String], NULL, NULL, NULL);
	sqlite3_exec(db, "PRAGMA locking_mode=EXCLUSIVE", NULL, NULL, NULL);	
	return bRet;
}


- (BOOL) openWithEncryption
{
	BOOL bRet = [self open];
	
	if ( bRet)
	{
		[self setBusyRetryTimeout: 25]; // in seconds
	}
#ifndef DO_NOT_ENCRYPT	
	
	if ( bRet && [databasePath hasSuffix: @"pdoc.db.en"] )
	{
		NSString* key = [[EEStorageManager sharedStorageManager] getDatabaseEncryptionKey];
		NSString* pragma = [NSString stringWithFormat:@"PRAGMA key = \"x'%@'\";", key];
		sqlite3_exec(db, [pragma UTF8String], NULL, NULL, NULL);
		sqlite3_exec(db, "PRAGMA locking_mode=EXCLUSIVE", NULL, NULL, NULL);
	}
#else	

#warning *** FMDatabaseEncryption encryption turned off

#endif 	
	return bRet;
}

+ (NSString*) escapeSingleQuotes: (NSString*) inString
{
	if ([inString rangeOfString:@"'"].length == 0 )
	{
		return inString;
	}
	
	return [inString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
}



@end
