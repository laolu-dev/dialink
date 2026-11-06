# Security policy

## Supported versions

Only the latest release in the App Store and Google Play gets security
fixes. Builds from `dev` are for testing and aren't supported.

## Reporting a vulnerability

Please don't open a public issue for a security problem.

<!-- TODO(maintainer): choose the reporting channel. Either turn on GitHub
private vulnerability reporting (Settings > Code security) and keep the line
below, or replace it with a security contact address. -->
Report it privately through the repository's **Security** tab, using
**Report a vulnerability**.

Include what you found, the steps to reproduce it, the app version and
platform, and what an attacker could do with it.

## What happens next

- You get an acknowledgement within 5 business days.
- Once the issue is confirmed, the fix ships in a new app build. Store
  builds can't be rolled back, so a fix is always a new version.
- You're credited in the release notes unless you'd rather not be.

## Out of scope

- The Dialink backend lives in a separate repository. Report backend issues
  there.
- Values in the app's environment files, such as the Google OAuth client
  IDs, are public by design. Anything inside the app binary is.
