//
//  ARTFormEncode.m
//  Ably
//
//  Created by Ricardo Pereira on 27/09/2019.
//  Copyright © 2019 Ably. All rights reserved.
//
//  Apple left a form encoder out for some reason.
//  Code credit to @mxcl. Based on:
//  https://github.com/mxcl/OMGHTTPURLRQ/blob/a757e2a3043c5f031b23ef8dadf82a97856dbfab/Sources/OMGFormURLEncode.m
//

#import "ARTFormEncode.h"

static inline NSString *enc(id in, NSString *ignore) {
    NSMutableCharacterSet *allowedSet = [NSMutableCharacterSet characterSetWithCharactersInString:ignore];
    [allowedSet formUnionWithCharacterSet:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [allowedSet removeCharactersInString:@":/?&=;+!@#$()',*"];

    return [[in description] stringByAddingPercentEncodingWithAllowedCharacters:allowedSet];
}

#define enckey(in) enc(in, @"[]")
#define encval(in) enc(in, @"")

static NSArray *DoQueryMagic(NSString *key, id value) {
    NSMutableArray *parts = [NSMutableArray new];

    // Sort dictionary keys to ensure consistent ordering in query string,
    // which is important when deserializing potentially ambiguous sequences,
    // such as an array of dictionaries
    #define sortDescriptor [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)]

    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[sortDescriptor]]) {
            id recursiveKey = key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey;
            [parts addObjectsFromArray:DoQueryMagic(recursiveKey, dictionary[nestedKey])];
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        for (id nestedValue in value)
            [parts addObjectsFromArray:DoQueryMagic([NSString stringWithFormat:@"%@[]", key], nestedValue)];
    } else if ([value isKindOfClass:[NSSet class]]) {
        for (id obj in [value sortedArrayUsingDescriptors:@[sortDescriptor]])
            [parts addObjectsFromArray:DoQueryMagic(key, obj)];
    } else {
        [parts addObjectsFromArray:[NSArray arrayWithObjects:key, value, nil]];
    }

    return parts;

    #undef sortDescriptor
}

NSString *ARTFormEncode(NSDictionary *parameters) {
    if (parameters.count == 0)
        return @"";
    NSMutableString *queryString = [NSMutableString new];
    NSEnumerator *e = DoQueryMagic(nil, parameters).objectEnumerator;
    for (;;) {
        id const obj = e.nextObject;
        if (!obj) break;
        [queryString appendFormat:@"%@=%@&", enckey(obj), encval(e.nextObject)];
    }
    [queryString deleteCharactersInRange:NSMakeRange(queryString.length - 1, 1)];
    return queryString;
}
