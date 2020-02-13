//
//  HRAutoreleasePoolTests.m
//  HRAutoreleasePoolTests
//
//  Created by Dmitry Rykun on 2/7/20.
//  Copyright © 2020 Dmitry Rykun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AutoreleasePool.h"

#define let __auto_type const

@interface TestObject: NSObject
@end

@implementation TestObject

- (oneway void)release {
    [super release];
}

- (void)dealloc {
    // not calling [super dealloc] so instance is not deallocated and retainCount is accessible
}

@end


@interface HRAutoreleasePoolTests : XCTestCase
@end

@implementation HRAutoreleasePoolTests

- (void)setUp {
}

- (void)tearDown {
}

- (void)testMustSendReleaseForEveryAddedObject {
    let autoreleasePool = [AutoreleasePool new];
    let testObject = [TestObject new];
    let n = 5;
    let retainCountBefore = testObject.retainCount;
    for (int i = 0; i < n; i++) {
        [testObject retain];
        [testObject hrAutorelease];
    }
    XCTAssertEqual(testObject.retainCount, retainCountBefore + n);
    [autoreleasePool drain];
    XCTAssertEqual(testObject.retainCount, retainCountBefore);
}

- (void)testMustAddToTopmostPool {
    let autoreleasePool1 = [AutoreleasePool new];
    let testObject1 = [TestObject new];
    [testObject1 retain];
    [testObject1 hrAutorelease];
    let autoreleasePool2 = [AutoreleasePool new];
    let testObject2 = [TestObject new];
    [testObject2 retain];
    [testObject2 hrAutorelease];
    [autoreleasePool2 drain];
    [autoreleasePool1 drain];
    XCTAssertEqual(testObject1.retainCount, 1);
    XCTAssertEqual(testObject2.retainCount, 1);
}

- (void)testMustBeThreadSpecific {
    let expectation = [[XCTestExpectation alloc] initWithDescription:@"Autorelease on different threads"];
    expectation.expectedFulfillmentCount = 2;
    let block = ^{
        let autoreleasePool = [AutoreleasePool new];
        let testObject = [TestObject new];
        let n = 5;
        let retainCountBefore = testObject.retainCount;
        for (int i = 0; i < n; i++) {
            [testObject retain];
            [testObject hrAutorelease];
        }
        XCTAssertEqual(testObject.retainCount, retainCountBefore + n);
        [autoreleasePool drain];
        XCTAssertEqual(testObject.retainCount, retainCountBefore);
        [expectation fulfill];
    };
    let thread1 = [[NSThread alloc] initWithBlock:block];
    let thread2 = [[NSThread alloc] initWithBlock:block];
    [thread1 start];
    [thread2 start];
    let result = [XCTWaiter waitForExpectations:@[expectation] timeout:100];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
}

- (void)testMustDrainOnThreadTermination {
    let expectation = [[XCTestExpectation alloc] initWithDescription:@"Autorelease on different threads"];
    let testObject = [TestObject new];
    let retainCountBefore = testObject.retainCount;
    let n = 5;
    for (int i = 0; i < n; i++) {
        [testObject retain];
    }
    let block = ^{
        let autoreleasePool = [AutoreleasePool new];
        for (int i = 0; i < n; i++) {
            [testObject hrAutorelease];
        }
        [expectation fulfill];
    };
    let thread = [[NSThread alloc] initWithBlock:block];
    [thread start];
    let result = [XCTWaiter waitForExpectations:@[expectation] timeout:100];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
    XCTAssertEqual(testObject.retainCount, retainCountBefore);
}

@end
