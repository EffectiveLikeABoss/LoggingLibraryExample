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

#import "LoggingLibrary+Gateway.h"

@implementation LoggingLibrary(Gateway)

NSString * const LOGGING_LIBRARY_DATA_BASE_NAME=@"LoggingLibrary.db";

NSString * const LOGGING_LIBRARY_CREATE_TABLE=@""
"   CREATE TABLE IF NOT EXISTS \"logs\" ("
"       `log_id`INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,"
"       `type` INTEGER NOT NULL,"
"       `title` TEXT NOT NULL,"
"       `message` TEXT NOT NULL,"
"       `created_date` NUMERIC NOT NULL"
"   );";

NSString * const LOGGING_LIBRARY_INSERT=@""
"   INSERT INTO logs "
"       (type, title, message, created_date) VALUES "
"       (?,?,?,CURRENT_TIMESTAMP);";

NSString * const LOGGING_LIBRARY_ALL_SEARCH=@""
"   SELECT log_id, type, title, message, created_date FROM logs ORDER BY datetime(created_date) DESC";

NSString * const LOGGING_LIBRARY_TYPE_SEARCH=@""
"   SELECT log_id, type, title, message, created_date FROM logs WHERE type=? ORDER BY datetime(created_date) DESC";

+(int)insertLLSingleLog:(LLSingleLog*)singleLog databasePath:(NSString*)databasePath{
    int affectedRows=0;
    
    // Create a sqlite object.
    sqlite3 *sqlite3Database;
    
    // Open the database.
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        // Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
        sqlite3_stmt *compiledStatement;
        
        // Load all data from database to memory.
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, [LOGGING_LIBRARY_INSERT UTF8String], -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            
            int result=sqlite3_bind_text(compiledStatement, 1, [singleLog.type UTF8String], -1, NULL);
            if(result != SQLITE_OK) {
                NSLog(@"Error on binding singleLog.type");
                NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
            }
            
            result=sqlite3_bind_text(compiledStatement, 2, [singleLog.title UTF8String], -1, NULL);
            if(result != SQLITE_OK) {
                NSLog(@"Error on binding singleLog.title");
                NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
            }
            
            result=sqlite3_bind_text(compiledStatement, 3, [singleLog.message UTF8String], -1, NULL);
            if(result != SQLITE_OK) {
                NSLog(@"Error on binding singleLog.message");
                NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
            }
            
            if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
                // Keep the affected rows.
                affectedRows = sqlite3_changes(sqlite3Database);
                
            } else {
                NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
            }
            
        } else {
            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        }
        
        // Release the compiled statement from memory.
        sqlite3_finalize(compiledStatement);
    }
    
    // Close the database.
    sqlite3_close(sqlite3Database);
    
    return affectedRows;
}

+(NSArray<LLSingleLog*>*)runSelectQueryOnDatabasePath:(NSString*)databasePath logType:(NSString*)logType {
    // Create a sqlite object.
    sqlite3 *sqlite3Database;
    
    NSMutableArray *arrResults = [[NSMutableArray alloc] init];
    
    const char *query;
    if (logType) {
        query=[LOGGING_LIBRARY_TYPE_SEARCH UTF8String];
    } else {
        query=[LOGGING_LIBRARY_ALL_SEARCH UTF8String];
    }
    
    
    // Open the database.
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK) {
        sqlite3_stmt *compiledStatement;
        
        // Load all data from database to memory.
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK) {
            
            if (logType) {
                [LoggingLibrary bindString:compiledStatement columnIndex:1 value:logType];
            }
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                LLSingleLog *dataRow=[LoggingLibrary fillSingleLogWithStatement:compiledStatement];
                
                if (dataRow) {
                    [arrResults addObject:dataRow];
                }
            }
            
        } else {
            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        }
        
        // Release the compiled statement from memory.
        sqlite3_finalize(compiledStatement);
    }
    
    // Close the database.
    sqlite3_close(sqlite3Database);
    
    return arrResults;
}

+(LLSingleLog*)fillSingleLogWithStatement:(sqlite3_stmt*)statement{
    LLSingleLog  *dataRow = [[LLSingleLog alloc] init];
    
    dataRow.logId=[LoggingLibrary getInt:statement columnIndex:0];
    
    dataRow.type=[LoggingLibrary getString:statement columnIndex:1];
    
    dataRow.title=[LoggingLibrary getString:statement columnIndex:2];
    
    dataRow.message=[LoggingLibrary getString:statement columnIndex:3];
    
    dataRow.createdDate=[LoggingLibrary getString:statement columnIndex:4];
    
    return dataRow;
}

+(NSNumber*)getInt:(sqlite3_stmt*)statement columnIndex:(int)i{
    char *dbDataAsChars = (char *)sqlite3_column_text(statement, i);
    
    // If there are contents in the currenct column (field) then add them to the current row array.
    if (dbDataAsChars != NULL && sqlite3_column_type(statement, i) != SQLITE_NULL) {
        return [NSNumber numberWithInt: sqlite3_column_int(statement, i)];
    }
    return nil;
}

+(NSString*)getString:(sqlite3_stmt*)statement columnIndex:(int)i{
    char *dbDataAsChars = (char *)sqlite3_column_text(statement, i);
    
    // If there are contents in the currenct column (field) then add them to the current row array.
    if (dbDataAsChars != NULL && sqlite3_column_type(statement, i) != SQLITE_NULL) {
        return [NSString stringWithUTF8String:dbDataAsChars];
    }
    return nil;
}

+(BOOL)bindString:(sqlite3_stmt*)statement columnIndex:(int)i value:(NSString*)value{
    if (!value) {
        return (sqlite3_bind_null(statement, i) == SQLITE_OK);
    }
    return (sqlite3_bind_text(statement, i, [value UTF8String], -1, NULL) == SQLITE_OK);
}

@end
