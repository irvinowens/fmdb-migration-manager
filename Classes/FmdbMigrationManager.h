//
//  FmdbMigrationManager.h
//  FmdbMigrationManager
//
//  Created by Dr Nic Williams on 2008-09-06.
//  Copyright 2008 Mocra and Dr Nic Williams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FmdbSoftMigration.h"
#import "FmdbMigration.h"
#import "FmdbMigrationColumn.h"
#import "FMResultSet.h"


@interface FmdbMigrationManager : NSObject {
	FMDatabase *db_;
	NSArray *migrations_;
	NSInteger currentVersion_;
	NSString *schemaMigrationsTableName_;
}
@property (retain) FMDatabase *db;
@property (retain) NSArray *migrations;
@property (assign,readonly) NSInteger currentVersion;
@property (readonly) NSString *schemaMigrationsTableName;

/**
 * Performs migration against database regardless of version.
 * @returns (id) an instance of itself
 * @param (NSString *)aPath The path to the database
 * @param (NSArray *)migrations The migrations to perform agasint the database
 */

+ (id)executeForDatabasePath:(NSString *)aPath withMigrations:(NSArray *)migrations;

- (id)initWithDatabasePath:(NSString *)aPath;
- (void)executeMigrations;

#pragma mark -
#pragma mark Internal methods

- (void)initializeSchemaMigrationsTable;

/**
 * Perform provided migration stack against the database if applicable.
 * It is assumed that if you have any soft migrations, they will at this point be archived
 */

- (void)performMigrations;
- (void)recordVersionStateAfterMigrating:(NSInteger)version;

#pragma mark -
#pragma mark Migration up to a defined version

/**
 * Performs migration against database up to a specific version.
 * @returns (id) an instance of itself
 * @param (NSString *)aPath The path to the database
 * @param (NSArray *)migrations The migrations to perform agasint the database
 * @param (NSInteger *)aVersion The version of the database to migrate to
 */

+ (id)executeForDatabasePath:(NSString *)aPath withMigrations:(NSArray *)migrations andMatchVersion:(NSInteger)aVersion;
- (void)executeMigrationsAndMatchVersion:(NSInteger)aVersion;
- (void)performMigrationsAndMatchVersion:(NSInteger)aVersion;
@end
