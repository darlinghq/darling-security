# darling-security

## Upstream URL

https://github.com/apple-oss-distributions/Security/tree/Security-59754.140.13

## Optional Secret Service backend

`securityd` can optionally store generic and internet password items in the
freedesktop Secret Service through `libsecret`. This is disabled by default.

Build with:

```sh
cmake -DDARLING_SECURITY_USE_SECRET_SERVICE=ON ...
```

If `libsecret-1` is unavailable at build time, or the Secret Service is
unavailable at runtime, `securityd` starts normally and the ordinary SQLite
keychain backend is used. Darling never requires a session bus or a running
keyring daemon for this feature.

The backend does not provide macOS access groups, entitlements, or ACLs.
Existing `securityd` entitlement checks still apply before the backend is
called. This feature is a storage backend only, not a policy equivalence layer.

## Updating Source

When updating the source code, make sure to refer to the [`Updating Sources`](https://docs.darlinghq.org/contributing/updating-sources/index.html#updating-sources) section from the Darling Docs website. Additional details (if any) can be found in [`darling/notes/UPDATE_SOURCE.md`](darling/notes/UPDATE_SOURCE.md).