#import "SmartActivate.h"

#define useLog 0

NSDictionary *getProcessInfo(NSString *targetCreator, NSString *targetName) {
	/* find an applicarion process specified by theSignature(creator type) from runnning process.
	if target application can be found, get information of the process and return as a result
	*/
	OSErr err;
	ProcessSerialNumber psn = {kNoProcess, kNoProcess};
	NSDictionary *pDict;
	NSString *dictValue;
	NSString *targetValue;
	id dictKey;
	BOOL isFound = NO;
	
	if (targetCreator == nil) {
		dictKey = @"CFBundleName";
		targetValue = targetName;
	}
	else {
		dictKey = @"FileCreator";
		targetValue = targetCreator;
	}
		
	err = GetNextProcess(&psn);
	while( err == noErr) {
		pDict = (NSDictionary *)ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask);
		dictValue = [pDict objectForKey:dictKey];
#if useLog
		NSLog([pDict description]);
#endif
		if (dictValue != nil) {
			if ([dictValue isEqualToString:targetValue]){
				if ([dictKey isEqualToString:@"FileCreator"] && (targetName != nil)) {
					if ([[pDict objectForKey:@"CFBundleName"] isEqualToString:targetName]) {
						isFound = YES;
						break;
					}
				}
				else {
					isFound = YES;
					break;
				}
			}
		}
		
		[pDict release];
		err = GetNextProcess (&psn);
	}
	
	if (isFound) {
		return pDict;
	}
	else{
		return nil;
	}
}

@implementation SmartActivate

+(BOOL)activateAppOfName:(NSString *)targetName
{
	return [self activateAppOfType:nil processName:targetName];
}

+(BOOL)activateAppOfType:(NSString *)targetCreator
{
	return [self activateAppOfType:targetCreator processName:nil];
}

+(BOOL)activateAppOfType:(NSString *)targetCreator processName:(NSString*)targetName {
	
	NSDictionary *pDict = getProcessInfo(targetCreator,targetName);
	if (pDict != nil) {
#if useLog
		NSLog(@"will activate");
		NSLog([pDict description]);
#endif
		ProcessSerialNumber psn;
		[[pDict objectForKey:@"PSN"] getValue:&psn];
		SetFrontProcessWithOptions(&psn,kSetFrontProcessFrontWindowOnly);
		[pDict release];
		return YES;
	}
	else {
		return NO;
	}
}

@end
