#include <Carbon/Carbon.h>

OSErr getStringValue(const AppleEvent *ev, AEKeyword theKey, CFStringRef *outStr);
void showAEDesc(const AppleEvent *ev);
void safeRelease(CFTypeRef theObj);
OSErr putBoolToReply(Boolean aBool, AppleEvent *reply);