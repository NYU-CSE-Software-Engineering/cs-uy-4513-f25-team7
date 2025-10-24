Feature: Role Assignment (Moderation Controls)
User Story
                As a moderator, I want to assign or remove the “moderator” role from other members,
                so that I can control who has access to moderation tools.
Acceptance Criteria
AC1 — Promote a User to Moderator
                Given I’m signed in as a moderator
                When I promote an existing member to “Moderator”
                Then that member gains access to moderation tools.
AC2 — Demote a Moderator to User
                Given I’m a moderator
                When I demote a moderator back to “User”
                Then their moderation tools disappear.
AC3 — Authorization Restrictions
                Regular users cannot see the Role Management page nor perform role changes.
                Attempting to visit the URL shows a “Not authorized” message.
AC4 — Safety Rule: At Least One Moderator
                The last remaining moderator cannot demote themselves if it would leave
                The platform with zero moderators; a clear error explains why.
MVC Component Outline
Models
User
                Attributes:
                • email: string
                • password_digest: string
                • role: enum {user, moderator} (default: user)
                Validations:
                • role inclusion in allowed values
                • Custom validation prevents removal of final moderator
Views
Users (Role Management Page)
                users/index.html.erb — Lists all users with their roles
                Buttons: “Promote” / “Demote” depending on current role
                Flash messages confirm success or show errors
Controllers
UsersController
                index — Displays all users and their roles
                update — Handles promotion/demotion requests with authorization checks
                Guards against demoting the final moderator