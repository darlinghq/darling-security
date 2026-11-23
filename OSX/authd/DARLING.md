# authd in Darling

authd is the Authorization Services daemon. Security.framework's Authorization
API (`AuthorizationCreate`, `AuthorizationCopyRights`, `AuthorizationRightGet`,
`SFAuthorization`, ...) sends its requests to the `com.apple.authd` Mach
service over XPC, and authd decides the rights from the rules in its database.
Darling builds authd from the sources here and runs it as a launchd daemon;
nothing in the client library is changed.

## How it runs

- `authd.xpc` is installed under `Security.framework/Versions/A/XPCServices`,
  as on macOS; its Info.plist gives `xpc_main` the service name.
- `com.apple.authd.plist` is a LaunchDaemon that starts it on demand when the
  Mach service is looked up.
- The rights database `/var/db/auth.db` is created on first start and filled
  from `/System/Library/Security/authorization.plist` (the rules macOS ships,
  unchanged). It is refreshed from the plist whenever the plist changes.
- Not built: `PreloginUserDb.m`, the FileVault pre-login user database, needs
  APFS preboot volumes. `darling_prelogin.c` stands in for it and reports that
  the database cannot be read.

## Policy

Darling has no SecurityAgent (no authentication dialog) and a prefix has no
account passwords to check, so a right that macOS grants after the user
authenticates cannot be decided by asking. Rules are evaluated exactly as on
macOS up to the point where authd would start the authentication UI. There:

- the user who created the authorization counts as authenticated (the user
  already owns the prefix), and the right is granted if that user satisfies the
  rule on their own account: uid 0, session owner when the rule asks for it, or
  member of the rule's group (for example `admin`);
- otherwise the right is denied (`errAuthorizationDenied`).

Before that point nothing differs from macOS: a right that needs authentication
is still refused without `kAuthorizationFlagExtendRights`
(`errAuthorizationDenied`) and without `kAuthorizationFlagInteractionAllowed`
(`errAuthorizationInteractionNotAllowed`), so programs that first probe without
interaction see what they see on macOS. The checks for a graphical session and
for dark wake are not made, because no window is shown.

| Right (rule) | macOS | Darling |
|---|---|---|
| `system.burn`, `system.hdd.smart`, `system.privilege.taskport.safe`, `config.add.*` (allow) | granted | granted |
| `config.config.*`, `config.remove.system.*` (deny) | denied | denied |
| a right not in the database (decided by the `default` rule, group admin) | denied; `errAuthorizationInteractionNotAllowed` with ExtendRights | same; with ExtendRights and InteractionAllowed granted like any user-class right |
| `system.preferences`, `system.privilege.admin` and other user-class rights (group admin), no ExtendRights | denied | denied |
| the same with ExtendRights, no InteractionAllowed | `errAuthorizationInteractionNotAllowed` | same |
| the same with ExtendRights and InteractionAllowed | authentication dialog; granted after a correct admin password | granted without a dialog if the creator is root or in group admin; denied otherwise |
| `config.modify.*` and other rules that delegate (`is-root`, `authenticate-admin`, ...) | per rule, the user-class step as in the previous rows | same |
| rights that run mechanisms (`system.login.console`, `system.login.fus`, ...) | run by SecurityAgent/authorizationhost | not run: no agent exists, `errAuthorizationInternal` |
| rights of rules that need the session owner (about a dozen, for example `com.apple.security.sudo`) | session owner = user logged in to the audit session | no audit session owner is known (see below), such rights are denied |
| AuthorizationRightGet / RightSet / RightRemove | database access under `config.*` rights | same, the `config.modify.*` check follows the rows above |

Where Darling grants what macOS would prompt for: only the rows "with
ExtendRights and InteractionAllowed" above (class `user` rights, directly, through a
delegating rule or through the `default` rule, for a creator who is root or in
the rule's group). The credential that results is the creator's own, kept for
the rule's timeout and sharing as on macOS.

The prefix owner is a member of the group `admin` (gid 80): the launcher adds
the group, with root and the owner as members, to a prefix's `/etc/group` if it
has none, as the first account of a Mac is an administrator. The account files
of a prefix have `*` as the password of the user; authd's check that skips a
locked account (a `*` password for a uid of 500 or more) is not applied, since
there are no passwords to lock.

## Audit sessions

authd identifies the client's audit session and its owner (`auditon`
`A_GETSINFO_ADDR`). Darling implements that call for the caller's own session
only, so the owner of the session is the audit user of the default session,
which is "none" (the audit user id -1). If a session cannot be looked up, authd
treats its owner as "none" and not as root.
