//
//  FmdbSoftMigrationOperation.h
//  EEStorageFramework
//
//  Created by iowens on 5/25/10.
//  Copyright 2010 Epocrates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FmdbMigrationColumn.h"
/**
 * To define a single soft migration operation.
 * Will be used to define what operation should happen to a table when using
 * soft migrations.
 */

@interface FmdbSoftMigrationOperation : NSObject {
	FmdbMigrationColumn *column;
	BOOL doCreateColumn;
}

/**
 * The name of the column being effected
 */

@property (nonatomic, retain) FmdbMigrationColumn *column;

/**
 * Are we to create the column or are we going to delete the column
 */

@property (nonatomic, assign) BOOL doCreateColumn;

@end
