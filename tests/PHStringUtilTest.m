/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright 2013 Medium Entertainment, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 PHStringUtilTest.m
 playhaven-sdk-ios

 Created by Anton Fedorchenko on 9/30/13
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <SenTestingKit/SenTestingKit.h>
#import "PHStringUtil.h"

@interface PHStringUtilTest : SenTestCase

@end

@implementation PHStringUtilTest

- (void)testUUID
{
    NSString *theFirstUUID = [PHStringUtil uuid];
    STAssertTrue(theFirstUUID.length > 0, @"Unexpected UUID: %@", theFirstUUID);
    
    NSString *theSecondUUID = [PHStringUtil uuid];
    STAssertTrue(theFirstUUID.length > 0, @"Unexpected UUID: %@", theFirstUUID);
    
    STAssertFalse([theFirstUUID isEqualToString:theSecondUUID], @"Two consecutive calls of uuid "
                "method should produce different UUIDs");
}

- (void)testDataDigestForString
{
    NSString *const kTestString = @"testString";
    NSData *theDigest = [PHStringUtil dataDigestForString:kTestString];

    STAssertTrue([theDigest length] > 0, @"Unexpected length of the digest!");
    STAssertEqualObjects(theDigest, [PHStringUtil dataDigestForString:kTestString], @"Digest "
                "should not change for two consecutive calls with the same input parameter.");
}

@end
