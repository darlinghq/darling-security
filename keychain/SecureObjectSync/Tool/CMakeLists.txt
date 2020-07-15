project(SOSCommands)

add_lib_ios(SOSCommands
	SOURCES
		accountCirclesViewsPrint.m
		keychain_log.m
		keychain_sync_test.m
		keychain_sync.m
		recovery_key.m
		secToolFileIO.c
		secViewDisplay.c
		syncbackup.m
)
