//
//  Tests.m
//  Tests
//
//  Created by David Costa Gonçalves on 04/02/17.
//  Copyright © 2017 Effective Like ABoss. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LLHeader.h"

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp {
    [super setUp];
    XCTestExpectation *expectation=[self expectationWithDescription:@"clean db"];
    [LoggingLibrary deleteLogCacheCompletionHandler:^(BOOL success) {
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testErrors {
    LLError(@"t", @"m");
    XCTestExpectation *expectationLLError=[self expectationWithDescription:@"LLError"];
    [LoggingLibrary selectLogsOfType:LOGGING_LIBRARY_ERROR completionHandler:^(NSArray<LLSingleLog *> *logs) {
        XCTAssertEqual(logs.count, (NSUInteger)1);
        
        LLSingleLog *log=[logs objectAtIndex:0];
        
        XCTAssertEqualObjects(log.type, LOGGING_LIBRARY_ERROR);
        XCTAssertEqualObjects(log.title, @"t");
        XCTAssertEqualObjects(log.message, @"m");
        
        [expectationLLError fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
    
    LLFormatedError(@"title", @"message %d", 3);
    XCTestExpectation *expectationLLFormatedError=[self expectationWithDescription:@"LLFormatedError"];
    [LoggingLibrary selectLogsOfType:LOGGING_LIBRARY_ERROR completionHandler:^(NSArray<LLSingleLog *> *logs) {
        XCTAssertEqual(logs.count, (NSUInteger)2);
        
        LLSingleLog *log=[logs objectAtIndex:1];
        
        XCTAssertEqualObjects(log.type, LOGGING_LIBRARY_ERROR);
        XCTAssertEqualObjects(log.title, @"title");
        XCTAssertEqualObjects(log.message, @"message 3");

        [expectationLLFormatedError fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testInformation {
    LLInfo(@"t", @"m");
    XCTestExpectation *expectationLLError=[self expectationWithDescription:@"LLInfo"];
    [LoggingLibrary selectLogsOfType:LOGGING_LIBRARY_INFO completionHandler:^(NSArray<LLSingleLog *> *logs) {
        XCTAssertEqual(logs.count, (NSUInteger)1);
        
        LLSingleLog *log=[logs objectAtIndex:0];
        
        XCTAssertEqualObjects(log.type, LOGGING_LIBRARY_INFO);
        XCTAssertEqualObjects(log.title, @"t");
        XCTAssertEqualObjects(log.message, @"m");
        
        [expectationLLError fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
    
    
    LLFormatedInfo(@"title", @"message %d", 55);
    XCTestExpectation *expectationLLFormatedError=[self expectationWithDescription:@"LLFormatedInfo"];
    [LoggingLibrary selectLogsOfType:LOGGING_LIBRARY_INFO completionHandler:^(NSArray<LLSingleLog *> *logs) {
        XCTAssertEqual(logs.count, (NSUInteger)2);
        
        LLSingleLog *log=[logs objectAtIndex:1];
        
        XCTAssertEqualObjects(log.type, LOGGING_LIBRARY_INFO);
        XCTAssertEqualObjects(log.title, @"title");
        XCTAssertEqualObjects(log.message, @"message 55");
        
        [expectationLLFormatedError fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testCheckPoints {
    LLCheck(@"t", @"m");
    XCTestExpectation *expectationLLError=[self expectationWithDescription:@"LLCheck"];
    [LoggingLibrary selectLogsOfType:LOGGING_LIBRARY_CHECK completionHandler:^(NSArray<LLSingleLog *> *logs) {
        XCTAssertEqual(logs.count, (NSUInteger)1);
        
        LLSingleLog *log=[logs objectAtIndex:0];
        
        XCTAssertEqualObjects(log.type, LOGGING_LIBRARY_CHECK);
        XCTAssertEqualObjects(log.title, @"t");
        XCTAssertEqualObjects(log.message, @"m");
        
        [expectationLLError fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
    
    
    LLFormatedCheck(@"title", @"message %d", 8);
    XCTestExpectation *expectationLLFormatedError=[self expectationWithDescription:@"LLFormatedCheck"];
    [LoggingLibrary selectLogsOfType:LOGGING_LIBRARY_CHECK completionHandler:^(NSArray<LLSingleLog *> *logs) {
        XCTAssertEqual(logs.count, (NSUInteger)2);
        
        LLSingleLog *log=[logs objectAtIndex:1];
        
        XCTAssertEqualObjects(log.type, LOGGING_LIBRARY_CHECK);
        XCTAssertEqualObjects(log.title, @"title");
        XCTAssertEqualObjects(log.message, @"message 8");
        
        [expectationLLFormatedError fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

@end
