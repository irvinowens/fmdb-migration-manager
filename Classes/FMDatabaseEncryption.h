//
//  FMDatabaseEncryption.h
//  iChartv1
//
//  Created by Eden, Peter on 10/22/09.
//  Copyright 2009 Epocrates. All rights reserved.
//

#import "FMDatabase.h"

/**
 * Forward declaration of the storage manager
 */

@class EEStorageManager;

@interface  FMResultSet(NonNullAdditions)

- (NSString*) nonNullStringForColumnIndex:(int)columnIdx;
- (NSString*) nonNullStringForColumn:(NSString*)columnName;

@end


@interface FMDatabase(EncryptionAdditions)

- (BOOL) openWithEncryption;
+ (NSString*) escapeSingleQuotes: (NSString*) inString;

@end
