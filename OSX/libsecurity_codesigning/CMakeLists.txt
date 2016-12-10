project(libsecurity_codesigning)

include_directories(
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/lib
	${CMAKE_CURRENT_SOURCE_DIR}/antlr2
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
	#lib/codedirectory.cpp			FIXME: dispatch_qos_class_t
	lib/cs.cpp
	#lib/SecCode.cpp			FIXME: dispatch_qos_class_t
	#lib/cskernel.cpp			FIXME: dispatch_qos_class_t
	#lib/SecStaticCode.cpp			FIXME: dispatch_qos_class_t
	#lib/csprocess.cpp			FIXME: dispatch_qos_class_t
	lib/SecRequirement.cpp
	lib/diskrep.cpp
	#lib/filediskrep.cpp			FIXME: dispatch_qos_class_t
	#lib/Code.cpp				FIXME: dispatch_qos_class_t
	lib/kerneldiskrep.cpp
	#lib/StaticCode.cpp			FIXME: dispatch_qos_class_t
	lib/reqparser.cpp
	lib/requirement.cpp
	lib/Requirements.cpp
	lib/reqdumper.cpp
	#lib/reqinterp.cpp			FIXME: dispatch_qos_class_t
	lib/reqmaker.cpp
	#lib/antlrplugin.cpp			FIXME: CF_BRIDGED_TYPE
	#lib/machorep.cpp			FIXME: dispatch_qos_class_t
	lib/SecCodeHost.cpp
	#lib/csgeneric.cpp			FIXME: dispatch_qos_class_t
	#lib/SecCodeSigner.cpp			FIXME: dispatch_qos_class_t
	#lib/CodeSigner.cpp			FIXME: dispatch_qos_class_t
	#lib/signer.cpp				FIXME: dispatch_qos_class_t
	#lib/evaluationmanager.cpp		FIXME: dispatch_qos_class_t
	#lib/signerutils.cpp			FIXME: dispatch_qos_class_t
	lib/sigblob.cpp
	#lib/resources.cpp			FIXME: dispatch_qos_class_t
	#lib/csutilities.cpp			FIXME: dispatch_qos_class_t
	#lib/singlediskrep.cpp			FIXME: dispatch_qos_class_t
	#lib/reqreader.cpp			FIXME: dispatch_qos_class_t
	lib/cserror.cpp
	lib/csdatabase.cpp
	lib/detachedrep.cpp
	#lib/slcrep.cpp				FIXME: CODESIGN_DISKREP_CREATE_SLC
	#lib/SecTask.c				FIXME: CF_BRIDGED_TYPE
	lib/policydb.cpp
	#lib/opaquewhitelist.cpp		FIXME: dispatch_qos_class_t
	#lib/SecAssessment.cpp			FIXME: dispatch_qos_class_t
	lib/xpcengine.cpp
	lib/xar++.cpp
	#lib/policyengine.cpp			FIXME: CF_BRIDGED_TYPE
	#lib/diskimagerep.cpp 			FIXME: Present in a newer version?
	lib/quarantine++.cpp
	#lib/drmaker.cpp			FIXME: dispatch_qos_class_t
	#lib/RequirementLexer.cpp		FIXME: dispatch_qos_class_t
	#lib/RequirementParser.cpp		FIXME: dispatch_qos_class_t
	lib/piddiskrep.cpp

	#lib/SecIntegrityLib.c			FIXME: CF_BRIDGED_TYPE
	#lib/SecCodeHostLib.c			FIXME: CF_BRIDGED_TYPE
	
)
