/*
 * Copyright (c) 2026 Lubos Dolezel
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef _SECITEM_SECRET_SERVICE_CRYPTO_H_
#define _SECITEM_SECRET_SERVICE_CRYPTO_H_

/*
 * The transfer encryption of the Secret Service session algorithm
 * "dh-ietf1024-sha256-aes128-cbc-pkcs7" (freedesktop Secret Service API,
 * "Transfer of Secrets"): a Diffie-Hellman exchange in the 1024-bit MODP group
 * of RFC 2409 (group 2), HKDF-SHA256 (RFC 5869) of the shared secret with no
 * salt and no info to a 128-bit key, and AES-128-CBC with PKCS #7 padding and a
 * fresh random IV for every secret. The key exchange is done by the Security
 * framework's CSSM interface (the Apple CSP's Diffie-Hellman), the key
 * derivation and the cipher by CommonCrypto, the IVs by SecRandomCopyBytes;
 * only the PKCS #7 padding (RFC 5652 section 6.3), an encoding, is done here.
 */

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#define kSecretServiceDHAlgorithm "dh-ietf1024-sha256-aes128-cbc-pkcs7"
#define kSecretServiceKeySize 16
#define kSecretServiceIVSize 16
/* The size of the group's prime, which is also the size of the shared secret. */
#define kSecretServiceDHPrimeSize 128

/* HKDF with SHA-256 (RFC 5869); salt and info may be empty. */
bool SecretServiceHKDFSHA256(const void *inputKey, size_t inputKeyLength,
    const void *salt, size_t saltLength, const void *info, size_t infoLength,
    void *outputKey, size_t outputKeyLength);

typedef struct SecretServiceDH *SecretServiceDHRef;

/*
 * Starts an exchange: a new private key in the group, and its public key as a
 * big-endian number in publicKey (at most kSecretServiceDHPrimeSize bytes).
 * Returns NULL on failure.
 */
SecretServiceDHRef SecretServiceDHCreate(uint8_t publicKey[kSecretServiceDHPrimeSize], size_t *publicKeyLength);

/* Frees the exchange and its private key. */
void SecretServiceDHRelease(SecretServiceDHRef exchange);

/*
 * Finishes the exchange with the peer's public key (big-endian) and derives the
 * session key. The shared secret is used as kSecretServiceDHPrimeSize bytes,
 * with leading zeros, as the algorithm defines, and is cleared before return.
 */
bool SecretServiceDHDeriveKey(SecretServiceDHRef exchange, const uint8_t *peerPublicKey, size_t peerPublicKeyLength,
    uint8_t key[kSecretServiceKeySize]);

/* AES-128-CBC with PKCS #7 padding under the given IV. *output is malloc'ed. */
bool SecretServiceEncryptWithIV(const uint8_t key[kSecretServiceKeySize], const uint8_t iv[kSecretServiceIVSize],
    const uint8_t *input, size_t inputLength, uint8_t **output, size_t *outputLength);

/* The same with a fresh random IV, which is returned in iv. */
bool SecretServiceEncrypt(const uint8_t key[kSecretServiceKeySize], const uint8_t *input, size_t inputLength,
    uint8_t iv[kSecretServiceIVSize], uint8_t **output, size_t *outputLength);

/*
 * Decrypts and removes the padding. Fails for an IV that is not 16 bytes, an
 * input that is not a whole number of blocks, or bad padding. *output is
 * malloc'ed; release it with SecretServiceFreeSecret.
 */
bool SecretServiceDecrypt(const uint8_t key[kSecretServiceKeySize], const uint8_t *iv, size_t ivLength,
    const uint8_t *input, size_t inputLength, uint8_t **output, size_t *outputLength);

/* Clears a buffer in a way the compiler keeps. */
void SecretServiceClear(void *buffer, size_t length);

/* Clears and frees a buffer that held a secret. */
void SecretServiceFreeSecret(void *buffer, size_t length);

#endif /* _SECITEM_SECRET_SERVICE_CRYPTO_H_ */
