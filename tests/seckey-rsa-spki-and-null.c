#include <CoreFoundation/CoreFoundation.h>
#include <Security/Security.h>
#include <stdint.h>
#include <stdio.h>

#define CHECK(c) do { if (!(c)) { fprintf(stderr, "FAIL: %s (line %d)\n", #c, __LINE__); return 1; } } while (0)

/* Valid P-256 EC SubjectPublicKeyInfo (must be rejected when kSecAttrKeyTypeRSA is requested). */
static const uint8_t kEcP256Spki[] = {
    0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02,
    0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03,
    0x42, 0x00, 0x04,
    0x6b, 0x17, 0xd1, 0xf2, 0xe1, 0x2c, 0x42, 0x47, 0xf8, 0xbc, 0xe6, 0xe5,
    0x63, 0xa4, 0x40, 0xf2, 0x77, 0x03, 0x7d, 0x81, 0x2d, 0xeb, 0x33, 0xa0,
    0xf4, 0xa1, 0x39, 0x45, 0xd8, 0x98, 0xc2, 0x96,
    0x4f, 0xe3, 0x42, 0xe2, 0xfe, 0x1a, 0x7f, 0x9b, 0x8e, 0xe7, 0xeb, 0x4a,
    0x7c, 0x0f, 0x9e, 0x16, 0x2b, 0xce, 0x33, 0x57, 0x6b, 0x31, 0x5e, 0xce,
    0xcb, 0xb6, 0x40, 0x68, 0x37, 0xbf, 0x51, 0xf5,
};

/* Minimal valid 512-bit RSA SubjectPublicKeyInfo (n=0xc0..3f, e=65537). */
static const uint8_t kRsa512Spki[] = {
    0x30, 0x5c,
    0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00,
    0x03, 0x4b, 0x00,
    0x30, 0x48,
    0x02, 0x41, 0x00,
    0xc0, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
    0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f,
    0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f,
    0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f,
    0x02, 0x03, 0x01, 0x00, 0x01,
};

int main(void) {
    CHECK(SecKeyCopyPublicKey(NULL) == NULL);

    CFErrorRef err = NULL;
    CHECK(SecKeyCopyExternalRepresentation(NULL, &err) == NULL);
    CHECK(err != NULL && CFErrorGetCode(err) == errSecParam);
    CFRelease(err);

    const void *rsaKeys[] = { kSecAttrKeyType, kSecAttrKeyClass };
    const void *rsaVals[] = { kSecAttrKeyTypeRSA, kSecAttrKeyClassPublic };
    CFDictionaryRef rsaAttrs = CFDictionaryCreate(NULL, rsaKeys, rsaVals, 2,
        &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    /* Positive RSA SPKI import. */
    CFDataRef rsaSpkiData = CFDataCreate(NULL, kRsa512Spki, sizeof(kRsa512Spki));
    err = NULL;
    SecKeyRef rsaKey = SecKeyCreateWithData(rsaSpkiData, rsaAttrs, &err);
    CHECK(rsaKey != NULL && err == NULL);
    CHECK(SecKeyGetBlockSize(rsaKey) == 64);
    err = NULL;
    CFDataRef ext = SecKeyCopyExternalRepresentation(rsaKey, &err);
    CHECK(ext != NULL && err == NULL);
    CFRelease(ext);
    CFRelease(rsaKey);
    CFRelease(rsaSpkiData);

    /* Non-zero unusedBits (byte 19 = 0x01 instead of 0x00) must fail. */
    uint8_t badUnused[sizeof(kRsa512Spki)];
    for (size_t i = 0; i < sizeof(kRsa512Spki); i++) badUnused[i] = kRsa512Spki[i];
    badUnused[19] = 0x01;
    CFDataRef badUnusedData = CFDataCreate(NULL, badUnused, sizeof(badUnused));
    err = NULL;
    CHECK(SecKeyCreateWithData(badUnusedData, rsaAttrs, &err) == NULL && err != NULL);
    CFRelease(err);
    CFRelease(badUnusedData);

    /* A trailing byte after the outer SPKI SEQUENCE is ignored, as on macOS (see the QUIRK in SecKey.m and
     * tests/seckey-rsa-public-import.c): the leading key is imported. */
    uint8_t trailing[sizeof(kRsa512Spki) + 1];
    for (size_t i = 0; i < sizeof(kRsa512Spki); i++) trailing[i] = kRsa512Spki[i];
    trailing[sizeof(kRsa512Spki)] = 0x00;
    CFDataRef trailingData = CFDataCreate(NULL, trailing, sizeof(trailing));
    err = NULL;
    SecKeyRef trailingKey = SecKeyCreateWithData(trailingData, rsaAttrs, &err);
    CHECK(trailingKey != NULL && err == NULL);
    if (trailingKey) CFRelease(trailingKey);
    CFRelease(trailingData);

    /* EC SPKI under kSecAttrKeyTypeRSA must fail. */
    CFDataRef ecData = CFDataCreate(NULL, kEcP256Spki, sizeof(kEcP256Spki));
    err = NULL;
    CHECK(SecKeyCreateWithData(ecData, rsaAttrs, &err) == NULL && err != NULL);
    CFRelease(err);
    CFRelease(ecData);

    const void *ecPrivKeys[] = { kSecAttrKeyType, kSecAttrKeySizeInBits };
    int bits = 256;
    CFNumberRef bitsNum = CFNumberCreate(NULL, kCFNumberIntType, &bits);
    const void *ecPrivVals[] = { kSecAttrKeyTypeECSECPrimeRandom, bitsNum };
    CFDictionaryRef ecAttrs = CFDictionaryCreate(NULL, ecPrivKeys, ecPrivVals, 2,
        &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    err = NULL;
    SecKeyRef ecPriv = SecKeyCreateRandomKey(ecAttrs, &err);
    CHECK(ecPriv != NULL && err == NULL);
    SecKeyRef ecPub = SecKeyCopyPublicKey(ecPriv);
    CHECK(ecPub != NULL);
    CFRelease(ecPub);
    CFRelease(ecPriv);
    CFRelease(bitsNum);
    CFRelease(ecAttrs);
    CFRelease(rsaAttrs);

    puts("PASS");
    return 0;
}
