/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright 2013-2014 Medium Entertainment, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 PHPublisherOpenRequestTest.m
 playhaven-sdk-ios

 Created by Jesus Fernandez on 3/30/11.
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <SenTestingKit/SenTestingKit.h>
#import "PHPublisherOpenRequest.h"
#import "PHConstants.h"
#import "SenTestCase+PHAPIRequestSupport.h"
#import "PHAPIRequest+Private.h"
#import "PHConstants.h"
#import "JSON.h"

#define EXPECTED_HASH @"3L0xlrDOt02UrTDwMSnye05Awwk"

/*static NSString *const kPHTestAPIKey1 = @"f25a3b41dbcb4c13bd8d6b0b282eec32";
static NSString *const kPHTestAPIKey2 = @"d45a3b4c13bd82eec32b8d6b0b241dbc";
static NSString *const kPHTestAPIKey3 = @"3bd82eed45a332b8d6b0b241dbcb4c1c";
static NSString *const kPHTestSID1 = @"13565276206185677368";
static NSString *const kPHTestSID2 = @"12256527677368061856";
static NSString *const kPHTestSID3 = @"73680618561225652767";*/

static NSString *const kPHTestToken  = @"PUBLISHER_TOKEN";
static NSString *const kPHTestSecret = @"PUBLISHER_SECRET";

@interface PHPublisherOpenRequestTest : SenTestCase
@end

@implementation PHPublisherOpenRequestTest

- (void)setUp
{
    [super setUp];

    // Cancel the request to remove it from the cache
    [[PHPublisherOpenRequest requestForApp:kPHTestToken secret:kPHTestSecret] cancel];
}

- (void)testInstance
{
    NSString *token  = @"PUBLISHER_TOKEN",
             *secret = @"PUBLISHER_SECRET";
    PHPublisherOpenRequest *request = [PHPublisherOpenRequest requestForApp:(NSString *)token secret:(NSString *)secret];
    NSURL *theRequestURL = [self URLForRequest:request];
    NSString *requestURLString = [theRequestURL absoluteString];

    STAssertNotNil(requestURLString, @"Parameter string is nil?");
    STAssertFalse([requestURLString rangeOfString:@"token="].location == NSNotFound,
                  @"Token parameter not present!");
    STAssertFalse([requestURLString rangeOfString:@"nonce="].location == NSNotFound,
                  @"Nonce parameter not present!");
    STAssertFalse([requestURLString rangeOfString:@"sig4="].location == NSNotFound,
                  @"Secret parameter not present!");

    STAssertTrue([request respondsToSelector:@selector(send)], @"Send method not implemented!");
}

- (void)testRequestParameters
{
    NSString *token  = @"PUBLISHER_TOKEN",
             *secret = @"PUBLISHER_SECRET";

    [PHAPIRequest setCustomUDID:nil];

    PHPublisherOpenRequest *request = [PHPublisherOpenRequest requestForApp:token secret:secret];
    NSURL *theRequestURL = [self URLForRequest:request];

    NSDictionary *signedParameters  = [request signedParameters];
    NSString     *requestURLString  = [theRequestURL absoluteString];

//#define PH_USE_MAC_ADDRESS 1
#if PH_USE_MAC_ADDRESS == 1
    if (PH_SYSTEM_VERSION_LESS_THAN(@"6.0"))
    {
        NSString *mac   = [signedParameters valueForKey:@"mac"];
        STAssertNotNil(mac, @"MAC param is missing!");
        STAssertFalse([requestURLString rangeOfString:@"mac="].location == NSNotFound, @"MAC param is missing: %@", requestURLString);
    }
#else
    NSString *mac   = [signedParameters valueForKey:@"mac"];
    STAssertNil(mac, @"MAC param is present!");
    STAssertTrue([requestURLString rangeOfString:@"mac="].location == NSNotFound, @"MAC param exists when it shouldn't: %@", requestURLString);
#endif
}

- (void)testNoIDFAParameter
{
    BOOL theOptOutFlag = [PHAPIRequest optOutStatus];
    
    // User is opted in
    [PHAPIRequest setOptOutStatus:NO];
    
    PHPublisherOpenRequest *theRequest = [PHPublisherOpenRequest requestForApp:kPHTestToken secret:
                kPHTestSecret];
    NSString *theRequestURL = [[self URLForRequest:theRequest] absoluteString];
    NSDictionary *theSignedParameters = [theRequest signedParameters];

    NSString *theIDFA = theSignedParameters[@"ifa"];

    STAssertNil(theIDFA, @"No IDFA parameter is expected on open request!");
    STAssertTrue([theRequestURL rangeOfString:@"ifa="].length == 0, @"No IDFA parameter is expected"
                " on open request!");

    // User is opted in
    [PHAPIRequest setOptOutStatus:YES];
    
    [theRequest cancel];
    
    theRequest = [PHPublisherOpenRequest requestForApp:kPHTestToken secret:kPHTestSecret];
    theRequestURL = [[self URLForRequest:theRequest] absoluteString];
    theSignedParameters = [theRequest signedParameters];

    STAssertNil(theSignedParameters[@"ifa"], @"No IDFA parameter is expected on open request!");
    STAssertTrue([theRequestURL rangeOfString:@"ifa="].length == 0, @"No IDFA parameter is expected"
                " on open request!");

    // Restore opt out status
    [PHAPIRequest setOptOutStatus:theOptOutFlag];
}

- (void)testCustomUDID
{
    NSString *token  = @"PUBLISHER_TOKEN",
             *secret = @"PUBLISHER_SECRET";

    [PHAPIRequest setCustomUDID:nil];

    PHPublisherOpenRequest *request = [PHPublisherOpenRequest requestForApp:token secret:secret];
    NSURL *theRequestURL = [self URLForRequest:request];
    NSString *requestURLString = [theRequestURL absoluteString];

    STAssertNotNil(requestURLString, @"Parameter string is nil?");
    STAssertTrue([requestURLString rangeOfString:@"d_custom="].location == NSNotFound,
                  @"Custom parameter exists when none is set.");

    PHPublisherOpenRequest *request2 = [PHPublisherOpenRequest requestForApp:token secret:secret];
    request2.customUDID = @"CUSTOM_UDID";
    theRequestURL = [self URLForRequest:request2];
    requestURLString = [theRequestURL absoluteString];
    STAssertFalse([requestURLString rangeOfString:@"d_custom="].location == NSNotFound,
                 @"Custom parameter missing when one is set.");
}

- (void)testTimeZoneParameter
{
    PHPublisherOpenRequest *theRequest = [PHPublisherOpenRequest requestForApp:kPHTestToken secret:
                kPHTestSecret];
    NSURL *theRequestURL = [self URLForRequest:theRequest];
    
    STAssertNotNil([theRequest.additionalParameters objectForKey:@"tz"], @"Missed time zone!");
    STAssertTrue(0 < [[theRequestURL absoluteString] rangeOfString:@"tz="].length, @"Missed time "
                "zone!");

    NSScanner *theTimeZoneScanner = [NSScanner scannerWithString:[theRequestURL absoluteString]];

    STAssertTrue([theTimeZoneScanner scanUpToString:@"tz=" intoString:NULL], @"Missed time zone!");
    STAssertTrue([theTimeZoneScanner scanString:@"tz=" intoString:NULL], @"Missed time zone!");
    
    float theTimeOffset = 0;
    STAssertTrue([theTimeZoneScanner scanFloat:&theTimeOffset], @"Missed time zone!");
    
    STAssertTrue(- 11 <= theTimeOffset && theTimeOffset <= 14, @"Incorrect time zone offset");
}

- (void)testHTTPMethod
{
    PHPublisherOpenRequest *theRequest = [PHPublisherOpenRequest requestForApp:kPHTestToken secret:
                kPHTestSecret];
    STAssertNotNil(theRequest, @"");
    
    STAssertEquals(PHRequestHTTPPost, theRequest.HTTPMethod, @"HTTPMethod of the request doesn't "
                "match the expected one!");
}



#pragma mark - Base URL Test

- (void)testUpdatingBaseURL
{
    PHPublisherOpenRequest *theRequest = [PHPublisherOpenRequest requestForApp:kPHTestToken secret:
                kPHTestSecret];
    STAssertNotNil(theRequest, @"");
    
    NSString *theOriginalURL = PHGetBaseURL();
    STAssertTrue([[theRequest urlPath] hasPrefix:theOriginalURL], @"The request's urlPath (%@) is "
                "expected to start with: %@", [theRequest urlPath], theOriginalURL);
    
    NSString *theTestBaseURL = @"http://testHost.com";
    [theRequest didSucceedWithResponse:@{@"prefix" : theTestBaseURL}];
    STAssertTrue([[theRequest urlPath] hasPrefix:theTestBaseURL], @"The request's urlPath (%@) is "
                "expected to start with: %@", [theRequest urlPath], theTestBaseURL);

    // Make sure that trailing slash is properly removed by SDK
    NSString *theBaseURLWithTrailingSlash = @"http://testHost2.com/";
    [theRequest didSucceedWithResponse:@{@"prefix" : theBaseURLWithTrailingSlash}];
    STAssertEqualObjects(PHGetBaseURL(), @"http://testHost2.com", @"Base URL should not end with a "
                "slash!");
    
    // Restore the original base URL
    [theRequest didSucceedWithResponse:@{@"prefix" : theOriginalURL}];
    STAssertTrue([[theRequest urlPath] hasPrefix:theOriginalURL], @"The request's urlPath (%@) is "
                "expected to start with: %@", [theRequest urlPath], theOriginalURL);

    // Make sure that invalid URL is not set as a base URL of the SDK
    NSString *theCorruptedURL = @"http:$testHost.com";
    [theRequest didSucceedWithResponse:@{@"prefix" : theCorruptedURL}];
    STAssertTrue([[theRequest urlPath] hasPrefix:theOriginalURL], @"The request's urlPath (%@) is "
                "expected to start with: %@", [theRequest urlPath], theOriginalURL);
}

#pragma mark -

- (NSDictionary *)responseDictionaryWithJSONFileName:(NSString *)aFileName
{
    NSError *theError = nil;
    NSString *thetheStubResponse = [NSString stringWithContentsOfURL:[[NSBundle bundleForClass:
                [self class]] URLForResource:aFileName withExtension:@"json"] encoding:
                NSUTF8StringEncoding error:&theError];
    STAssertNotNil(thetheStubResponse, @"Cannot create data with stub response!");
    
    PH_SBJSONPARSER_CLASS *theParser = [[[PH_SBJSONPARSER_CLASS alloc] init] autorelease];
    NSDictionary *theResponseDictionary = [theParser objectWithString:thetheStubResponse];
    STAssertNotNil(thetheStubResponse, @"Cannot parse stub response!");

    return theResponseDictionary[@"response"];
}

@end
