#import "SmartActivate.h"

#define useLog 0

//NSDictionary *getProcessInfo(NSString *targetCreator, NSString *targetName, NSString *targetIdentifier) {
NSDictionary *getProcessInfo(id targetCreator, id targetName, id targetIdentifier) {
	/* find an applicarion process specified by theSignature(creator type) from runnning process.
	if target application can be found, get information of the process and return as a result
	*/
#if useLog
	NSLog(@"start getProcessInfo");
#endif
	NSMutableArray *keyList = [NSMutableArray arrayWithObjects:@"FileCreator",@"CFBundleIdentifier",@"CFBundleName",nil];

	unsigned int firstKeyIndex;
	
	if (targetCreator != nil) {
		firstKeyIndex = 0;
	}
	else if (targetIdentifier != nil) {
		firstKeyIndex = 1;
	}
	else {
		firstKeyIndex = 2;
	}
	
	if (targetCreator == nil) targetCreator = [NSNull null];
	if (targetName == nil) targetName = [NSNull null];
	if (targetIdentifier == nil) targetIdentifier = [NSNull null];
	NSMutableArray *valueList = [NSMutableArray arrayWithObjects:targetCreator,targetIdentifier,targetName,nil];
	
	NSString *dictKey = [keyList objectAtIndex:firstKeyIndex];
	[keyList removeObjectAtIndex:firstKeyIndex];
	NSString *targetValue = [valueList objectAtIndex:firstKeyIndex];
	[valueList removeObjectAtIndex:firstKeyIndex];
	
	BOOL isFound = NO;
	ProcessSerialNumber psn = {kNoProcess, kNoProcess};
	NSDictionary *pDict;

	OSErr err = GetNextProcess(&psn);
	while( err == noErr) {
		pDict = (NSDictionary *)ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask);
		NSString *dictValue = [pDict objectForKey:dictKey];
#if useLog
		NSLog([pDict description]);
		NSLog(dictKey);
		NSLog(dictValue);
		NSLog(targetValue);
#endif
		if (dictValue != nil) {
			if ([dictValue isEqualToString:targetValue]){
				isFound = YES;
				for (int i=0; i < 2; i++) {
					NSString *secondValue = [valueList objectAtIndex:i];
					if ([secondValue isNotEqualTo: [NSNull null]]) {
						dictValue = [pDict objectForKey:[keyList objectAtIndex:i]];
						if (![dictValue isEqualToString:secondValue]) {
							isFound = NO;
							break;
						}
					}
				}
				
				if (isFound) break;
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

	NSDictionary *pDict = getProcessInfo(targetCreator,targetName,targetIdentifier);
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
