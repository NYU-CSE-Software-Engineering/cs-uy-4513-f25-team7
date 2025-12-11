# Identity & 2FA/OAuth — BDD Design

## User Stories

1. **Base authentication** — *As a* PokéForum visitor, *I want to* register and sign in with email and password, *so that I can* access my account and participate in the forum.
2. **Two-factor authentication (TOTP)** — *As a* security-conscious member, *I want to* enable two-factor authentication for my account, *so that I can* protect my account even if my password is compromised.
3. **Google SSO** — *As a* member who prefers using Google, *I want to* sign in with my Google account, *so that I can* log in quickly without typing a password.
4. **Password reset** — *As a* member who forgot my password, *I want to* reset it via a secure email link, *so that I can* regain access to my account.
5. **2FA recovery codes** — *As a* member with 2FA enabled, *I want to* get one-time backup codes, *so that I can* log in if I lose access to my authenticator app.
6. **Admin role management** — *As an* admin, *I want to* promote, demote, or deactivate users, *so that I can* manage moderation and community safety.
7. **OAuth token lifecycle** — *As a* member using Google SSO, *I want to* have my OAuth tokens stored, refreshed, and revocable securely, *so that I can* keep my account linked without exposing credentials.

## Acceptance Criteria

### A. Base Authentication

- **Register (happy):** Given I’m on the sign-up page, when I submit a unique email and strong password, then a member account is created and I see a welcome message on my profile/dashboard.
- **Duplicate email (sad):** Given an account exists for that email, when I sign up with the same email, then I see “Email has already been taken” and no account is created.
- **Login (happy):** Given a valid account without 2FA, when I log in with correct email/password, then I land on my profile/dashboard and see a logout link.
- **Invalid credentials (sad):** When I log in with a bad email or password, then I see “Invalid email or password” and I am not logged in.

### B. Two-Factor Authentication (TOTP)

- **Enable 2FA (happy):** Given I’m logged in, when I start 2FA setup, then the app generates a TOTP secret and shows a QR; when I enter a valid 6-digit code, then 2FA is enabled and I see a success notice.
- **Wrong code (sad):** Given I’m enabling 2FA, when I enter an invalid code, then 2FA is not enabled and I see “Invalid authentication code”.
- **Login with 2FA (happy):** Given my account has 2FA enabled, when I log in with correct email/password and then enter a valid TOTP code, then I’m logged in successfully.
- **Missing/invalid 2FA at login (sad):** Given 2FA is enabled, when I fail to provide a valid code, then login is denied with an error.
- **Regenerate 2FA (recovery):** Given I have 2FA enabled, when I regenerate my 2FA secret from settings, then the old secret is replaced and I must scan a new QR and confirm a code to re-enable 2FA.

### C. Google SSO

- **First-time Google login (happy):** When I approve Google sign-in, then a forum account is created (or linked) for my verified Google email and I am logged in with a success notice.
- **Google denial/failure (sad):** When I deny consent or the provider errors, then I see “Google sign-in failed or was canceled” and remain unauthenticated.

### D. Password Reset

- **Request reset (happy):** Given I’m on “Forgot Password?”, when I submit a registered email, then a time-limited, single-use reset link is emailed and I see a generic success message.
- **Reset with valid token (happy):** Given I opened a valid reset link, when I submit a new strong password and confirmation, then my password is updated and I’m prompted to log in.
- **Invalid/expired token (sad):** When I open an invalid or expired link, then I see “Invalid or expired reset link” and cannot change the password.

### E. 2FA Recovery Codes

- **Issue codes (happy):** After enabling 2FA, when I finish setup, then I see exactly 10 one-time recovery codes and a warning to save them; the system stores only hashed codes.
- **Login with backup code (happy):** Given I’m at the 2FA prompt, when I enter a valid unused backup code, then I’m logged in and that code is invalidated.
- **Reuse blocked (sad):** Given a backup code was used, when I try it again, then I see “Invalid authentication code” and I’m not logged in.
- **Regenerate codes (happy):** Given I’m logged in with 2FA, when I regenerate recovery codes, then I see a new set and all old codes are invalid.

### F. Admin Role Management

- **Promote/demote (happy):** Given I’m an admin on the user management page, when I promote a member to moderator or demote a moderator to member, then the role updates immediately and the UI reflects the change.
- **Deactivate/reactivate (happy):** Given I’m an admin, when I deactivate a user, then the user cannot log in; when I reactivate, login is allowed again.
- **Access control (sad):** Given I’m not an admin, when I try to access admin user management, then I’m denied with a “Not authorized” error.

### G. OAuth Token Lifecycle

- **Secure storage:** After Google login, the access/refresh tokens and expiry are stored server-side, encrypted; secrets are never exposed to clients.
- **Refresh:** When an access token expires and a refresh token exists, the system can refresh it server-side without user interruption.
- **Disconnect/Revoke:** When I disconnect Google, the app revokes tokens at the provider and deletes stored credentials; subsequent Google sign-in requires re-consent/linking.

## MVC Design Outline

### Models

- **User**
  - **Auth:** `email:string{uniq}`, `password_digest:string` (bcrypt/argon2), `active:boolean` (default true), timestamps.
  - **Roles:** `role:string` enum (`member`, `moderator`, `admin`).
  - **2FA:** `two_factor_enabled:boolean`, `otp_secret:text` (encrypted), `backup_code_digests:json` (array of bcrypt hashes).
  - **Password reset:** `reset_digest:string`, `reset_sent_at:datetime`.
  - **OAuth (Google):** `google_uid:string`, `google_token:text` (encrypted), `google_refresh_token:text` (encrypted), `google_token_expires_at:datetime`.
  - **Methods:** `authenticate_password`, `enable_2fa!(secret)`, `valid_totp?(code)`, `issue_backup_codes!`, `use_backup_code!(code)`, `generate_reset_token!`, `reset_password!(token, new_pw)`, `admin?`, etc.
- **(Optional) Role** — if not using enum; seed roles and map permissions.

### Views

- **Auth:** `registrations/new`, `sessions/new` (+ “Forgot password?”, “Sign in with Google”).
- **2FA:** `two_factor/setup` (QR + code form), `two_factor/verify` (login prompt), `two_factor/recovery_codes` (display after enable/regenerate).
- **Password reset:** `password_resets/new` (request), `password_resets/edit` (set new password).
- **Admin:** `admin/users/index` (list + actions: promote/demote/deactivate/reactivate).
- **Profile/Dashboard:** `users/show` or `home/index` (post-login).

### Controllers

- **RegistrationsController:** `new`, `create` (sign-up).
- **SessionsController:** `new`, `create` (password check → if 2FA enabled, redirect to verify), `destroy`.
- **TwoFactorController:** `setup` (generate secret & QR), `enable` (verify TOTP → enable + issue recovery codes), `verify` (login-time code or backup code).
- **PasswordResetsController:** `new`, `create` (email token), `edit` (token gate), `update` (change password, invalidate token).
- **Admin::UsersController:** `index`, `update` (role changes), custom actions `deactivate`/`reactivate`.
- **OmniauthCallbacksController (or Sessions callback):** `google_oauth2` (link/create user; store tokens securely; sign in), `disconnect` (revoke & remove tokens).

## Security & Data Protection Considerations

- **Passwords:** Hash with bcrypt (or argon2). Enforce length ≥ 12; consider breached-password checks. Use an app-wide pepper via credentials.
- **2FA secrets:** Store encrypted; never log or re-display. Verify with server-side TOTP (allow small clock drift). Recovery codes are randomly generated, **stored only as hashes**, and one-time use.
- **Password reset:** Use high-entropy, single-use tokens; store only digest + timestamp; expire (e.g., 1h). Do not reveal whether an email exists in responses.
- **SQL injection:** Use ActiveRecord parameterization; never interpolate untrusted input. Add DB constraints and validations.
- **Sessions & cookies:** HttpOnly, Secure, SameSite Lax/Strict; rotate session ID at login; short JWT/session TTL; lock account after N failed attempts; optional email confirmation.
- **Google OAuth:** Keep client secrets in env/credentials. Store tokens encrypted; refresh automatically when needed; provide user-initiated disconnect that revokes at provider and deletes stored tokens.
- **RBAC:** Gate admin routes/actions with server-side checks; hide admin UI from non-admins.

## Developer Setup Notes

- **Google OAuth credentials (safe sharing):**
  - Add to Rails credentials (`rails credentials:edit`) under:
    ```yaml
    google_oauth:
      client_id: "YOUR_CLIENT_ID"
      client_secret: "YOUR_CLIENT_SECRET"
    ```
  - Commit the encrypted `config/credentials.yml.enc` but **never** commit the `master.key`. Share the master key privately (e.g., 1Password/secret manager) so teammates can decrypt without seeing plaintext secrets.
  - Alternative: set `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` env vars locally; each teammate can use their own Google OAuth client if preferred.
  - Required redirect URI for dev: `http://localhost:3000/auth/google_oauth2/callback` (add production URI as needed).

- **2FA QR enrollment UI:**
  - The enrollment page (`/two_factor/new`) renders a real QR code from the provisioning URI using `rqrcode`. The manual `otpauth://` URI remains visible as a fallback.

## Deliverables (for this assignment)

- **Design doc (this file).**
- **Feature file:** `features/identity_2fa_oauth.feature` — scenarios covering all acceptance criteria above.
- **Step definitions:** `features/step_definitions/identity_steps.rb` — Capybara steps including OmniAuth mocks and TOTP helpers.
- **Support helper:** `features/support/test_two_factor_helper.rb` — generate/verify TOTP and backup codes in tests.
- **Screenshot(s):** `features/screenshots/identity_2fa_oauth_*.jpg` (initial RED run) and, if extended, `_2.jpg` for added features.
