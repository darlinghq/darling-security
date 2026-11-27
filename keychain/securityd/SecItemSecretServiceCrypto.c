/*
 * Copyright (c) 2026 Lubos Dolezel
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#define __STDC_WANT_LIB_EXT1__ 1

#include "SecItemSecretServiceCrypto.h"

#include <CommonCrypto/CommonCryptor.h>
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonKeyDerivationSPI.h>
#include <Security/SecRandom.h>
#include <Security/cssm.h>
#include <Security/cssmapple.h>
#include <pthread.h>
#include <stdlib.h>
#include <string.h>

/* The CSSM interface is deprecated, but it is the Security framework's Diffie-Hellman. */
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

/* RFC 2409 section 6.2: the prime of the second Oakley group; the generator is 2. */
static const uint8_t kGroup2Prime[kSecretServiceDHPrimeSize] = {
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc9, 0x0f, 0xda, 0xa2, 0x21, 0x68, 0xc2, 0x34,
    0xc4, 0xc6, 0x62, 0x8b, 0x80, 0xdc, 0x1c, 0xd1, 0x29, 0x02, 0x4e, 0x08, 0x8a, 0x67, 0xcc, 0x74,
    0x02, 0x0b, 0xbe, 0xa6, 0x3b, 0x13, 0x9b, 0x22, 0x51, 0x4a, 0x08, 0x79, 0x8e, 0x34, 0x04, 0xdd,
    0xef, 0x95, 0x19, 0xb3, 0xcd, 0x3a, 0x43, 0x1b, 0x30, 0x2b, 0x0a, 0x6d, 0xf2, 0x5f, 0x14, 0x37,
    0x4f, 0xe1, 0x35, 0x6d, 0x6d, 0x51, 0xc2, 0x45, 0xe4, 0x85, 0xb5, 0x76, 0x62, 0x5e, 0x7e, 0xc6,
    0xf4, 0x4c, 0x42, 0xe9, 0xa6, 0x37, 0xed, 0x6b, 0x0b, 0xff, 0x5c, 0xb6, 0xf4, 0x06, 0xb7, 0xed,
    0xee, 0x38, 0x6b, 0xfb, 0x5a, 0x89, 0x9f, 0xa5, 0xae, 0x9f, 0x24, 0x11, 0x7c, 0x4b, 0x1f, 0xe6,
    0x49, 0x28, 0x66, 0x51, 0xec, 0xe6, 0x53, 0x81, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
};

void
SecretServiceClear(void *buffer, size_t length)
{
    if (buffer != NULL && length > 0)
        memset_s(buffer, length, 0, length);
}

void
SecretServiceFreeSecret(void *buffer, size_t length)
{
    SecretServiceClear(buffer, length);
    free(buffer);
}

#pragma mark - HKDF

bool
SecretServiceHKDFSHA256(const void *inputKey, size_t inputKeyLength, const void *salt, size_t saltLength,
    const void *info, size_t infoLength, void *outputKey, size_t outputKeyLength)
{
    CCKDFParametersRef parameters = NULL;
    if (CCKDFParametersCreateHkdf(&parameters, salt, saltLength, info, infoLength) != kCCSuccess)
        return false;
    CCStatus status = CCDeriveKey(parameters, kCCDigestSHA256, inputKey, inputKeyLength,
        outputKey, outputKeyLength);
    CCKDFParametersDestroy(parameters);
    if (status != kCCSuccess) {
        SecretServiceClear(outputKey, outputKeyLength);
        return false;
    }
    return true;
}

#pragma mark - Diffie-Hellman

struct SecretServiceDH {
    CSSM_KEY privateKey;
};

static void *
CSSMMalloc(CSSM_SIZE size, void *context)
{
    return malloc(size);
}

static void
CSSMFree(void *pointer, void *context)
{
    free(pointer);
}

static void *
CSSMRealloc(void *pointer, CSSM_SIZE size, void *context)
{
    return realloc(pointer, size);
}

static void *
CSSMCalloc(uint32 count, CSSM_SIZE size, void *context)
{
    return calloc(count, size);
}

static const CSSM_API_MEMORY_FUNCS kMemoryFunctions = {
    CSSMMalloc, CSSMFree, CSSMRealloc, CSSMCalloc, NULL
};

static pthread_once_t gCSPOnce = PTHREAD_ONCE_INIT;
static CSSM_CSP_HANDLE gCSP = 0;

/* Attaches the Apple CSP once per process. */
static void
AttachCSP(void)
{
    /* the caller's identity towards CSSM; it is not checked */
    static const CSSM_GUID kCallerGuid = {
        0x8f1d4a62, 0x5c3b, 0x4e0a, { 0x9d, 0x27, 0x61, 0x53, 0x65, 0x63, 0x53, 0x76 }
    };
    static const CSSM_VERSION kVersion = { 2, 0 };
    CSSM_PVC_MODE pvcPolicy = CSSM_PVC_NONE;
    CSSM_CSP_HANDLE csp = 0;
    if (CSSM_Init(&kVersion, CSSM_PRIVILEGE_SCOPE_NONE, &kCallerGuid, CSSM_KEY_HIERARCHY_NONE,
            &pvcPolicy, NULL) != CSSM_OK ||
        CSSM_ModuleLoad(&gGuidAppleCSP, CSSM_KEY_HIERARCHY_NONE, NULL, NULL) != CSSM_OK ||
        CSSM_ModuleAttach(&gGuidAppleCSP, &kVersion, &kMemoryFunctions, 0, CSSM_SERVICE_CSP, 0,
            CSSM_KEY_HIERARCHY_NONE, NULL, 0, NULL, &csp) != CSSM_OK)
        return;
    gCSP = csp;
}

static CSSM_CSP_HANDLE
CSP(void)
{
    pthread_once(&gCSPOnce, AttachCSP);
    return gCSP;
}

/* The group as PKCS #3 DHParameter ::= SEQUENCE { prime INTEGER, base INTEGER }, DER. */
static size_t
EncodeGroup2Parameters(uint8_t *der)
{
    size_t n = 0;
    der[n++] = 0x30;
    der[n++] = 0x81;
    der[n++] = 3 + 1 + sizeof(kGroup2Prime) + 3;
    /* the prime's top bit is set, so the INTEGER has a leading zero byte */
    der[n++] = 0x02;
    der[n++] = 0x81;
    der[n++] = 1 + sizeof(kGroup2Prime);
    der[n++] = 0x00;
    memcpy(der + n, kGroup2Prime, sizeof(kGroup2Prime));
    n += sizeof(kGroup2Prime);
    der[n++] = 0x02;
    der[n++] = 0x01;
    der[n++] = 0x02;
    return n;
}

SecretServiceDHRef
SecretServiceDHCreate(uint8_t publicKey[kSecretServiceDHPrimeSize], size_t *publicKeyLength)
{
    CSSM_CSP_HANDLE csp = CSP();
    if (csp == 0)
        return NULL;
    SecretServiceDHRef exchange = calloc(1, sizeof(*exchange));
    if (exchange == NULL)
        return NULL;

    uint8_t der[16 + kSecretServiceDHPrimeSize];
    CSSM_DATA parameters = { EncodeGroup2Parameters(der), der };
    CSSM_DATA label = { 2, (uint8 *)"dh" };
    CSSM_CC_HANDLE context = 0;
    CSSM_KEY public;
    memset(&public, 0, sizeof(public));
    bool ok = CSSM_CSP_CreateKeyGenContext(csp, CSSM_ALGID_DH, kSecretServiceDHPrimeSize * 8,
        NULL, NULL, NULL, NULL, &parameters, &context) == CSSM_OK;
    /* the private key stays in the CSP; only a reference to it comes back */
    ok = ok && CSSM_GenerateKeyPair(context,
        CSSM_KEYUSE_DERIVE, CSSM_KEYATTR_RETURN_DATA | CSSM_KEYATTR_EXTRACTABLE, &label, &public,
        CSSM_KEYUSE_DERIVE, CSSM_KEYATTR_RETURN_REF, &label, NULL, &exchange->privateKey) == CSSM_OK;
    if (context != 0)
        CSSM_DeleteContext(context);
    if (!ok) {
        free(exchange);
        return NULL;
    }
    /* the raw public key is the big-endian public value */
    ok = public.KeyData.Length > 0 && public.KeyData.Length <= kSecretServiceDHPrimeSize;
    if (ok) {
        memcpy(publicKey, public.KeyData.Data, public.KeyData.Length);
        *publicKeyLength = public.KeyData.Length;
    }
    CSSM_FreeKey(csp, NULL, &public, CSSM_FALSE);
    if (!ok) {
        SecretServiceDHRelease(exchange);
        return NULL;
    }
    return exchange;
}

void
SecretServiceDHRelease(SecretServiceDHRef exchange)
{
    if (exchange == NULL)
        return;
    CSSM_FreeKey(CSP(), NULL, &exchange->privateKey, CSSM_FALSE);
    SecretServiceFreeSecret(exchange, sizeof(*exchange));
}

/* A public value is usable when 1 < y < p - 1 (NIST SP 800-56A, the partial public key validation). */
static bool
IsValidPublicValue(const uint8_t *value, size_t length)
{
    uint8_t padded[kSecretServiceDHPrimeSize];
    memset(padded, 0, sizeof(padded) - length);
    memcpy(padded + sizeof(padded) - length, value, length);
    /* p - 1 is the prime with its last byte one less (the prime is odd) */
    uint8_t limit[kSecretServiceDHPrimeSize];
    memcpy(limit, kGroup2Prime, sizeof(limit));
    limit[sizeof(limit) - 1] -= 1;
    bool aboveOne = false;
    for (size_t i = 0; i + 1 < sizeof(padded) && !aboveOne; i++)
        aboveOne = padded[i] != 0;
    aboveOne = aboveOne || padded[sizeof(padded) - 1] > 1;
    return aboveOne && memcmp(padded, limit, sizeof(padded)) < 0;
}

bool
SecretServiceDHDeriveKey(SecretServiceDHRef exchange, const uint8_t *peerPublicKey, size_t peerPublicKeyLength,
    uint8_t key[kSecretServiceKeySize])
{
    CSSM_CSP_HANDLE csp = CSP();
    if (csp == 0 || peerPublicKeyLength == 0 || peerPublicKeyLength > kSecretServiceDHPrimeSize ||
        !IsValidPublicValue(peerPublicKey, peerPublicKeyLength))
        return false;
    CSSM_CC_HANDLE context = 0;
    CSSM_DATA peer = { peerPublicKeyLength, (uint8 *)peerPublicKey };
    CSSM_DATA label = { 2, (uint8 *)"dh" };
    CSSM_KEY derived;
    memset(&derived, 0, sizeof(derived));
    /* the "derived key" is the shared secret itself, as many bytes as the prime */
    bool ok = CSSM_CSP_CreateDeriveKeyContext(csp, CSSM_ALGID_DH, CSSM_ALGID_RC4, kSecretServiceDHPrimeSize * 8,
        NULL, &exchange->privateKey, 0, 0, NULL, &context) == CSSM_OK &&
        CSSM_DeriveKey(context, &peer, CSSM_KEYUSE_ANY, CSSM_KEYATTR_RETURN_DATA | CSSM_KEYATTR_EXTRACTABLE,
            &label, NULL, &derived) == CSSM_OK;
    if (context != 0)
        CSSM_DeleteContext(context);
    uint8_t shared[kSecretServiceDHPrimeSize];
    size_t length = derived.KeyData.Length;
    ok = ok && length > 0 && length <= sizeof(shared);
    if (ok) {
        /* the secret is a number of the prime's size: keep its leading zero bytes */
        memset(shared, 0, sizeof(shared) - length);
        memcpy(shared + sizeof(shared) - length, derived.KeyData.Data, length);
    }
    if (derived.KeyData.Data != NULL) {
        SecretServiceClear(derived.KeyData.Data, derived.KeyData.Length);
        CSSM_FreeKey(csp, NULL, &derived, CSSM_FALSE);
    }
    ok = ok && SecretServiceHKDFSHA256(shared, sizeof(shared), NULL, 0, NULL, 0, key, kSecretServiceKeySize);
    SecretServiceClear(shared, sizeof(shared));
    return ok;
}

#pragma mark - AES-128-CBC with PKCS #7 padding

static bool
CBC(CCOperation operation, const uint8_t key[kSecretServiceKeySize], const uint8_t iv[kSecretServiceIVSize],
    const uint8_t *input, size_t length, uint8_t *output)
{
    size_t moved = 0;
    return CCCrypt(operation, kCCAlgorithmAES, 0, key, kSecretServiceKeySize, iv, input, length,
        output, length, &moved) == kCCSuccess && moved == length;
}

/* 1 when x is not 0, without a branch on x. */
static uint32_t
NonZero(uint32_t x)
{
    return (x | (0u - x)) >> 31;
}

/*
 * The number of padding bytes at the end of a decrypted value of at least one
 * block, or 0 if the padding is not valid. It looks at the same bytes whatever
 * the padding is.
 */
static size_t
PaddingLength(const uint8_t *value, size_t length)
{
    uint32_t pad = value[length - 1];
    /* pad must be 1...16 */
    uint32_t bad = NonZero((pad - 1) >> 31) | NonZero((kCCBlockSizeAES128 - pad) >> 31);
    for (uint32_t i = 0; i < kCCBlockSizeAES128; i++) {
        uint32_t inPadding = (i - pad) >> 31;
        bad |= inPadding & NonZero(value[length - 1 - i] ^ pad);
    }
    return (size_t)(pad & (bad - 1));
}

bool
SecretServiceEncryptWithIV(const uint8_t key[kSecretServiceKeySize], const uint8_t iv[kSecretServiceIVSize],
    const uint8_t *input, size_t inputLength, uint8_t **output, size_t *outputLength)
{
    size_t pad = kCCBlockSizeAES128 - inputLength % kCCBlockSizeAES128;
    size_t length = inputLength + pad;
    if (length < inputLength)
        return false;
    uint8_t *padded = malloc(length);
    uint8_t *encrypted = malloc(length);
    bool ok = padded != NULL && encrypted != NULL;
    if (ok) {
        if (inputLength > 0)
            memcpy(padded, input, inputLength);
        memset(padded + inputLength, (int)pad, pad);
        ok = CBC(kCCEncrypt, key, iv, padded, length, encrypted);
    }
    if (padded != NULL)
        SecretServiceFreeSecret(padded, length);
    if (!ok) {
        free(encrypted);
        return false;
    }
    *output = encrypted;
    *outputLength = length;
    return true;
}

bool
SecretServiceEncrypt(const uint8_t key[kSecretServiceKeySize], const uint8_t *input, size_t inputLength,
    uint8_t iv[kSecretServiceIVSize], uint8_t **output, size_t *outputLength)
{
    if (SecRandomCopyBytes(kSecRandomDefault, kSecretServiceIVSize, iv) != errSecSuccess)
        return false;
    return SecretServiceEncryptWithIV(key, iv, input, inputLength, output, outputLength);
}

bool
SecretServiceDecrypt(const uint8_t key[kSecretServiceKeySize], const uint8_t *iv, size_t ivLength,
    const uint8_t *input, size_t inputLength, uint8_t **output, size_t *outputLength)
{
    if (iv == NULL || ivLength != kSecretServiceIVSize || inputLength == 0 ||
        inputLength % kCCBlockSizeAES128 != 0)
        return false;
    uint8_t *decrypted = malloc(inputLength);
    if (decrypted == NULL)
        return false;
    size_t pad = CBC(kCCDecrypt, key, iv, input, inputLength, decrypted) ?
        PaddingLength(decrypted, inputLength) : 0;
    if (pad == 0) {
        SecretServiceFreeSecret(decrypted, inputLength);
        return false;
    }
    /* the padding is not part of the value */
    SecretServiceClear(decrypted + inputLength - pad, pad);
    *output = decrypted;
    *outputLength = inputLength - pad;
    return true;
}
