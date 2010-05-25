//
//  FmdbSoftMigration.h
//  EEStorageFramework
//
//  Created by iowens on 5/24/10.
//  Copyright 2010 Epocrates. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FmdbSoftMigration : FmdbMigration {

}

/**
 * To perform an on-demand migration of the database.
 * This will perform a migration of the database and archive this migration's schema for later use or rollback, etc...
 * @param (NSDictionary *)schemaDictionary The dictionary of the schema, should specify key : column_name, value : type ( Integer, text, etc )
 * @param (NSUInteger)migrationVersion A version for the soft migration, to indicate in which order it should be evaluated
 * @param (FMDatabase *)db The database against which to run the migration
 */

- (void)doSoftMigrateWithSchema:(NSDictionary *)schemaDictionary andVersion:(NSUInteger)migrationVersion onDatabase:(FMDatabase *)db;

/**
 * Method to get the latest migration version from the FmdbMigrationManager
 */

- (void)getLatestMigrationVersion;

@end
