project(libsecurity_codesigning)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/lib
	${CMAKE_CURRENT_SOURCE_DIR}/antlr2
	${CMAKE_CURRENT_SOURCE_DIR}/../libsecurityd
	${CMAKE_CURRENT_SOURCE_DIR}/../sec
	${CMAKE_CURRENT_BINARY_DIR}/../libsecurityd
)

add_definitions(
	-Wno-unused-value
	-Wno-format
)

add_library(security_codesigning OBJECT
	antlr2/src/ANTLRUtil.cpp
	antlr2/src/ASTFactory.cpp
	antlr2/src/ASTNULLType.cpp
	antlr2/src/ASTRefCount.cpp
	antlr2/src/BaseAST.cpp
	antlr2/src/BitSet.cpp
	antlr2/src/CharBuffer.cpp
	antlr2/src/CharScanner.cpp
	lib/dirscanner.cpp
	antlr2/src/CommonAST.cpp
	antlr2/src/CommonASTWithHiddenTokens.cpp
	antlr2/src/CommonHiddenStreamToken.cpp
	antlr2/src/CommonToken.cpp
	antlr2/src/InputBuffer.cpp
	antlr2/src/LLkParser.cpp
	antlr2/src/MismatchedCharException.cpp
	antlr2/src/MismatchedTokenException.cpp
	antlr2/src/NoViableAltException.cpp
	antlr2/src/NoViableAltForCharException.cpp
	antlr2/src/Parser.cpp
	antlr2/src/RecognitionException.cpp
	antlr2/src/String.cpp
	antlr2/src/Token.cpp
	antlr2/src/TokenBuffer.cpp
	antlr2/src/TokenRefCount.cpp
	antlr2/src/TokenStreamBasicFilter.cpp
	antlr2/src/TokenStreamHiddenTokenFilter.cpp
	antlr2/src/TokenStreamRewriteEngine.cpp
	antlr2/src/TokenStreamSelector.cpp
	antlr2/src/TreeParser.cpp
	lib/bundlediskrep.cpp
	lib/cdbuilder.cpp
	lib/codedirectory.cpp
	lib/cs.cpp
	lib/SecCode.cpp
	lib/cskernel.cpp
	lib/SecStaticCode.cpp
	lib/csprocess.cpp
	lib/SecRequirement.cpp
	lib/diskrep.cpp
	lib/filediskrep.cpp
	lib/Code.cpp
	lib/kerneldiskrep.cpp
	lib/StaticCode.cpp
	lib/reqparser.cpp
	lib/requirement.cpp
	lib/Requirements.cpp
	lib/reqdumper.cpp
	lib/reqinterp.cpp
	lib/reqmaker.cpp
	lib/antlrplugin.cpp
	lib/machorep.cpp
	lib/SecCodeHost.cpp
	lib/csgeneric.cpp
	lib/SecCodeSigner.cpp
	lib/CodeSigner.cpp
	lib/signer.cpp
	lib/evaluationmanager.cpp
	lib/signerutils.cpp
	lib/sigblob.cpp
	lib/resources.cpp
	lib/csutilities.cpp
	lib/singlediskrep.cpp
	lib/reqreader.cpp
	lib/cserror.cpp
	lib/csdatabase.cpp
	lib/detachedrep.cpp
	lib/slcrep.cpp
	lib/SecTask.c
	lib/policydb.cpp
	lib/opaquewhitelist.cpp
	lib/SecAssessment.cpp
	lib/xpcengine.cpp
	lib/xar++.cpp
	#lib/policyengine.cpp			FIXME: Tons of missing constants
	#lib/diskimagerep.cpp 			FIXME: Present in a newer version?
	lib/quarantine++.cpp
	lib/drmaker.cpp
	lib/RequirementLexer.cpp
	lib/RequirementParser.cpp
	lib/piddiskrep.cpp

	lib/SecIntegrityLib.c
	#lib/SecCodeHostLib.c			FIXME: Multiple definitions of SecHostSetHostingPort
)

add_dependencies(security_codesigning securityd_client)
