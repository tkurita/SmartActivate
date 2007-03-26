#include "SmartActivate.h"

#define useLog 0

CFDictionaryRef getProcessInfo(CFStringRef targetCreator, CFStringRef targetName, CFStringRef targetIdentifier) {
	/* find an applicarion process specified by theSignature(creator type) from runnning process.
	if target application can be found, get information of the process and return as a result
	*/
	CFIndex nKey = 3;
	CFMutableArrayRef keyList = CFArrayCreateMutable(NULL,nKey,&kCFTypeArrayCallBacks);
	CFArrayAppendValue(keyList, CFSTR("FileCreator"));
	CFArrayAppendValue(keyList, CFSTR("CFBundleIdentifier"));
	CFArrayAppendValue(keyList, CFSTR("CFBundleName"));

	CFIndex firstKeyIndex;
	
	if (targetCreator != NULL) {
		firstKeyIndex = 0;
	}
	else if (targetIdentifier != NULL) {
		firstKeyIndex = 1;
	}
	else {
		firstKeyIndex = 2;
	}
	if (targetCreator == NULL) targetCreator = (CFStringRef)kCFNull;
	if (targetName == NULL) {
		targetName = (CFStringRef)kCFNull;
	} else {
		CFMutableStringRef target_name_mut = CFStringCreateMutableCopy(NULL, 0, targetName);
		CFStringNormalize((CFMutableStringRef) target_name_mut,  kCFStringNormalizationFormKC);
		targetName = target_name_mut;
	}
	
	if (targetIdentifier == NULL) targetIdentifier = (CFStringRef)kCFNull;

	CFMutableArrayRef valueList = CFArrayCreateMutable(NULL, nKey,&kCFTypeArrayCallBacks);
	CFArrayAppendValue(valueList, targetCreator);
	CFArrayAppendValue(valueList, targetIdentifier);
	CFArrayAppendValue(valueList, targetName);
	
	CFStringRef dictKey = CFArrayGetValueAtIndex(keyList, firstKeyIndex);
	CFArrayRemoveValueAtIndex(keyList, firstKeyIndex);
	CFStringRef targetValue = CFArrayGetValueAtIndex(valueList, firstKeyIndex);
	CFArrayRemoveValueAtIndex(valueList, firstKeyIndex);
	
	Boolean isFound = false;
	ProcessSerialNumber psn = {kNoProcess, kNoProcess};
	CFDictionaryRef pDict = NULL;
	CFComparisonResult isSameStr;
	
	OSErr err = GetNextProcess(&psn);
	while( err == noErr) {
		pDict = ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask);
		CFStringRef dictValue = CFDictionaryGetValue(pDict, dictKey);
		if (dictValue != NULL) {
			isSameStr = CFStringCompare(dictValue,targetValue,0);
			#if useLog
			CFShow(dictValue);
			CFShow(CFDictionaryGetValue(pDict, CFSTR("CFBundleIdentifier")));
			CFShow(targetValue);
			#endif
			if (isSameStr == kCFCompareEqualTo){
				isFound = true;
				for (CFIndex i=0; i < 2; i++) {
					CFStringRef secondValue = CFArrayGetValueAtIndex(valueList,i);
					if (secondValue != (CFStringRef)kCFNull) {
						CFStringRef nextKey = CFArrayGetValueAtIndex(keyList, i);
						dictValue = CFDictionaryGetValue(pDict,nextKey);
						isSameStr = CFStringCompare(dictValue,secondValue,0);
						if (isSameStr != kCFCompareEqualTo) {
							isFound = false;
							break;
						}
					}
				}
				
				if (isFound) break;
			}
		}
		
		CFRelease(pDict);
		err = GetNextProcess (&psn);
	}
	
	CFRelease(keyList);
	CFRelease(valueList);
	if (targetName != NULL) CFRelease(targetName);
	
	if (isFound) {
		return pDict;
	}
	else{
		return nil;
	}
}

OSStatus activateForProcessInfo(CFDictionaryRef pDict) {
	ProcessSerialNumber psn;
	CFNumberGetValue(CFDictionaryGetValue(pDict,CFSTR("PSN")),kCFNumberLongLongType,&psn);
	return SetFrontProcessWithOptions(&psn,kSetFrontProcessFrontWindowOnly);
}

OSStatus activateSelf() {
	ProcessSerialNumber psn;
	OSErr err = GetCurrentProcess(&psn);
	OSStatus result = err;
	if (err == noErr) {
		result = SetFrontProcessWithOptions(&psn,kSetFrontProcessFrontWindowOnly);
	}

	return result;
}