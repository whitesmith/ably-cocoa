//
//  ARTChannel.h
//  ably
//
//  Created by Yavor Georgiev on 20.08.15.
//  Copyright (c) 2015 г. Ably. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARTTypes.h"
#import "ARTDataEncoder.h"

@class ARTChannelOptions;
@class ARTMessage;
@class __GENERIC(ARTPaginatedResult, ItemType);
@class ARTDataQuery;

ART_ASSUME_NONNULL_BEGIN

@interface ARTChannel : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (readonly, getter=getLogger) ARTLog *logger;

- (instancetype)initWithName:(NSString *)name andOptions:(ARTChannelOptions *)options andLogger:(ARTLog *)logger;

- (void)publish:(art_nullable id)data callback:(art_nullable ARTErrorCallback)callback;
- (void)publish:(art_nullable id)data name:(art_nullable NSString *)name callback:(art_nullable ARTErrorCallback)callback;

- (void)publishMessage:(ARTMessage *)message callback:(art_nullable ARTErrorCallback)callback;
- (void)publishMessages:(__GENERIC(NSArray, ARTMessage *) *)messages callback:(art_nullable ARTErrorCallback)callback;

- (BOOL)history:(art_nullable ARTDataQuery *)query callback:(void(^)(__GENERIC(ARTPaginatedResult, ARTMessage *) *__art_nullable result, NSError *__art_nullable error))callback error:(NSError *__art_nullable *__art_nullable)errorPtr;

@end

ART_ASSUME_NONNULL_END
