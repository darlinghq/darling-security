/*
 * Copyright (c) 2016 Apple Inc. All Rights Reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */

#import "CKKSKeychainView.h"
#import "CKKSCurrentKeyPointer.h"
#import "CKKSKey.h"
#import "CKKSNewTLKOperation.h"
#import "CKKSGroupOperation.h"
#import "CKKSNearFutureScheduler.h"
#import "keychain/ckks/CloudKitCategories.h"
#import "keychain/categories/NSError+UsefulConstructors.h"

#if OCTAGON

#import "keychain/ckks/CKKSTLKShareRecord.h"

@interface CKKSNewTLKOperation ()
@property NSBlockOperation* cloudkitModifyOperationFinished;
@property CKOperationGroup* ckoperationGroup;

@property (nullable) CKKSCurrentKeySet* keyset;
@end

@implementation CKKSNewTLKOperation
@synthesize keyset;

- (instancetype)init {
    return nil;
}
- (instancetype)initWithCKKSKeychainView:(CKKSKeychainView*)ckks ckoperationGroup:(CKOperationGroup*)ckoperationGroup {
    if(self = [super init]) {
        _ckks = ckks;
        _ckoperationGroup = ckoperationGroup;
    }
    return self;
}

- (void)groupStart {
    /*
     * Rolling keys is an essential operation, and must be transactional: either completing successfully or
     * failing entirely. Also, in the case of failure, some other peer has beaten us to CloudKit and changed
     * the keys stored there (which we must now fetch and handle): the keys we attempted to upload are useless.

     * Therefore, we'll skip the normal OutgoingQueue behavior, and persist keys in-memory until such time as
     * CloudKit tells us the operation succeeds or fails, at which point we'll commit them or throw them away.
     *
     * Note that this means edge cases in the case of secd dying in the middle of this operation; our normal
     * retry mechanisms won't work. We'll have to make the policy decision to re-roll the keys if needed upon
     * the next launch of secd (or, the write will succeed after we die, and we'll handle receiving the CK
     * items as if a different peer uploaded them).
     */

    CKKSKeychainView* ckks = self.ckks;

    if(self.cancelled) {
        ckksnotice("ckkstlk", ckks, "CKKSNewTLKOperation cancelled, quitting");
        return;
    }

    if(!ckks) {
        ckkserror("ckkstlk", ckks, "no CKKS object");
        return;
    }

    // Synchronous, on some thread. Get back on the CKKS queue for SQL thread-safety.
    [ckks dispatchSyncWithAccountKeys: ^bool{
        if(self.cancelled) {
            ckksnotice("ckkstlk", ckks, "CKKSNewTLKOperation cancelled, quitting");
            return false;
        }

        ckks.lastNewTLKOperation = self;

        NSError* error = nil;

        ckksinfo("ckkstlk", ckks, "Generating new TLK");

        // Promote to strong reference
        CKKSKeychainView* ckks = self.ckks;

        CKKSKey* newTLK = nil;
        CKKSKey* newClassAKey = nil;
        CKKSKey* newClassCKey = nil;
        CKKSKey* wrappedOldTLK = nil;

        // Now, prepare data for the operation:

        // We must find the current TLK (to wrap it to the new TLK).
        NSError* localerror = nil;
        CKKSKey* oldTLK = [CKKSKey currentKeyForClass: SecCKKSKeyClassTLK zoneID:ckks.zoneID error: &localerror];
        if(localerror) {
            ckkserror("ckkstlk", ckks, "couldn't load the current TLK: %@", localerror);
            // TODO: not loading the old TLK is fine, but only if there aren't any TLKs
        }

        [oldTLK ensureKeyLoaded: &error];

        ckksnotice("ckkstlk", ckks, "Old TLK is: %@ %@", oldTLK, error);
        if(error != nil) {
            ckkserror("ckkstlk", ckks, "Couldn't fetch and unwrap old TLK: %@", error);
            [ckks _onqueueAdvanceKeyStateMachineToState: SecCKKSZoneKeyStateError withError: error];
            return false;
        }

        // Generate new hierarchy:
        //       newTLK
        //      /   |   \
        //     /    |    \
        //    /     |     \
        // oldTLK classA classC

        CKKSAESSIVKey* newAESKey = [CKKSAESSIVKey randomKey:&error];
        if(error) {
            ckkserror("ckkstlk", ckks, "Couldn't create new TLK: %@", error);
            self.error = error;
            [ckks _onqueueAdvanceKeyStateMachineToState:SecCKKSZoneKeyStateError withError:error];
            return false;
        }
        newTLK = [[CKKSKey alloc] initSelfWrappedWithAESKey:newAESKey
                                                       uuid:[[NSUUID UUID] UUIDString]
                                                   keyclass:SecCKKSKeyClassTLK
                                                      state:SecCKKSProcessedStateLocal
                                                     zoneID:ckks.zoneID
                                            encodedCKRecord:nil
                                                 currentkey:true];

        newClassAKey = [CKKSKey randomKeyWrappedByParent: newTLK keyclass: SecCKKSKeyClassA error: &error];
        newClassCKey = [CKKSKey randomKeyWrappedByParent: newTLK keyclass: SecCKKSKeyClassC error: &error];

        if(error != nil) {
            ckkserror("ckkstlk", ckks, "couldn't make new key hierarchy: %@", error);
            // TODO: this really isn't the error state, but a 'retry'.
            [ckks _onqueueAdvanceKeyStateMachineToState: SecCKKSZoneKeyStateError withError: error];
            return false;
        }

        CKKSCurrentKeyPointer* currentTLKPointer =    [CKKSCurrentKeyPointer forKeyClass: SecCKKSKeyClassTLK withKeyUUID:newTLK.uuid       zoneID:ckks.zoneID error: &error];
        CKKSCurrentKeyPointer* currentClassAPointer = [CKKSCurrentKeyPointer forKeyClass: SecCKKSKeyClassA   withKeyUUID:newClassAKey.uuid zoneID:ckks.zoneID error: &error];
        CKKSCurrentKeyPointer* currentClassCPointer = [CKKSCurrentKeyPointer forKeyClass: SecCKKSKeyClassC   withKeyUUID:newClassCKey.uuid zoneID:ckks.zoneID error: &error];

        if(error != nil) {
            ckkserror("ckkstlk", ckks, "couldn't make current key records: %@", error);
            // TODO: this really isn't the error state, but a 'retry'.
            [ckks _onqueueAdvanceKeyStateMachineToState: SecCKKSZoneKeyStateError withError: error];
            return false;
        }

        // Wrap old TLK under the new TLK
        wrappedOldTLK = [oldTLK copy];
        if(wrappedOldTLK) {
            [wrappedOldTLK ensureKeyLoaded: &error];
            if(error != nil) {
                ckkserror("ckkstlk", ckks, "couldn't unwrap TLK, aborting new TLK operation: %@", error);
                [ckks _onqueueAdvanceKeyStateMachineToState: SecCKKSZoneKeyStateError withError: error];
                return false;
            }

            [wrappedOldTLK wrapUnder: newTLK error:&error];
            // TODO: should we continue in this error state? Might be required to fix broken TLKs/argue over which TLK should be used
            if(error != nil) {
                ckkserror("ckkstlk", ckks, "couldn't wrap oldTLK, aborting new TLK operation: %@", error);
                [ckks _onqueueAdvanceKeyStateMachineToState: SecCKKSZoneKeyStateError withError: error];
                return false;
            }

            wrappedOldTLK.currentkey = false;
        }

        CKKSCurrentKeySet* keyset = [[CKKSCurrentKeySet alloc] init];

        keyset.tlk = newTLK;
        keyset.classA = newClassAKey;
        keyset.classC = newClassCKey;

        keyset.currentTLKPointer = currentTLKPointer;
        keyset.currentClassAPointer = currentClassAPointer;
        keyset.currentClassCPointer = currentClassCPointer;

        keyset.proposed = YES;

        if(wrappedOldTLK) {
            // TODO o no
        }

        // Save the proposed keys to the keychain. Note that we might reject this TLK later, but in that case, this TLK is just orphaned. No worries!
        ckksnotice("ckkstlk", ckks, "Saving new keys %@ to keychain", keyset);

        [newTLK       saveKeyMaterialToKeychain: &error];
        [newClassAKey saveKeyMaterialToKeychain: &error];
        [newClassCKey saveKeyMaterialToKeychain: &error];
        if(error) {
            self.error = error;
            ckkserror("ckkstlk", ckks, "couldn't save new key material to keychain, aborting new TLK operation: %@", error);
            [ckks _onqueueAdvanceKeyStateMachineToState: SecCKKSZoneKeyStateError withError: error];
            return false;
        }

        // Generate the TLK sharing records for all trusted peers
        NSMutableSet<CKKSTLKShareRecord*>* tlkShares = [NSMutableSet set];
        for(CKKSPeerProviderState* trustState in ckks.currentTrustStates) {
            if(trustState.currentSelfPeers.currentSelf == nil || trustState.currentSelfPeersError) {
                if(trustState.essential) {
                    ckksnotice("ckkstlk", ckks, "Fatal error: unable to generate TLK shares for (%@): %@", newTLK, trustState.currentSelfPeersError);
                    self.error = trustState.currentSelfPeersError;
                    [ckks _onqueueAdvanceKeyStateMachineToState:SecCKKSZoneKeyStateError withError:trustState.currentSelfPeersError];
                    return false;
                }
                ckksnotice("ckkstlk", ckks, "Unable to generate TLK shares for (%@): %@", newTLK, trustState);
                continue;
            }

            for(id<CKKSPeer> trustedPeer in trustState.currentTrustedPeers) {
                if(!trustedPeer.publicEncryptionKey) {
                    ckksnotice("ckkstlk", ckks, "No need to make TLK for %@; they don't have any encryption keys", trustedPeer);
                    continue;
                }

                ckksnotice("ckkstlk", ckks, "Generating TLK(%@) share for %@", newTLK, trustedPeer);
                CKKSTLKShareRecord* share = [CKKSTLKShareRecord share:newTLK as:trustState.currentSelfPeers.currentSelf to:trustedPeer epoch:-1 poisoned:0 error:&error];

                [tlkShares addObject:share];
            }
        }

        keyset.pendingTLKShares = [tlkShares allObjects];

        self.keyset = keyset;

        [ckks _onqueueAdvanceKeyStateMachineToState:SecCKKSZoneKeyStateWaitForTLKUpload withError:nil];

        return true;
    }];
}

- (void)cancel {
    [super cancel];
}

@end;

#endif
