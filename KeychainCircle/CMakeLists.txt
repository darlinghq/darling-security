project(KeychainCircle)

add_framework(KeychainCircle
	FAT
	CURRENT_VERSION
	VERSION "A"

	SOURCES
		../keychain/ot/proto/generated_source/OTApplicantToSponsorRound2M1.m
		../keychain/ot/proto/generated_source/OTPairingMessage.m
		../keychain/ot/proto/generated_source/OTSOSMessage.m
		../keychain/ot/proto/generated_source/OTSponsorToApplicantRound1M2.m
		../keychain/ot/proto/generated_source/OTSponsorToApplicantRound2M2.m
		generated_source/KCInitialMessageData.m
		KCAccountKCCircleDelegate.m
		KCAESGCMDuplexSession.m
		KCDer.m
		KCError.m
		KCJoiningAcceptSession.m
		KCJoiningMessages.m
		KCJoiningRequestCircleSession.m
		KCJoiningRequestSecretSession.m
		KCSRPContext.m
		NSData+SecRandom.m
		NSError+KCCreationHelpers.m
		PairingChannel.m

	DEPENDENCIES
		# frameworks
		#ProtocolBuffer # missing
		Security

		# dynamic libraries
		compression

		# static libraries
		utilities
)
