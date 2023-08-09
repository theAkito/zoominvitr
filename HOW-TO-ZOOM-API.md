# Getting Zoom API Access

This document explains how to get access to Zoom's developer API, which you need to use this project's product successfully.

Getting access to Zoom's developer API is free of monetary cost.

This project's software requires only read-only permissions for your Zoom account.

## Step by Step
1. Log into your Zoom account.
2. Visit https://marketplace.zoom.us/develop/create
3. Choose "Server-to-Server OAuth 2.0" & click "Create App".
4. Provide a name. For example, "Zoominvitr".
5. **Securely** store Account ID, Client ID & Client Secret. This is just as important as the password to this Zoom account!
6. Press continue, to get to the "Information" tab.
7. Fill the information, as you please. Fields shall not remain empty. You most likely want to fill in some junk information, since your app is not intended for public use.
8. Press continue, to get to the "Feature" tab.
9. **Securely** store Secret Token. (Ignore Verification Token.)
10. Press continue, to get to the "Scopes" tab.
11. Press "+ Add Scopes".
12. Choose the "Meeting" tab.
13. Scroll to "View all user meetings - `meeting:read:admin`" & check its checkbox.
14. Press continue, to get to the "Activation" tab.
15. Press "Activate your app".
16. On the top, it should show the following message.
    > Congratulations! Your app is now activated on the account

### Get User ID

1. Log into your Zoom account.
2. Visit https://zoom.us/account/user#/
3. Select the Master user, which is the original owner of the account, by clicking on the E-Mail address or Name ID on the left.
4. Copy the URL in the address bar. It should look like this. https://zoom.us/user/abcabcfpaourour/profile
5. Extract the User ID from the URL. From the above example, you would get `abcabcfpaourour`.
6. Store this User ID.

## Resources
* https://developers.zoom.us/docs/api/rest/using-zoom-apis/
* https://developers.zoom.us/docs/integrations/oauth/
* https://developers.zoom.us/docs/internal-apps/s2s-oauth/
* https://marketplace.zoom.us/
* https://marketplace.zoom.us/develop/create

## Troubleshooting

If you somehow cannot manage to set up access to Zoom's API, then please contact Zoom support to solve your issue.

https://support.zoom.us/hc/en-us