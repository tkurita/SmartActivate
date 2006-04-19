#import "SmartActivate.h"

#define useLog 0

@implementation SmartActivate

+(BOOL)activateAppOfName:(NSString *)targetName
{
	return [self activateAppOfType:nil processName:targetName identifier:nil];
}

+(BOOL)activateAppOfType:(NSString *)targetCreator
{
	return [self activateAppOfType:targetCreator processName:nil identifier:nil];
}

+(BOOL)activateAppOfType:(NSString *)targetCreator processName:(NSString*)targetName identifier:(NSString*)targetIdentifier {
#if useLog	
	NSLog(@"start activateAppOfType");
#endif

	CFDictionaryRef pDict = getProcessInfo((CFStringRef)targetCreator,
											(CFStringRef)targetName,
											(CFStringRef)targetIdentifier);
	if (pDict != nil) {
		OSStatus result = activateForProcessInfo(pDict);
		CFRelease(pDict);
		
		return result==noErr;
	}
	else {
		return NO;
	}
}

@end
