project(libsecurity_cryptkit)

add_macos_legacy_lib(security_cryptkit
	SOURCES
		lib/byteRep.c
		lib/ckSHA1.c
		lib/ckutilities.c
		lib/CryptKitAsn1.cpp
		lib/CryptKitDER.cpp
		lib/curveParams.c
		lib/elliptic.c
		lib/ellipticProj.c
		lib/enc64.c
		lib/falloc.c
		lib/feeDigitalSignature.c
		lib/feeECDSA.c
		lib/feeFEED.c
		lib/feeFEEDExp.c
		lib/feeHash.c
		lib/feePublicKey.c
		lib/feeRandom.c
		lib/giantIntegers.c
		lib/HmacSha1Legacy.c
		lib/platform.c
	DEFINITIONS
		CK_SECURITY_BUILD
)
