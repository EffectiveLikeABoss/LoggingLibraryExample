//
//  This is free and unencumbered software released into the public domain.
//
//  Anyone is free to copy, modify, publish, use, compile, sell, or
//  distribute this software, either in source code form or as a compiled
//  binary, for any purpose, commercial or non-commercial, and by any
//  means.

//  In jurisdictions that recognize copyright laws, the author or authors
//  of this software dedicate any and all copyright interest in the
//  software to the public domain. We make this dedication for the benefit
//  of the public at large and to the detriment of our heirs and
//  successors. We intend this dedication to be an overt act of
//  relinquishment in perpetuity of all present and future rights to this
//  software under copyright law.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
//  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  For more information, please refer to <http://unlicense.org>
//
//  Created by Effective Like ABoss
//

#import "LoggingLibrary.h"
#import "LoggingLibrary+Gateway.h"
#import "LLHeader.h"

@implementation LoggingLibrary

NSString * const LOGGING_LIBRARY_ERROR = @"error";
NSString * const LOGGING_LIBRARY_INFO = @"info";
NSString * const LOGGING_LIBRARY_CHECK = @"check";

+(dispatch_queue_t)getQueue{
    static dispatch_queue_t logQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logQueue = dispatch_queue_create("com.effectivelikeaboss.logginglibraryexample", DISPATCH_QUEUE_SERIAL);
    });
    return logQueue;
}

+(void)logMessage:(NSString*)message withTitle:(NSString*)title withType:(NSString*)type completionHandler:(void(^)(BOOL success))completion{
    dispatch_async([LoggingLibrary getQueue], ^{
        NSString *dataBasePath=[LoggingLibrary checkForLoggingDatabasePath];
        if (dataBasePath) {
            LLSingleLog *log=[[LLSingleLog alloc] init];
            log.message=message;
            log.title=title;
            log.type=type;
            if (completion) {
                completion([LoggingLibrary insertLLSingleLog:log databasePath:dataBasePath] > 0);
            }
        } else if (completion) {
            completion(NO);
        }
    });
}

+(void)deleteLogCacheCompletionHandler:(void(^)(BOOL success))completion{
    dispatch_async([LoggingLibrary getQueue], ^{
        NSString *cacheExists=[LoggingLibrary checkForLoggingDatabasePath];
        if (cacheExists) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            BOOL success = [fileManager removeItemAtPath:cacheExists error:&error];
            if (!success) {
                LLFormatedError(@"LoggingLibrary", @"Could not delete file -:%@ ",error);
            }
            if (completion) {
                completion(success);
            }
        }
    });
}

+(void)selectAllLogsCompletionHandler:(void(^)(NSArray<LLSingleLog*>* logs))completion{
    dispatch_async([LoggingLibrary getQueue], ^{
        NSString *dataBasePath=[LoggingLibrary checkForLoggingDatabasePath];
        if (dataBasePath && dataBasePath.length!=0) {
            completion([LoggingLibrary runSelectQueryOnDatabasePath:dataBasePath logType:nil]);
        } else {
            completion(@[]);
        }
    });
}

+(void)selectLogsOfType:(NSString*)type completionHandler:(void(^)(NSArray<LLSingleLog*>* logs))completion{
    if (!completion) {
        return;
    }
    dispatch_async([LoggingLibrary getQueue], ^{
        NSString *dataBasePath=[LoggingLibrary checkForLoggingDatabasePath];
        if (dataBasePath && dataBasePath.length!=0) {
            completion([LoggingLibrary runSelectQueryOnDatabasePath:dataBasePath logType:type]);
        } else {
            completion(@[]);
        }
    });
}







#pragma mark Setup methods
+(NSString*)checkForLoggingDatabasePath{
    NSString *dataBasePath=[LoggingLibrary loggingDatabaseExists];
    if (!dataBasePath) {
        dataBasePath=[LoggingLibrary createLoggingDatabase];
        
    }
    return dataBasePath;
}

+(NSString*)loggingDatabaseExists{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc]initWithString:[documentsDirectory stringByAppendingPathComponent:LOGGING_LIBRARY_DATA_BASE_NAME]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        return databasePath;
    }
    return nil;
}

+(NSString*)createLoggingDatabase {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *databasePath = [[NSString alloc]initWithString:[documentsDirectory stringByAppendingPathComponent:LOGGING_LIBRARY_DATA_BASE_NAME]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath] == FALSE) {
        [LoggingLibrary createDataBase:databasePath createStatements:@[LOGGING_LIBRARY_CREATE_TABLE]];
    }
    
    return databasePath;
}

+(void)createDataBase:(NSString*)databasePath createStatements:(NSArray<NSString*>*)statements{
    sqlite3 *database;
    int openDatabaseResult = sqlite3_open([databasePath UTF8String], &database);
    
    if(openDatabaseResult == SQLITE_OK) {
        
        for (NSString *statement in statements) {
            const char *sqlStatement=[statement UTF8String];
            char *error;
            if(sqlite3_exec(database, sqlStatement, NULL, NULL, &error) != SQLITE_OK) {
                NSLog(@"error createDataBase '%s'", error);
                return;
            }
        }
        
    } else {
        NSLog(@"Error creating database '%@'", databasePath);
    }
    sqlite3_close(database);
}


@end
