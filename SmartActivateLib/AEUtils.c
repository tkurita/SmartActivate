#include "AEUtils.h"

#define useLog 0

#pragma mark for debug
void showAEDesc(const AppleEvent *ev)
{
	Handle result;
	OSStatus resultStatus;
	resultStatus = AEPrintDescToHandle(ev,&result);
	printf("%s\n",*result);
	DisposeHandle(result);
}

void safeRelease(CFTypeRef theObj)
{
	if (theObj != NULL) {
		CFRelease(theObj);
	}
}

OSErr getStringValue(const AppleEvent *ev, AEKeyword theKey, CFStringRef *outStr)
{
#if useLog
	printf("start getStringValue\n");
#endif
	OSErr err;
	DescType typeCode;
	DescType returnedType;
    Size actualSize;
	Size dataSize;
	CFStringEncoding encodeKey;
	
	err = AESizeOfParam(ev, theKey, &typeCode, &dataSize);
	if (dataSize == 0) {
		*outStr = CFSTR("");
		goto bail;
	}
	
	switch (typeCode) {
		case typeChar:
			encodeKey = CFStringGetSystemEncoding();
			break;
		case typeUTF8Text:
			encodeKey = kCFStringEncodingUTF8;
			break;
		default :
			typeCode = typeUnicodeText;
			encodeKey = kCFStringEncodingUnicode;
	}
	
	UInt8 *dataPtr = malloc(dataSize);
	err = AEGetParamPtr (ev, theKey, typeCode, &returnedType, dataPtr, dataSize, &actualSize);
	if (actualSize > dataSize) {
#if useLog
		printf("buffere size is allocated. data:%i actual:%i\n", dataSize, actualSize);
#endif	
		dataSize = actualSize;
		dataPtr = (UInt8 *)realloc(dataPtr, dataSize);
		if (dataPtr == NULL) {
			printf("fail to reallocate memory\n");
			goto bail;
		}
		err = AEGetParamPtr (ev, theKey, typeCode, &returnedType, dataPtr, dataSize, &actualSize);
	}
	
	if (err != noErr) {
		free(dataPtr);
		goto bail;
	}
	
	*outStr = CFStringCreateWithBytes(NULL, dataPtr, dataSize, encodeKey, false);
	free(dataPtr);
bail:
#if useLog		
	printf("end getStringValue\n");
#endif
	return err;
}

OSErr putStringToReply(CFStringRef inStr, CFStringEncoding kEncoding, AppleEvent *reply)
{
#if useLog
	printf("start putStringToReply\n");
#endif
	OSErr err;
	DescType resultType;
	
	switch (kEncoding) {
		case kCFStringEncodingUTF8 :
			resultType = typeUTF8Text;
			break;
		default :
			resultType = typeUnicodeText;
	}
	
	const char *constBuff = CFStringGetCStringPtr(inStr, kEncoding);
	
	AEDesc resultDesc;
	if (constBuff == NULL) {
		char *buffer;
		CFIndex charLen = CFStringGetLength(inStr);
		CFIndex maxLen = CFStringGetMaximumSizeForEncoding(charLen, kEncoding);
		buffer = malloc(maxLen+1);
		CFStringGetCString(inStr, buffer, maxLen+1, kEncoding);
		err=AECreateDesc(resultType, buffer, strlen(buffer), &resultDesc);
		free(buffer);
	}
	else {
		err=AECreateDesc(resultType, constBuff, strlen(constBuff), &resultDesc);
	}
	
	
	if (err != noErr) goto bail;
	
	err=AEPutParamDesc(reply, keyAEResult, &resultDesc);
	if (err != noErr) {
		AEDisposeDesc(&resultDesc);
	}
	
bail:
#if useLog
	printf("end putStringToReply\n");
#endif
	return err;
}

OSErr putBoolToReply(Boolean aBool, AppleEvent *reply)
{
#if useLog
	printf("start putBoolToReply\n");
#endif
	OSErr err;
	DescType resultType = (aBool? typeTrue:typeFalse);
	AEDesc resultDesc;
	err=AECreateDesc(resultType, NULL, 0, &resultDesc);
	err=AEPutParamDesc(reply, keyAEResult, &resultDesc);
	
#if useLog
	printf("end putBoolToReply\n");
#endif
	return err;
}