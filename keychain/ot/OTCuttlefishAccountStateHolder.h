
#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

#import "keychain/ot/proto/generated_source/OTAccountMetadataClassC.h"

extern NSString* _Nonnull OTCuttlefishContextErrorDomain;
typedef NS_ENUM(uint32_t, OTCuttlefishContextErrors) {
    OTCCNoExistingPeerID = 0,
};

NS_ASSUME_NONNULL_BEGIN

@protocol OTCuttlefishAccountStateHolderNotifier
- (void)accountStateUpdated:(OTAccountMetadataClassC*)newState from:(OTAccountMetadataClassC*)oldState;
@end

@interface OTCuttlefishAccountStateHolder : NSObject

// If you already know you're on this queue, call the _onqueue versions below.
- (instancetype)initWithQueue:(dispatch_queue_t)queue
                    container:(NSString*)containerName
                      context:(NSString*)contextID;

- (OTAccountMetadataClassC* _Nullable)loadOrCreateAccountMetadata:(NSError**)error;
- (OTAccountMetadataClassC* _Nullable)_onqueueLoadOrCreateAccountMetadata:(NSError**)error;

- (void)registerNotification:(id<OTCuttlefishAccountStateHolderNotifier>)notifier;

- (BOOL)persistNewEgoPeerID:(NSString*)peerID error:(NSError**)error;
- (NSString * _Nullable)getEgoPeerID:(NSError **)error;

- (BOOL)persistNewTrustState:(OTAccountMetadataClassC_TrustState)newState
                       error:(NSError**)error;

- (BOOL)persistNewEpoch:(uint64_t)epoch error:(NSError**)error;

- (BOOL)persistAccountChanges:(OTAccountMetadataClassC* (^)(OTAccountMetadataClassC* metadata))makeChanges
                        error:(NSError**)error;

- (BOOL)_onqueuePersistAccountChanges:(OTAccountMetadataClassC* (^)(OTAccountMetadataClassC* metadata))makeChanges
                                error:(NSError**)error;

- (NSDate *)lastHealthCheckupDate:(NSError * _Nullable *)error;
- (BOOL)persistLastHealthCheck:(NSDate*)lastCheck error:(NSError**)error;

- (OTAccountMetadataClassC_AttemptedAJoinState)fetchPersistedJoinAttempt:(NSError * _Nullable *)error;
- (BOOL)persistOctagonJoinAttempt:(OTAccountMetadataClassC_AttemptedAJoinState)attempt error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
