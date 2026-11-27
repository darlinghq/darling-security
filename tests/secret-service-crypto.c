// Copyright (C) 2026 Lubos Dolezel
//
// Unit test of the transfer encryption of securityd's Secret Service backend
// (keychain/securityd/SecItemSecretServiceCrypto.c, compiled in here), without
// D-Bus or a Secret Service:
//
//   secret-service-crypto vectors
//       HKDF-SHA256 against the RFC 5869 test vectors (appendix A, cases 1-3;
//       case 3 has no salt and no info, as the session algorithm uses it),
//       AES-128-CBC against NIST SP 800-38A F.2.1 (CBC-AES128.Encrypt), PKCS #7
//       padding (RFC 5652 section 6.3) and its checks on decryption, fresh IVs,
//       and a Diffie-Hellman exchange in RFC 2409 group 2 between two contexts.
//   secret-service-crypto exchange <count> <peer public key, hex>
//       <count> exchanges, each with a new private key, with the given peer;
//       prints "public <hex> key <hex>" (this side's public key and the derived
//       session key) for each, for the driver secret-service-crypto.py to check
//       against its own computation.
//
// Prints PASS or FAIL lines and "ALL PASSED" or "FAILED <n>".
// The deployment target of the 32-bit build predates the CommonCrypto calls; Darling provides them in both slices.
#pragma clang diagnostic ignored "-Wunguarded-availability-new"

#include "../keychain/securityd/SecItemSecretServiceCrypto.c"

#include <CommonCrypto/CommonCryptor.h>
#include <stdio.h>

static int failures;

static void expect(int ok, const char *what) {
    printf("%s %s\n", ok ? "PASS" : "FAIL", what);
    fflush(stdout);
    if (!ok)
        failures++;
}

static size_t unhex(const char *hex, uint8_t *out, size_t capacity) {
    size_t n = 0;
    while (hex[0] != '\0' && hex[1] != '\0' && n < capacity) {
        unsigned value;
        if (sscanf(hex, "%2x", &value) != 1)
            break;
        out[n++] = (uint8_t)value;
        hex += 2;
    }
    return n;
}

static void printHex(const char *label, const uint8_t *bytes, size_t length) {
    printf("%s ", label);
    for (size_t i = 0; i < length; i++)
        printf("%02x", bytes[i]);
    if (strcmp(label, "public") != 0)
        printf("\n");
}

static void hkdfCase(const char *name, const uint8_t *ikm, size_t ikmLength, const uint8_t *salt, size_t saltLength,
    const uint8_t *info, size_t infoLength, const char *okmHex) {
    uint8_t expected[128], okm[128];
    size_t length = unhex(okmHex, expected, sizeof(expected));
    int ok = SecretServiceHKDFSHA256(ikm, ikmLength, salt, saltLength, info, infoLength, okm, length);
    expect(ok && memcmp(okm, expected, length) == 0, name);
}

static void hkdfVectors(void) {
    uint8_t ikm[80], salt[80], info[80];
    // RFC 5869 A.1: basic test case with SHA-256
    memset(ikm, 0x0b, 22);
    for (int i = 0; i < 13; i++)
        salt[i] = (uint8_t)i;
    for (int i = 0; i < 10; i++)
        info[i] = (uint8_t)(0xf0 + i);
    hkdfCase("HKDF-SHA256 RFC 5869 A.1", ikm, 22, salt, 13, info, 10,
        "3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf34007208d5b887185865");
    // RFC 5869 A.2: longer inputs and outputs
    for (int i = 0; i < 80; i++) {
        ikm[i] = (uint8_t)i;
        salt[i] = (uint8_t)(0x60 + i);
        info[i] = (uint8_t)(0xb0 + i);
    }
    hkdfCase("HKDF-SHA256 RFC 5869 A.2", ikm, 80, salt, 80, info, 80,
        "b11e398dc80327a1c8e7f78c596a49344f012eda2d4efad8a050cc4c19afa97c"
        "59045a99cac7827271cb41c65e590e09da3275600c2f09b8367793a9aca3db71"
        "cc30c58179ec3e87c14c01d5c1f3434f1d87");
    // RFC 5869 A.3: zero-length salt and info
    memset(ikm, 0x0b, 22);
    hkdfCase("HKDF-SHA256 RFC 5869 A.3 (no salt, no info)", ikm, 22, NULL, 0, NULL, 0,
        "8da4e775a563c18f715f802a063c5a31b8a11f5c5ee1879ec3454e5f3c738d2d9d201395faa4b61a96c8");
}

// raw AES-128-CBC without padding, to build and inspect blocks
static int rawCBC(CCOperation op, const uint8_t *key, const uint8_t *iv, const uint8_t *in, size_t length, uint8_t *out) {
    size_t moved = 0;
    return CCCrypt(op, kCCAlgorithmAES, 0, key, 16, iv, in, length, out, length, &moved) == kCCSuccess && moved == length;
}

static void aesVectors(void) {
    // NIST SP 800-38A F.2.1 CBC-AES128.Encrypt
    uint8_t key[16], iv[16], plain[64], cipher[64];
    unhex("2b7e151628aed2a6abf7158809cf4f3c", key, 16);
    unhex("000102030405060708090a0b0c0d0e0f", iv, 16);
    unhex("6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e51"
          "30c81c46a35ce411e5fbc1191a0a52eff69f2445df4f9b17ad2b417be66c3710", plain, 64);
    unhex("7649abac8119b246cee98e9b12e9197d5086cb9b507219ee95db113a917678b2"
          "73bed6b8e3c1743b7116e69e222295163ff1caa1681fac09120eca307586e1a7", cipher, 64);

    uint8_t *out = NULL, *back = NULL;
    size_t outLength = 0, backLength = 0;
    int ok = SecretServiceEncryptWithIV(key, iv, plain, 64, &out, &outLength);
    expect(ok && outLength == 80, "AES-128-CBC/PKCS7: 64 bytes encrypt to 80 (a whole padding block)");
    expect(ok && memcmp(out, cipher, 64) == 0, "AES-128-CBC: NIST SP 800-38A F.2.1 ciphertext");
    uint8_t padBlock[16], allSixteen[16];
    memset(allSixteen, 16, 16);
    expect(ok && rawCBC(kCCDecrypt, key, out + 48, out + 64, 16, padBlock) && memcmp(padBlock, allSixteen, 16) == 0,
        "PKCS7: the padding block is sixteen bytes of 16");
    ok = ok && SecretServiceDecrypt(key, iv, 16, out, outLength, &back, &backLength);
    expect(ok && backLength == 64 && memcmp(back, plain, 64) == 0, "AES-128-CBC/PKCS7: the NIST plaintext decrypts back");
    free(out);
    free(back);

    // every length up to two blocks round-trips and pads to the next block
    int roundTrips = 1;
    for (size_t n = 0; n <= 33; n++) {
        out = back = NULL;
        if (!SecretServiceEncryptWithIV(key, iv, plain, n, &out, &outLength) || outLength != (n / 16 + 1) * 16 ||
            !SecretServiceDecrypt(key, iv, 16, out, outLength, &back, &backLength) || backLength != n ||
            (n > 0 && memcmp(back, plain, n) != 0))
            roundTrips = 0;
        free(out);
        free(back);
    }
    expect(roundTrips, "PKCS7: lengths 0..33 pad to the next whole block and round-trip");

    // blocks whose padding is bad are refused; good short padding is removed
    struct { const char *name; uint8_t tail[3]; int good; size_t length; } pads[] = {
        { "PKCS7: a last byte of 0 is refused", { 'x', 'x', 0x00 }, 0, 0 },
        { "PKCS7: a last byte above 16 is refused", { 'x', 'x', 0x11 }, 0, 0 },
        { "PKCS7: inconsistent padding bytes are refused", { 'x', 0x03, 0x02 }, 0, 0 },
        { "PKCS7: one byte of padding is removed", { 'x', 'x', 0x01 }, 1, 15 },
        { "PKCS7: two bytes of padding are removed", { 'x', 0x02, 0x02 }, 1, 14 },
    };
    for (size_t i = 0; i < sizeof(pads) / sizeof(pads[0]); i++) {
        uint8_t block[16], encrypted[16];
        memset(block, 'x', 16);
        memcpy(block + 13, pads[i].tail, 3);
        back = NULL;
        ok = rawCBC(kCCEncrypt, key, iv, block, 16, encrypted) &&
            SecretServiceDecrypt(key, iv, 16, encrypted, 16, &back, &backLength);
        expect(pads[i].good ? ok && backLength == pads[i].length : !ok, pads[i].name);
        free(back);
    }

    back = NULL;
    expect(!SecretServiceDecrypt(key, iv, 15, cipher, 16, &back, &backLength), "decrypt: an IV that is not 16 bytes is refused");
    expect(!SecretServiceDecrypt(key, iv, 16, cipher, 0, &back, &backLength), "decrypt: an empty value is refused");
    expect(!SecretServiceDecrypt(key, iv, 16, cipher, 17, &back, &backLength), "decrypt: a partial block is refused");
    expect(!SecretServiceDecrypt(key, NULL, 0, cipher, 16, &back, &backLength), "decrypt: no IV is refused");

    // a fresh IV for every secret
    uint8_t iv1[16], iv2[16];
    uint8_t *c1 = NULL, *c2 = NULL;
    size_t l1 = 0, l2 = 0;
    ok = SecretServiceEncrypt(key, plain, 20, iv1, &c1, &l1) && SecretServiceEncrypt(key, plain, 20, iv2, &c2, &l2);
    expect(ok && memcmp(iv1, iv2, 16) != 0 && l1 == l2 && memcmp(c1, c2, l1) != 0,
        "encrypt: two encryptions of one value use different IVs and give different ciphertexts");
    ok = ok && SecretServiceDecrypt(key, iv1, 16, c1, l1, &back, &backLength);
    expect(ok && backLength == 20 && memcmp(back, plain, 20) == 0, "encrypt: the value decrypts with its own IV");
    free(c1);
    free(c2);
    free(back);
}

static void dhSelfExchange(void) {
    uint8_t publicA[kSecretServiceDHPrimeSize], publicB[kSecretServiceDHPrimeSize];
    size_t lengthA = 0, lengthB = 0;
    SecretServiceDHRef a = SecretServiceDHCreate(publicA, &lengthA);
    SecretServiceDHRef b = SecretServiceDHCreate(publicB, &lengthB);
    expect(a != NULL && b != NULL, "DH: two group 2 exchanges start");
    if (a == NULL || b == NULL)
        return;
    expect(lengthA > 64 && lengthA <= 128 && lengthB > 64 && lengthB <= 128, "DH: the public keys are at most 128 bytes");
    expect(lengthA != lengthB || memcmp(publicA, publicB, lengthA) != 0, "DH: the two public keys differ");
    uint8_t keyA[16], keyB[16], zero[16] = { 0 };
    int ok = SecretServiceDHDeriveKey(a, publicB, lengthB, keyA) && SecretServiceDHDeriveKey(b, publicA, lengthA, keyB);
    expect(ok && memcmp(keyA, keyB, 16) == 0 && memcmp(keyA, zero, 16) != 0, "DH: both sides derive the same session key");
    expect(!SecretServiceDHDeriveKey(a, publicB, 0, keyA), "DH: an empty peer key is refused");
    uint8_t tooLong[129];
    memset(tooLong, 0x01, sizeof(tooLong));
    expect(!SecretServiceDHDeriveKey(a, tooLong, sizeof(tooLong), keyA), "DH: a peer key longer than the prime is refused");
    // the public values 0, 1, p - 1 and p are refused (NIST SP 800-56A partial public key validation)
    uint8_t prime[128], value[128];
    memcpy(prime, kGroup2Prime, 128);
    memset(value, 0, 128);
    int refused = !SecretServiceDHDeriveKey(a, value, 128, keyA);
    value[127] = 1;
    refused = refused && !SecretServiceDHDeriveKey(a, value, 128, keyA) && !SecretServiceDHDeriveKey(a, value, 1, keyA);
    memcpy(value, prime, 128);
    refused = refused && !SecretServiceDHDeriveKey(a, value, 128, keyA);
    value[127] -= 1;
    refused = refused && !SecretServiceDHDeriveKey(a, value, 128, keyA);
    value[127] -= 1;
    int accepted = SecretServiceDHDeriveKey(a, value, 128, keyA);
    uint8_t two = 2;
    accepted = accepted && SecretServiceDHDeriveKey(a, &two, 1, keyA);
    expect(refused, "DH: the peer values 0, 1, p - 1 and p are refused");
    expect(accepted, "DH: the peer values 2 and p - 2 are accepted");
    SecretServiceDHRelease(a);
    SecretServiceDHRelease(b);
}

int main(int argc, char **argv) {
    if (argc == 2 && strcmp(argv[1], "vectors") == 0) {
        hkdfVectors();
        aesVectors();
        dhSelfExchange();
    } else if (argc == 4 && strcmp(argv[1], "exchange") == 0) {
        uint8_t peer[kSecretServiceDHPrimeSize], publicKey[kSecretServiceDHPrimeSize], key[16];
        size_t peerLength = unhex(argv[3], peer, sizeof(peer));
        int count = atoi(argv[2]), completed = 0;
        for (int i = 0; i < count; i++) {
            size_t publicLength = 0;
            SecretServiceDHRef exchange = SecretServiceDHCreate(publicKey, &publicLength);
            if (exchange != NULL && SecretServiceDHDeriveKey(exchange, peer, peerLength, key)) {
                printHex("public", publicKey, publicLength);
                printHex(" key", key, sizeof(key));
                completed++;
            }
            if (exchange != NULL)
                SecretServiceDHRelease(exchange);
        }
        expect(count > 0 && completed == count, "DH: every exchange with the given peer key completes");
    } else {
        fprintf(stderr, "usage: secret-service-crypto vectors | exchange <count> <peer public key hex>\n");
        return 2;
    }
    printf(failures ? "FAILED %d\n" : "ALL PASSED\n", failures);
    return failures ? 1 : 0;
}
