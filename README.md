# darling-security

## Upstream URL

https://github.com/apple-oss-distributions/Security/tree/Security-59754.140.13

## Optional Secret Service backend

`securityd` can store generic and internet password items in the host's
freedesktop Secret Service (GNOME Keyring, KWallet, KeePassXC, ...) instead of
the keychain database in the prefix. It is **off by default**; with the setting
off nothing changes, and no D-Bus connection is made.

Switch it on in the prefix with

```sh
defaults write org.darlinghq.security SecretServiceBackend -bool YES
```

and restart the prefix (`darling shutdown`), so that `secd` reads it again. The
backend talks to the host's session bus (`DBUS_SESSION_BUS_ADDRESS`, or
`$XDG_RUNTIME_DIR/bus`) through Darling's libdbus wrapper, uses the "plain"
Secret Service session and the collection that the service names `default`. If
the bus, the service or the default collection is missing, or a call fails to
reach the service, the backend turns itself off until `secd` restarts and the
keychain database is used.

What leaves the prefix when it is on: for each generic or internet password
item that is added with a service and an account (or a server and an account),
its secret value and its service, account, access group, server, protocol,
port, path, security domain, authentication type, generic, label, description,
comment, creator and type attributes are sent to the host's Secret Service,
where any process of the host user that can use the session bus can read them
like any other Secret Service entry. The secret travels unencrypted over the
local session bus ("plain" session). Keys, certificates, identities and every
other item remain in the prefix's keychain database.

Behavior: copy (data only), update, delete and add of those items go to the
service; an item that the service does not hold is looked up in the database as
before, so items stored earlier stay reachable. Queries that ask for
attributes, references or several results are answered from the database only.
The service has no access groups, entitlements or ACLs; the checks `securityd`
makes before the backend is called are unchanged, and the backend adds none. A
locked collection is unlocked when the service allows it without a prompt;
otherwise the call fails with `errSecInteractionNotAllowed`.

## Updating Source

When updating the source code, make sure to refer to the [`Updating Sources`](https://docs.darlinghq.org/contributing/updating-sources/index.html#updating-sources) section from the Darling Docs website. Additional details (if any) can be found in [`darling/notes/UPDATE_SOURCE.md`](darling/notes/UPDATE_SOURCE.md).