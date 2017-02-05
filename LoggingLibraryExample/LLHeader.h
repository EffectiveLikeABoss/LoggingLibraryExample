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


#ifndef LLHeader_h
#define LLHeader_h

// if we don't want logging just comment the next line
#define USE_LOGGING_LIBRARY



#ifdef USE_LOGGING_LIBRARY

#import "LoggingLibrary.h"

// insert logs into database
#define LOGGING_LIBRARY_LOG_TO_DATA_BASE            YES

//output logs to console
#define LOGGING_LIBRARY_LOG_ERROR_TO_CONSOLE        YES
#define LOGGING_LIBRARY_LOG_INFO_TO_CONSOLE         YES
#define LOGGING_LIBRARY_LOG_CHECKPOINT_TO_CONSOLE   YES


/**
 * Insert a new error log entry
 * @author David Costa Gonçalves
 *
 * @param t title
 * @param m message
 */
#define LLError(t,m) callLoggingLibrary(t,m,LOGGING_LIBRARY_ERROR,LOGGING_LIBRARY_LOG_ERROR_TO_CONSOLE)

/**
 * Insert a new formatted error log entry
 * @author David Costa Gonçalves
 *
 * @param t title
 * @param m message
 */
#define LLFormatedError(t,m,...) callLoggingLibrary(t,[NSString stringWithFormat:(m), ##__VA_ARGS__],LOGGING_LIBRARY_ERROR,LOGGING_LIBRARY_LOG_ERROR_TO_CONSOLE)

/**
 * Insert a new information log entry
 * @author David Costa Gonçalves
 *
 * @param t title
 * @param m message
 */
#define LLInfo(t,m) callLoggingLibrary(t,m,LOGGING_LIBRARY_INFO,LOGGING_LIBRARY_LOG_INFO_TO_CONSOLE)

/**
 * Insert a new formatted information log entry
 * @author David Costa Gonçalves
 *
 * @param t title
 * @param m message
 */
#define LLFormatedInfo(t,m,...) callLoggingLibrary(t,[NSString stringWithFormat:(m), ##__VA_ARGS__],LOGGING_LIBRARY_INFO,LOGGING_LIBRARY_LOG_INFO_TO_CONSOLE)

/**
 * Insert a new checkpoint log entry
 * @author David Costa Gonçalves
 *
 * @param t title
 * @param m message
 */
#define LLCheck(t,m) callLoggingLibrary(t,m,LOGGING_LIBRARY_CHECK,LOGGING_LIBRARY_LOG_CHECKPOINT_TO_CONSOLE)

/**
 * Insert a new formatted checkpoint log entry
 * @author David Costa Gonçalves
 *
 * @param t title
 * @param m message
 */
#define LLFormatedCheck(t,m,...) callLoggingLibrary(t,[NSString stringWithFormat:(m), ##__VA_ARGS__],LOGGING_LIBRARY_CHECK,LOGGING_LIBRARY_LOG_CHECKPOINT_TO_CONSOLE)


static inline void callLoggingLibrary(NSString *title, id message, NSString *type, BOOL logConsole) {
    NSString *stringMessage=[message description];
    
    [LoggingLibrary logMessage:stringMessage withTitle:title withType:type completionHandler:^(BOOL success) {
        if (success && logConsole) {
            NSLog(@"%@\t%@\t\t%@", type, title, stringMessage);
        }
        if (!success) {
            NSLog(@"ERROR LOGGING MESSAGE '%@\t%@\t\t%@'", type, title, stringMessage);
        }
    }];
}

#else


#define LLError(t,m)

#define LLFormatedError(t,m,...)

#define LLInfo(t,m)

#define LLFormatedInfo(t,m,...)

#define LLCheck(t,m)

#define LLFormatedCheck(t,m,...)


#endif



#endif /* LLHeader_h */
