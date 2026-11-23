/*
 * This file is part of Darling.
 *
 * Copyright (C) 2026 Lubos Dolezel
 *
 * Darling is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Darling is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Darling.  If not, see <http://www.gnu.org/licenses/>.
 */

// The pre-login user database describes the users that can unlock an APFS
// volume before login (FileVault). It is built from the volume's preboot
// data, which a Darling prefix does not have, so authd has no database to
// read. The functions keep the argument checks of the original interface and
// report that the database cannot be read, the same answer the interface gives
// on a system whose database fails to load.

#include "PreloginUserDb.h"
#include <Security/Authorization.h>
#include <Security/SecBase.h>

OSStatus preloginudb_copy_userdb(const char * _Nullable uuid, UInt32 flags, CFArrayRef _Nonnull * _Nonnull output)
{
    if (!output) {
        return errAuthorizationBadAddress;
    }
    return errAuthorizationInternal;
}

OSStatus prelogin_copy_pref_value(const char * _Nullable uuid, const char * _Nullable user, const char * _Nonnull domain, const char * _Nonnull item, CFTypeRef _Nonnull * _Nonnull output)
{
    if (!output || !uuid) {
        return errAuthorizationBadAddress;
    }
    return errAuthorizationInternal;
}

OSStatus prelogin_smartcardonly_override(const char * _Nonnull uuid, unsigned char operation, Boolean * _Nullable status)
{
    if (!uuid) {
        return errSecParam;
    }
    return errAuthorizationInternal;
}
