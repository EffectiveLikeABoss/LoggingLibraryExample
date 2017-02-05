# LoggingLibraryExample
Using DISPATCH_QUEUE_SERIAL and #define to create a logging system

# Usuage
```
LOGGING_LIBRARY_ERROR //constant
LLError(@"t", @"m"); // logs a error
LLFormatedError(@"title", @"message %d", 3);
```
```
LOGGING_LIBRARY_INFO constant

LLInfo(@"t", @"m"); // logs a information

LLFormatedInfo(@"title", @"message %d", 55);
```
```
LOGGING_LIBRARY_CHECK constant

LLCheck(@"t", @"m"); // logs a checkpoint

LLFormatedCheck(@"title", @"message %d", 8);
```

**To retrieve all logs**
```
[LoggingLibrary selectAllLogsCompletionHandler:^(NSArray<LLSingleLog *> *logs) {

}];
```

**To retrieve all logs from a specific type**
```
[LoggingLibrary selectLogsOfType:LOGGING_LIBRARY_CHECK completionHandler:^(NSArray<LLSingleLog *> *logs) {

}];
```
