#define __CONSTANT_CFSTRINGS__  1
#include <CoreFoundation/CFString.h>

/*
 * These constants are all ones that are present in libsecurity_keychain/lib/SecItemConstants.c
 * but not in sec/Security/SecItemConstants.c. This file was created to resolve that issue.
*/

#define SEC_CONST_DECL(k,v) const CFTypeRef k = CFSTR(v);

SEC_CONST_DECL (kSecAttrAccess, "acls");
SEC_CONST_DECL (kSecAttrPRF, "prf");
SEC_CONST_DECL (kSecAttrSalt, "salt");
SEC_CONST_DECL (kSecAttrRounds, "rounds");
SEC_CONST_DECL (kSecAttrNoLegacy, "nleg");
SEC_CONST_DECL (kSecMatchSubjectStartsWith, "m_SubjectStartsWith");
SEC_CONST_DECL (kSecMatchSubjectEndsWith, "m_SubjectEndsWith");
SEC_CONST_DECL (kSecMatchSubjectWholeString, "m_SubjectWholeString");
SEC_CONST_DECL (kSecMatchDiacriticInsensitive, "m_DiacriticInsensitive");
SEC_CONST_DECL (kSecMatchWidthInsensitive, "m_WidthInsensitive");
SEC_CONST_DECL (kSecAttrKeyTypeDES, "14");
SEC_CONST_DECL (kSecAttrKeyType3DES, "17");
SEC_CONST_DECL (kSecAttrKeyTypeRC2, "23");
SEC_CONST_DECL (kSecAttrKeyTypeRC4, "25");
SEC_CONST_DECL (kSecAttrKeyTypeDSA, "43");
SEC_CONST_DECL (kSecAttrKeyTypeCAST, "56");
SEC_CONST_DECL (kSecAttrKeyTypeECDSA, "73");
SEC_CONST_DECL (kSecAttrKeyTypeAES, "2147483649");
SEC_CONST_DECL (kSecAttrPRFHmacAlgSHA1, "hsha1");
SEC_CONST_DECL (kSecAttrPRFHmacAlgSHA224, "hsha224");
SEC_CONST_DECL (kSecAttrPRFHmacAlgSHA256, "hsha256");
SEC_CONST_DECL (kSecAttrPRFHmacAlgSHA384, "hsha384");
SEC_CONST_DECL (kSecAttrPRFHmacAlgSHA512, "hsha512");
SEC_CONST_DECL (kSecSymmetricKeyAttrs, "symmetric");
