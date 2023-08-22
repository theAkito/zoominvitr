# Frequently Asked Questions

## How about implementing support for [Jitsi](https://jitsi.org/)?

Jitsi currently [does not support scheduling meetings](https://community.jitsi.org/t/schedule-a-meeting/73276/2?u=akito) without a heavily customised setup.

## How about implementing support for [BigBlueButton](http://bigbluebutton.org/)?

BigBlueButton currently [does not support scheduling meetings](https://github.com/bigbluebutton/greenlight/issues/1009#issuecomment-844480795)

## Why is this project licenced under [AGPL-3.0](https://choosealicense.com/licenses/agpl-3.0/)?

It is licensed under this licence, because Zoom is a proprietary product with lots of users for no other reason, than, for example, Microsoft Windows became so popular.
Needless to say, such products are made by companies which don't give a damn about you & just want to suck every single last penny out of your pockets.

I do not want to help grow such businesses in any way beyond what I need to do for business I shall not avoid.

The reason I created this project is the grade of necessity. I would prefer to not use a product from a company like the one standing behind Zoom, at all.

## Why not release it with Nim 2.0.0?

Nim 2.0.0 currently has a bug.

```
/root/.nimble/pkgs2/ready-0.1.4-876e2ab213a5ef4a48f054a37cd420d1a1d2fa6c/ready/connections.nim(55, 15) template/generic instantiation of `join` from here
38.77 /nim/lib/pure/strutils.nim(1855, 6) Error: 'join' can have side effects
38.77 > /nim/lib/pure/strutils.nim(1865, 17) Hint: 'join' calls `.sideEffect` '$'
38.77 >> /root/.nimble/pkgs2/ready-0.1.4-876e2ab213a5ef4a48f054a37cd420d1a1d2fa6c/ready/connections.nim(46, 6) Hint: '$' called by 'join'
```

Fixed in the newest nightly version, so we are just waiting for it to be officially released & made public through a corresponding Docker image.