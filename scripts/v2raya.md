# desktop v2rayA forwarding draft (pending review)

## Current requested scope

HTTP/SOCKS forwarding only; no transparent proxy, TUN, DNS interception or
routing changes. Keep v2rayN installed. Do not activate repository changes
until explicitly approved.

- `packages/v2raya.nix`: official v2rayA 2.5.16 and same-version core, fixed
  SHA-256. The locked nixpkgs default 2.2.7.5 does not support the required
  AnyTLS/newer SQLite state.
- `hosts/desktop/configuration.nix`: UI `127.0.0.1:2017`, explicit rule HTTP
  proxy `127.0.0.1:20172`, root service free of self-referencing proxy env.
- `scripts/v2raya-setup.py`: default read-only preview. `--apply` requires root
  and a stopped service, backs up SQLite privately, disables transparent proxy
  and DNS interception, restricts proxy listeners to loopback, and leaves the
  core stopped for review. Nodes, accounts, subscriptions, selection, existing
  bypasses and unrelated settings are preserved.

Default proxy ports: SOCKS 20170, HTTP 20171, whitelist-rule HTTP 20172.
Do not point clients at these until the core actually listens and connectivity
is verified. Existing GUI clients can retain an old 10808 proxy setting.

## Diagnostics (2026-11-25)

During the latest investigation the running system already contained the new
package and v2rayA management service, but its core was stopped: only 2017
listened, not 20170/20171/20172. The system-wide explicit proxy configuration
pointed at 20172, so clients inheriting that setting had no working listener.
v2rayN on 10808 returned HTTPS 204 for gstatic; a GitHub request timed out,
so general external connectivity is not fully validated.

Isolated core tests used temporary loopback-only HTTP port 20871. No transparent
inbound, system activation, live database changes or node changes were made:

1. v2rayA's selected AnyTLS node and v2rayN's node had the same hostname,
   password and SNI, but different ports. They were not identical selections.
2. The system resolver returned an IP different from v2rayN's established node
   connection. TCP to the system-resolved endpoint timed out. An authenticated
   HTTPS DNS query to AliDNS returned the active peer IP instead.
3. Using that reachable IP, both selected and v2rayN ports accepted TCP, but
   v2raya_core rejected TLS: `x509: certificate is not valid for any names`.
   Independent standard TLS verification also reported a self-signed certificate.
4. v2rayN enables insecure TLS and Chrome uTLS. v2rayA 2.5.16's AnyTLS importer
   does NOT translate `insecure=1`, `allowInsecure=1` or `fp=chrome`. Its native
   core uses normal TLS verification; a trusted certificate-chain pin is the
   supported exception for a self-signed endpoint. Merely importing the same
   subscription does not reproduce v2rayN's TLS behavior.

A complete fix requires correct node DNS and a verifiable node certificate,
OR a certificate-chain hash obtained from the provider over a trusted channel.
Do not silently trust a fingerprint captured from the unauthenticated failing
connection, disable certificate verification, change SNI speculatively, or
modify the subscription. A local forward through v2rayN is possible but is not
an independent replacement for v2rayN.

Private diagnostic configs/logs: `/var/lib/v2raya-debug` (0700). They contain
node credentials and must never be copied to Git, chat, or the Nix store.
All temporary diagnostic core services were stopped after the tests.

## Earlier migration history

An earlier transparent-proxy deployment began under explicit authorization.
After the instruction changed to review-only, it was rolled back to the prior
system profile, its database and generated config restored, and v2rayN's
explicit 10808 proxy recovered. Original TUN recovery was not confirmed.
No migration rollback timer remains. Private pre-migration backup:
`/var/backups/v2raya-migration/before-switch`. Runtime was subsequently changed
outside that rollback, so do not assume this backup is the latest state or run
its rollback script without reviewing paths and current services.

## Non-activating review checks

```sh
nix eval --no-update-lock-file path:.#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
nix build --no-update-lock-file --no-link path:.#nixosConfigurations.desktop.config.system.build.toplevel
sudo python3 scripts/v2raya-setup.py
```

Only after approval: take fresh backups; stop v2rayA before `--apply`; deploy;
review/create the local administrator account; fix DNS/certificate validation;
review node selection; start the core in the UI and test HTTP/SOCKS. Keep
transparent proxy disabled. Track new files before using a Git-based flake;
`path:.` also includes untracked files without staging them.

The package's ignored `v2ray` argument is for compatibility with the NixOS
module override. The server uses its same-version bundled core instead.
