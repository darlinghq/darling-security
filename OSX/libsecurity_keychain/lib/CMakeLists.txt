project(libsecurity_keychain)

cmake_minimum_required(VERSION 2.4.0)
enable_language(C ASM)

if(COMMAND cmake_policy)
	cmake_policy(SET CMP0003 NEW)
	cmake_policy(SET CMP0005 NEW)
endif(COMMAND cmake_policy)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -msse -msse2 -msse3 -w -nostdinc -fblocks")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D__DARWIN_UNIX03 -fPIC -w")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdinc -nostdinc++ -fblocks -Wno-deprecated -fPIC")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -nostdlib -Wl,--version-script=${DARLING_TOP_DIRECTORY}/darwin.map")

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/..)
include_directories(${CMAKE_SOURCE_DIR}/src/external/corefoundation/Headers)
include_directories(${CMAKE_BINARY_DIR}/src/external/corefoundation/Headers)
include_directories(${CMAKE_SOURCE_DIR}/src/external/foundation/Headers)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libcxx/include)
include_directories(${CMAKE_SOURCE_DIR}/src/external/libdispatch)
include_directories(${CMAKE_SOURCE_DIR}/src/CommonCrypto)

add_definitions(-DOBJC2RUNTIME=1)

set(security_keychain_sources
	Access.cpp
	ACL.cpp
	Certificate.cpp
	CertificateRequest.cpp
	CertificateValues.cpp
	cssmdatetime.cpp
	defaultcreds.cpp
	DLDBListCFPref.cpp
	DynamicDLDBList.cpp
	ExtendedAttribute.cpp
	Globals.cpp
	Identity.cpp
	IdentityCursor.cpp
	Item.cpp
	KCCursor.cpp
	KCEventNotifier.cpp
	KCUtilities.cpp
	Keychains.cpp
	KeyItem.cpp
	Password.cpp
	Policies.cpp
	PolicyCursor.cpp
	PrimaryKey.cpp
	SecAccess.cpp
	SecACL.cpp
	SecBase.cpp
	SecCertificateBundle.cpp
	SecCertificate.cpp
	SecCertificateRequest.cpp
	SecCFTypes.cpp
	SecExport.cpp
	SecExternalRep.cpp
	SecFDERecoveryAsymmetricCrypto.cpp
	SecIdentity.cpp
	SecIdentitySearch.cpp
	SecImport.cpp
	SecImportExportAgg.cpp
	SecImportExportCrypto.cpp
	SecImportExportOpenSSH.cpp
	SecImportExportPem.cpp
	SecImportExportPkcs8.cpp
	SecImportExportUtils.cpp
	SecItem.cpp
	SecKeychainAddIToolsPassword.cpp
	SecKeychain.cpp
	SecKeychainItem.cpp
	SecKeychainItemExtendedAttributes.cpp
	SecKeychainSearch.cpp
	SecKey.cpp
	SecNetscapeTemplates.cpp
	SecPassword.cpp
	SecPkcs8Templates.cpp
	SecPolicy.cpp
	SecPolicySearch.cpp
	SecTrust.cpp
	SecTrustedApplication.cpp
	SecTrustSettings.cpp
	SecWrappedKeys.cpp
	StorageManager.cpp
	TrustAdditions.cpp
	Trust.cpp
	TrustedApplication.cpp
	TrustItem.cpp
	TrustRevocation.cpp
	TrustSettings.cpp
	TrustSettingsUtils.cpp
	TrustStore.cpp
	UnlockReferralItem.cpp
)

add_library(security_keychain OBJECT ${security_keychain_sources})

