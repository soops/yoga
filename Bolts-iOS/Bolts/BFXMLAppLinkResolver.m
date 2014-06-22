/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <UIKit/UIKit.h>

#import <libxml2/libxml/xpath.h>
#import <libxml2/libxml/HTMLparser.h>

#import "BFXMLAppLinkResolver.h"
#import "BFAppLink.h"
#import "BFAppLinkTarget.h"
#import "BFTask.h"
#import "BFTaskCompletionSource.h"

static NSString *const BFXMLAppLinkResolverIOSURLKey = @"url";
static NSString *const BFXMLAppLinkResolverIOSAppStoreIdKey = @"app_store_id";
static NSString *const BFXMLAppLinkResolverIOSAppNameKey = @"app_name";
static NSString *const BFXMLAppLinkResolverDictionaryValueKey = @"_value";
static NSString *const BFXMLAppLinkResolverPreferHeader = @"Prefer-Html-Meta-Tags";
static NSString *const BFXMLAppLinkResolverMetaTagPrefix = @"al";
static NSString *const BFXMLAppLinkResolverWebKey = @"web";
static NSString *const BFXMLAppLinkResolverIOSKey = @"ios";
static NSString *const BFXMLAppLinkResolverIPhoneKey = @"iphone";
static NSString *const BFXMLAppLinkResolverIPadKey = @"ipad";
static NSString *const BFXMLAppLinkResolverWebURLKey = @"url";
static NSString *const BFXMLAppLinkResolverShouldFallbackKey = @"should_fallback";

NSString *const BFXMLAppLinkResolverErrorDomain = @"BFXMLAppLinkResolverErrorDomain";

@implementation BFXMLAppLinkResolver

+ (instancetype)sharedInstance {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (BFTask *)followRedirects:(NSURL *)url {
    // This task will be resolved with either the redirect NSURL
    // or a dictionary with the response data to be returned.
    BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:BFXMLAppLinkResolverMetaTagPrefix
   forHTTPHeaderField:BFXMLAppLinkResolverPreferHeader];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               if (connectionError) {
                                   [tcs setError:connectionError];
                                   return;
                               }

                               if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

                                   // NSURLConnection usually follows redirects automatically, but the
                                   // documentation is unclear what the default is. This helps it along.
                                   if ([[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(300, 100)] containsIndex:httpResponse.statusCode]) {
                                       NSString *redirectString = httpResponse.allHeaderFields[@"Location"];
                                       NSURL *redirectURL = [NSURL URLWithString:redirectString];
                                       [tcs setResult:redirectURL];
                                       return;
                                   }
                               }

                               [tcs setResult:@{
                                                @"response" : response,
                                                @"data" : data
                                                }];
                           }];
    return [tcs.task continueWithSuccessBlock:^id(BFTask *task) {
        // If we redirected, just keep recursing.
        if ([task.result isKindOfClass:[NSURL class]]) {
            return [self followRedirects:task.result];
        }
        return task;
    }];
}

- (BFTask *)appLinkFromURLInBackground:(NSURL *)url {
    return [[self followRedirects:url] continueWithSuccessBlock:^id(BFTask *task) {
                                           NSData *responseData = task.result[@"data"];
                                           NSHTTPURLResponse *response = task.result[@"response"];

                                           htmlDocPtr document = htmlReadMemory(responseData.bytes, (int)responseData.length, [url.absoluteString UTF8String], [response.textEncodingName UTF8String], HTML_PARSE_RECOVER);
                                           xmlErrorPtr xmlError = xmlGetLastError();
                                           if (xmlError) {
                                               NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                                               if (xmlError->message)
                                                   [userInfo setObject:@(xmlError->message) forKey:NSLocalizedDescriptionKey];
                                               NSError *error = [NSError errorWithDomain:BFXMLAppLinkResolverErrorDomain code:(xmlError->code) userInfo:userInfo];
                                               xmlResetError(xmlError);
                                               return [BFTask taskWithError:error];
                                           }

                                           xmlXPathContextPtr context = xmlXPathNewContext(document);
                                           xmlXPathObjectPtr xpathObj = xmlXPathNodeEval(xmlDocGetRootElement(document), BAD_CAST"//meta[starts-with(@property,'al')]", context);

                                           NSMutableArray *results = [NSMutableArray array];
                                           for (NSInteger idx = 0; idx < xmlXPathNodeSetGetLength(xpathObj->nodesetval); idx++) {
                                               NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
                                               xmlNodePtr node = xmlXPathNodeSetItem(xpathObj->nodesetval, idx);
                                               xmlChar *propertyValue = xmlGetProp(node, BAD_CAST"property");
                                               if (propertyValue) {
                                                   [attributes setObject:@((const char *)propertyValue) forKey:@"property"];
                                                   xmlFree(propertyValue);
                                               }
                                               xmlChar *contentValue = xmlGetProp(node, BAD_CAST"content");
                                               if (contentValue) {
                                                   [attributes setObject:@((const char *)contentValue) forKey:@"content"];
                                                   xmlFree(contentValue);
                                               }
                                               [results addObject:attributes];
                                           }

                                           xmlXPathFreeObject(xpathObj);
                                           xmlXPathFreeContext(context);
                                           xmlFreeDoc(document);

                                           return [BFTask taskWithResult:[self appLinkFromALData:[self parseALData:results] destination:url]];
                                       }];
}

/*
 Builds up a data structure filled with the app link data from the meta tags on a page.
 The structure of this object is a dictionary where each key holds an array of app link
 data dictionaries.  Values are stored in a key called "_value".
 */
- (NSDictionary *)parseALData:(NSArray *)dataArray {
    NSMutableDictionary *al = [NSMutableDictionary dictionary];
    for (NSDictionary *tag in dataArray) {
        NSString *name = tag[@"property"];
        if (![name isKindOfClass:[NSString class]]) {
            continue;
        }
        NSArray *nameComponents = [name componentsSeparatedByString:@":"];
        if (![nameComponents[0] isEqualToString:BFXMLAppLinkResolverMetaTagPrefix]) {
            continue;
        }
        NSMutableDictionary *root = al;
        for (int i = 1; i < nameComponents.count; i++) {
            NSMutableArray *children = root[nameComponents[i]];
            if (!children) {
                children = [NSMutableArray array];
                root[nameComponents[i]] = children;
            }
            NSMutableDictionary *child = children.lastObject;
            if (!child || i == nameComponents.count - 1) {
                child = [NSMutableDictionary dictionary];
                [children addObject:child];
            }
            root = child;
        }
        if (tag[@"content"]) {
            root[BFXMLAppLinkResolverDictionaryValueKey] = tag[@"content"];
        }
    }
    return al;
}

/*
 Converts app link data into a BFAppLink containing the targets relevant for this platform.
 */
- (BFAppLink *)appLinkFromALData:(NSDictionary *)appLinkDict destination:(NSURL *)destination {
    NSMutableArray *linkTargets = [NSMutableArray array];
    
    NSArray *platformData = nil;
    switch (UI_USER_INTERFACE_IDIOM()) {
        case UIUserInterfaceIdiomPad:
            platformData = @[appLinkDict[BFXMLAppLinkResolverIPadKey] ?: @{},
                             appLinkDict[BFXMLAppLinkResolverIOSKey] ?: @{}];
            break;
        case UIUserInterfaceIdiomPhone:
            platformData = @[appLinkDict[BFXMLAppLinkResolverIPhoneKey] ?: @{},
                             appLinkDict[BFXMLAppLinkResolverIOSKey] ?: @{}];
            break;
        default:
            // Future-proofing. Other User Interface idioms should only hit ios.
            platformData = @[appLinkDict[BFXMLAppLinkResolverIOSKey] ?: @{}];
            break;
    }
    
    for (NSArray *platformObjects in platformData) {
        for (NSDictionary *platformDict in platformObjects) {
            // The schema requires a single url/app store id/app name,
            // but we could find multiple of them. We'll make a best effort
            // to interpret this data.
            NSArray *urls = platformDict[BFXMLAppLinkResolverIOSURLKey];
            NSArray *appStoreIds = platformDict[BFXMLAppLinkResolverIOSAppStoreIdKey];
            NSArray *appNames = platformDict[BFXMLAppLinkResolverIOSAppNameKey];
            
            NSUInteger maxCount = MAX(urls.count, MAX(appStoreIds.count, appNames.count));
            
            for (NSUInteger i = 0; i < maxCount; i++) {
                NSString *urlString = urls[i][BFXMLAppLinkResolverDictionaryValueKey];
                NSURL *url = urlString ? [NSURL URLWithString:urlString] : nil;
                NSString *appStoreId = appStoreIds[i][BFXMLAppLinkResolverDictionaryValueKey];
                NSString *appName = appNames[i][BFXMLAppLinkResolverDictionaryValueKey];
                BFAppLinkTarget *target = [BFAppLinkTarget appLinkTargetWithURL:url
                                                                     appStoreId:appStoreId
                                                                        appName:appName];
                [linkTargets addObject:target];
            }
        }
    }
    
    NSDictionary *webDict = appLinkDict[BFXMLAppLinkResolverWebKey][0];
    NSString *webUrlString = webDict[BFXMLAppLinkResolverWebURLKey][0][BFXMLAppLinkResolverDictionaryValueKey];
    NSString *shouldFallbackString = webDict[BFXMLAppLinkResolverShouldFallbackKey][0][BFXMLAppLinkResolverDictionaryValueKey];
    
    NSURL *webUrl = destination;
    
    if (shouldFallbackString &&
        [@[@"no", @"false", @"0"] containsObject:[shouldFallbackString lowercaseString]]) {
        webUrl = nil;
    }
    if (webUrl && webUrlString) {
        webUrl = [NSURL URLWithString:webUrlString];
    }
    
    return [BFAppLink appLinkWithSourceURL:destination
                                   targets:linkTargets
                                    webURL:webUrl];
}

@end
