// This file was automatically generated by protocompiler
// DO NOT EDIT!
// Compiled from OTRecovery.proto

#import <Foundation/Foundation.h>
#import <ProtocolBuffer/PBCodable.h>

#ifdef __cplusplus
#define RECOVERY_FUNCTION extern "C" __attribute__((visibility("hidden")))
#else
#define RECOVERY_FUNCTION extern __attribute__((visibility("hidden")))
#endif

__attribute__((visibility("hidden")))
@interface Recovery : PBCodable <NSCopying>
{
    NSData *_encryptionSPKI;
    NSString *_peerID;
    NSData *_signingSPKI;
}


@property (nonatomic, readonly) BOOL hasPeerID;
@property (nonatomic, retain) NSString *peerID;

@property (nonatomic, readonly) BOOL hasSigningSPKI;
/** as SubjectPublicKeyInfo (SPKI): */
@property (nonatomic, retain) NSData *signingSPKI;

@property (nonatomic, readonly) BOOL hasEncryptionSPKI;
@property (nonatomic, retain) NSData *encryptionSPKI;

// Performs a shallow copy into other
- (void)copyTo:(Recovery *)other;

// Performs a deep merge from other into self
// If set in other, singular values in self are replaced in self
// Singular composite values are recursively merged
// Repeated values from other are appended to repeated values in self
- (void)mergeFrom:(Recovery *)other;

RECOVERY_FUNCTION BOOL RecoveryReadFrom(__unsafe_unretained Recovery *self, __unsafe_unretained PBDataReader *reader);

@end

