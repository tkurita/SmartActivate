#import "SmartActivate.h"

#define useLog 0

@implementation SmartActivate

+(BOOL)activateAppOfInfo:(NSDictionary *)pDict
{
	if (pDict != nil) {
		OSStatus result = activateForProcessInfo((CFDictionaryRef)pDict);
		return result==noErr;
	}
	else {
		return NO;
	}
}

+(NSDictionary *)processInfoOfIdentifier:(NSString*)targetIdentifier
{
	NSDictionary *pDict = (NSDictionary *)getProcessInfo(NULL,NULL,
														 (CFStringRef)targetIdentifier);
	return [pDict autorelease];
}


+(NSDictionary *)processInfoOfName:(NSString*)targetName
{
	NSDictionary *pDict = (NSDictionary *)getProcessInfo(NULL,
														 (CFStringRef)targetName,
														 NULL);
	return [pDict autorelease];
}

+(NSDictionary *)processInfoOfType:(NSString *)targetCreator 
{
	NSDictionary *pDict = (NSDictionary *)getProcessInfo((CFStringRef)targetCreator,
														 NULL,NULL);
	return [pDict autorelease];
}

+(NSDictionary *)processInfoOfType:(NSString *)targetCreator processName:(NSString*)targetName identifier:(NSString*)targetIdentifier
{
	NSDictionary *pDict = (NSDictionary *)getProcessInfo((CFStringRef)targetCreator,
										   (CFStringRef)targetName,
										   (CFStringRef)targetIdentifier);
	return [pDict autorelease];
}

+(BOOL)activateAppOfIdentifier:(NSString *)targetIdentifier
{
	return [self activateAppOfType:nil processName:nil identifier:targetIdentifier];
}

+(BOOL)activateAppOfName:(NSString *)targetName
{
	return [self activateAppOfType:nil processName:targetName identifier:nil];
}

+(BOOL)activateAppOfType:(NSString *)targetCreator
{
	return [self activateAppOfType:targetCreator processName:nil identifier:nil];
}

+(BOOL)activateAppOfType:(NSString *)targetCreator processName:(NSString*)targetName identifier:(NSString*)targetIdentifier
{
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

+(BOOL)activateSelf
{
	OSStatus result = activateSelf();
	return result == noErr;
}

@end
