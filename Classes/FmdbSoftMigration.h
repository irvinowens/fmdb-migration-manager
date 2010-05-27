//
//  FmdbSoftMigration.h
//  EEStorageFramework
//
//  Created by iowens on 5/24/10.
//  Copyright 2010 Epocrates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FmdbMigration.h"
#import "FmdbMigrationManager.h"
#import "FmdbSoftMigrationOperation.h"

/**
 * The soft migration object.
 * Will perform a migration against an arbitrary database table with a given dictionary
 * the dictionary should look like this { tableName: "name", columns : [ { columnName : "colName", columnType : "colType", defaultValue: 0, removeColumn : 0  } ], createTable : 0 }
 * in cocoa vernacular, the object should be structured in a dictionary, the dictionary should contain an array, 
 * and the array should contain dictionaries with keys columnName, columnType, defaultValue, and removeColumn all fields are mandatory, defaultValue can be nil
 * the createTable field if 0, the migration will not try to create the table, if it is a non-zero value, then it will
 * based on the remove column value, non-zero means add column, non-zero means remove column
 */

@interface FmdbSoftMigration : FmdbMigration {
	NSDictionary *schema;
	NSUInteger databaseMigrationVersion;
}

/**
 * The dictionary describing the table
 */

@property (nonatomic, retain) NSDictionary *schema;

/**
 * The version for the migration
 */

@property (nonatomic, assign) NSUInteger databaseMigrationVersion;

/**
 * Return a soft migration with a pre-archive migration dictionary.
 * This method is useful for the run migrations method in the migration manager.  It allows the manager to
 * recover a saved migration dictionary to use when running the up or down migrations
 * @returns (id) an instance of this soft migration with schema loaded
 * @param (NSUInteger)migrationVersion The version to which this soft migration should be initialized
 */

+ (id)migrationWithDatabaseVersion:(NSUInteger)migrationVersion;

/**
 * To perform an on-demand migration of the database and initialize the soft migration object.
 * This will initialize the soft schema object and archive this migration's schema for later use or rollback, etc...
 * @param (NSDictionary *)dbSchema The dictionary of the schema, should specify key : column_name, value : type ( Integer, text, etc )
 * @param (NSUInteger)migrationVersion A version for the soft migration, to indicate in which order it should be evaluated
 * @param (FMDatabase *)database The database against which to run the migration
 */

- (id)initAndArchiveSchemaWithDatabase:(FMDatabase *)database andSchema:(NSDictionary *)dbSchema andVersion:(NSUInteger)migrationVersion;

/**
 * Method to get the latest migration version from the FmdbMigrationManager
 */

- (NSInteger)getLatestMigrationVersion;

/**
 * Save migration instance object heirarchy to disk for later use.
 * Will save the migration to disk, using the version.migration for its key.
 * WARNING: This will overwrite any existing migrations you have of that version.  Hard migrations with the same version number will
 * take precedence.
 * @param (NSDictionary *)dictionary The migration dictionary to use
 * @param (NSUInteger)version The version of the migration
 */

- (void)archiveMigrationWithDictionary:(NSDictionary *)dictionary andVersion:(NSUInteger)version;

/**
 * Restore migration into its dictionary form.
 * Restores an archived migration back to its natural form
 * @returns (NSDictionary *) A dictionary encapsulating a migration of a given version
 */

- (NSDictionary *)restoreMigrationDictionaryWithVersion:(NSUInteger)version;

/**
 * Create the migration folder if it doesn't exist.
 * Will create a folder in which to keep the archived soft migrations if it doesn't exist
 */

- (void)createMigrationArchivingFolderIfNotExists;

/**
 * Safely get the portable user folder with the migration folder as a string.
 * @returns (NSString *) portable user folder with the migration folder
 */

- (NSString *)safelyGetMigrationsFolder;

@end
