
#import <Foundation/Foundation.h>

#if OCTAGON

#import "keychain/ckks/CKKSGroupOperation.h"
#import "keychain/ot/OctagonStateMachineHelpers.h"
#import "keychain/ot/OTOperationDependencies.h"

NS_ASSUME_NONNULL_BEGIN

@interface OTResetCKKSZonesLackingTLKsOperation : CKKSGroupOperation <OctagonStateTransitionOperationProtocol>
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDependencies:(OTOperationDependencies*)dependencies
                       intendedState:(OctagonState*)intendedState
                          errorState:(OctagonState*)errorState;
@end

NS_ASSUME_NONNULL_END

#endif // OCTAGON
