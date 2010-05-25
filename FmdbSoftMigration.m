//
//  FmdbSoftMigration.m
//  EEStorageFramework
//
//  Created by iowens on 5/24/10.
//  Copyright 2010 Epocrates. All rights reserved.
//

#import "FmdbSoftMigration.h"


@implementation FmdbSoftMigration

- (void)doSoftMigrateWithSchema:(NSDictionary *)schemaDictionary andVersion:(NSUInteger)migrationVersion onDatabase:(FMDatabase *)db
{
	
}

- (void)getLatestMigrationVersion
{
	
}

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

@end
