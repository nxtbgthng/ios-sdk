/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright 2014 Medium Entertainment, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 PHEventTest.m
 playhaven-sdk-ios

 Created by Anton Fedorchenko on 2/26/14.
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <SenTestingKit/SenTestingKit.h>
#import "PlayHavenSDK.h"
#import "JSON.h"

static NSString *const kPHTestEventPropertyKey1 = @"EventPropertyKey1";
static NSString *const kPHTestEventPropertyKey2 = @"EventPropertyKey2";
static NSString *const kPHTestEventPropertyKey3 = @"EventPropertyKey3";
static NSString *const kPHTestEventPropertyKey4 = @"EventPropertyKey4";
static NSString *const kPHTestEventPropertyKey5 = @"EventPropertyKey5";
static NSString *const kPHTestEventPropertyKey6 = @"EventPropertyKey6";
static NSString *const kPHTestEventPropertyKey7 = @"EventPropertyKey7";
static NSString *const kPHTestEventPropertyKey8 = @"EventPropertyKey8";
static NSString *const kPHTestEventPropertyKey9 = @"EventPropertyKey9";

static NSString *const kPHTestEventPropertyValue1 = @"EventPropertyValue1";
static NSString *const kPHTestEventPropertyValue2 = @"EventPropertyValue2";
static NSString *const kPHTestEventPropertyValue3 = @"!@#$%^&*(+_)(GVLSAJUCBAIU";

@interface PHEventTest : SenTestCase
@end

@implementation PHEventTest

- (void)testCreationWithClassMethod
{
    NSDictionary *theProperties = @{kPHTestEventPropertyKey1 : kPHTestEventPropertyValue1};
    
    STAssertNil([PHEvent eventWithProperties:nil], @"Event object should not be created with nil "
                "properties dictionary!");
    STAssertNotNil([PHEvent eventWithProperties:theProperties], @"Cannot create event object!");

    // Create properties dictionary that cannot be converted into JSON
    theProperties = @{kPHTestEventPropertyKey1 : [kPHTestEventPropertyValue1 dataUsingEncoding:
                NSUTF8StringEncoding]};
    STAssertNil([PHEvent eventWithProperties:theProperties], @"Event object "
                "should not be created with properties that cannot be converted into JSON!");

    // Create properties dictionary that cannot be converted into JSON
    theProperties = @{kPHTestEventPropertyKey1 : [NSDate date]};
    STAssertNil([PHEvent eventWithProperties:theProperties], @"Event object should not be created "
                "with properties that cannot be converted into JSON!");

    // Create properties dictionary that cannot be converted into JSON
    theProperties = @{kPHTestEventPropertyKey1 : [NSSet setWithObject:kPHTestEventPropertyValue1]};
    STAssertNil([PHEvent eventWithProperties:theProperties], @"Event object should not be created "
                "with properties that cannot be converted into JSON!");
}

- (void)testCreationWithInitializer
{
    NSDictionary *theProperties = @{kPHTestEventPropertyKey1 : kPHTestEventPropertyValue1};
    
    STAssertNil([[[PHEvent alloc] initWithProperties:nil] autorelease], @"Event object should not "
                "be created with nil properties dictionary!");
    STAssertNotNil([[[PHEvent alloc] initWithProperties:theProperties] autorelease], @"Cannot "
                "create event object!");
}

- (void)testEventProperties
{
    NSUInteger theTestIntegerValue = 123;
    float theTestFloatValue = 123.4567f;
    BOOL theTestBoolValue = YES;

    NSDictionary *theProperties =
    @{
        kPHTestEventPropertyKey1 : kPHTestEventPropertyValue1,
        kPHTestEventPropertyKey2 : @{kPHTestEventPropertyKey3 : kPHTestEventPropertyValue2},
        kPHTestEventPropertyKey4 : @[kPHTestEventPropertyValue1, kPHTestEventPropertyValue2],
        kPHTestEventPropertyKey5 : @(theTestIntegerValue),
        kPHTestEventPropertyKey6 : [NSDecimalNumber numberWithFloat:theTestFloatValue],
        kPHTestEventPropertyKey7 : [NSNull null],
        kPHTestEventPropertyKey8 : @(theTestBoolValue),
        kPHTestEventPropertyKey9 : kPHTestEventPropertyValue3
    };

    PHEvent *theTestEvent = [PHEvent eventWithProperties:theProperties];
    STAssertNotNil(theTestEvent, @"Cannot create event object!");
    STAssertEqualObjects(theProperties, theTestEvent.properties, @"Event's properties don't match "
                "the ones passed to the ititializer!");
    
    NSString *theJSONRepresentation = theTestEvent.JSONRepresentation;
    STAssertNotNil(theJSONRepresentation, @"JSON representation of the event object should not be "
                "nil");
    
    PH_SBJSONPARSER_CLASS *theJSONParser = [[PH_SBJSONPARSER_CLASS new] autorelease];
    NSError *theError = nil;
    NSDictionary *theDecodedEvent = [theJSONParser objectWithString:theJSONRepresentation error:
                &theError];
    
    STAssertNotNil(theDecodedEvent, @"Cannot decode the event JSON: %@", theError);
    STAssertTrue((NSUInteger)[[NSDate date] timeIntervalSince1970] >= [theDecodedEvent[@"ts"]
                integerValue], @"Unexpected time stamp of the event!");
    STAssertEqualObjects(theProperties, theDecodedEvent[@"event"], @"Event's properties don't match "
                "the ones passed to the initializer!");
}

@end
