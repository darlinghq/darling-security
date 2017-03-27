project(libsecurity_cryptkit)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/lib
	${CMAKE_SOURCE_DIR}/src/external/cfnetwork/include
	${CMAKE_SOURCE_DIR}/src/external/foundation/src
	${CMAKE_SOURCE_DIR}/src/external/coregraphics/Headers
)

add_definitions(
	-Wno-unused-value
	-Wno-format
	-DCK_SECURITY_BUILD
)

add_library(security_cryptkit OBJECT
	lib/byteRep.c
	lib/CipherFileDES.c
	lib/CipherFileFEED.c
	lib/ckDES.c
	lib/ckMD5.c
	lib/ckSHA1.c
	lib/ckSHA1_priv.c
	lib/ckutilities.c
	lib/CryptKitAsn1.cpp
	lib/CryptKitDER.cpp
	lib/curveParams.c
	lib/elliptic.c
	lib/ellipticProj.c
	lib/enc64.c
	lib/engineNSA127.c
	lib/falloc.c
	#lib/feeCipherFileAtom.c
	#lib/feeCipherFile.c
	lib/feeDES.c
	lib/feeDigitalSignature.c
	lib/feeECDSA.c
	lib/feeFEED.c
	lib/feeFEEDExp.c
	lib/feeHash.c
	lib/feePublicKey.c
	lib/feeRandom.c
	#lib/giantFFT.c
	lib/giantIntegers.c
	lib/giantPort_PPC.c
	lib/HmacSha1Legacy.c
	lib/mutils.m
	#lib/NSCipherFile.m
	#lib/NSDESCryptor.m
	#lib/NSFEEPublicKey.m
	#lib/NSMD5Hash.m
	#lib/NSRandomNumberGenerator.m
	lib/platform.c
)

