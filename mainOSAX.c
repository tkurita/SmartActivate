#include "SmartActivate.h"
#include "AEUtils.h"

#include <Carbon/Carbon.h>

#define useLog 0

#define kSmartActivateSuite  'smAt'
#define kActivateProcessEvent	'smAt'
#define kCreatorParam 'cTyp'
#define kBundleIDParam 'buID'

UInt32			gAdditionReferenceCount = 0;
CFBundleRef		gAdditionBundle;

//static Boolean isEventsInstalled;
// =============================================================================
// == Entry points.

static OSErr InstallMyEventHandlers();
static void RemoveMyEventHandlers();
void SATerminate();

OSErr SAInitialize(CFBundleRef theBundle)
{
#if useLog
	printf("start SAInitialize\n");
#endif	
	gAdditionBundle = theBundle;  // no retain needed.
	
	return InstallMyEventHandlers();
}

void SATerminate()
{
	// Release anything you allocated in SAInitialize here...
#if useLog
	printf("start SATerminate\n");
#endif
	RemoveMyEventHandlers();
	/*
	if (isEventsInstalled) {
		RemoveMyEventHandlers();
		isEventsInstalled = 0;
	}*/
}

Boolean SAIsBusy()
{
	//return true;
	return gAdditionReferenceCount != 0;
}

int main(int argc, char *argv[])
{
	InstallMyEventHandlers();
    RunApplicationEventLoop();
	RemoveMyEventHandlers();
}

// =============================================================================

OSErr MyEventHandler(const AppleEvent *ev, AppleEvent *reply, long refcon)
{
#if useLog
	NSLog(@"start MyEventHandler");
#endif	
	++gAdditionReferenceCount;  // increment the reference count first thing!
	
	OSErr resultCode;
	OSErr err;

	CFStringRef targetCreator = NULL;
	CFStringRef targetName = NULL;
	CFStringRef targetIdentifier = NULL;
	
	
	err = getStringValue(ev, kCreatorParam, &targetCreator);
//	if (err != noErr) {
//		targetCreator = NULL;
		//printf("fail to get creator type with error :%d\n",err);
//	}
	
	err = getStringValue(ev, kBundleIDParam, &targetIdentifier);
//	if (err != noErr) {
//		targetIdentifier = NULL;
		//printf("fail to get bundle ID with error :%d\n",err);
//	}
	
	err = getStringValue(ev, keyDirectObject, &targetName);
//	if (err != noErr) {
//		targetName = NULL;
		//printf("fail to get application name with error :%d\n",err);
//	}
	
	Boolean isSuccess = 0;
	CFDictionaryRef pdict = NULL;
	if (targetName || targetCreator || targetIdentifier) {
		pdict = getProcessInfo(targetCreator, targetName, targetIdentifier);
		if (pdict != NULL) {
			err = activateForProcessInfo(pdict);
			if (err == noErr) isSuccess = 1;
		}
		resultCode = noErr;
	}
	else {
		isSuccess = 0;
		resultCode = errAEDescNotFound;
	}

	putBoolToReply(isSuccess, reply);
	--gAdditionReferenceCount;  // don't forget to decrement the reference count when you leave!
	safeRelease(targetCreator);
	safeRelease(targetName);
	safeRelease(targetIdentifier);
	safeRelease(pdict);
	
#if useLog
	printf("end MyEventHandler\n");
#endif
	return resultCode;
}

// -----------------------------------------------------------------------------
// -- Event handler data.

struct AEEventHandlerInfo {
	FourCharCode			evClass, evID;
	AEEventHandlerProcPtr	proc;
};
typedef struct AEEventHandlerInfo AEEventHandlerInfo;

static const AEEventHandlerInfo gEventInfo[] = {
	{ kSmartActivateSuite, kActivateProcessEvent, MyEventHandler }
	// Add more suite/event/handler triplets here if you define more than one command.
};
#define kEventHandlerCount  (sizeof(gEventInfo) / sizeof(AEEventHandlerInfo))

static AEEventHandlerUPP gEventUPPs[kEventHandlerCount];

// =============================================================================

static OSErr InstallMyEventHandlers()
{
	OSErr		err;
	size_t		i;
	
	for (i = 0; i < kEventHandlerCount; ++i) {
		if ((gEventUPPs[i] = NewAEEventHandlerUPP(gEventInfo[i].proc)) != NULL)
			err = AEInstallEventHandler(gEventInfo[i].evClass, gEventInfo[i].evID, gEventUPPs[i], 0, true);
		else
			err = memFullErr;
		
		if (err != noErr) {
			SATerminate();  // Call the termination function ourselves, because the loader won't once we fail.
			return err;
		}
	}
	//isEventsInstalled = true;
	return noErr; 
}

// -----------------------------------------------------------------------------

static void RemoveMyEventHandlers()
{
	OSErr		err;
	size_t		i;
	
	for (i = 0; i < kEventHandlerCount; ++i) {
		if (gEventUPPs[i] &&
			(err = AERemoveEventHandler(gEventInfo[i].evClass, gEventInfo[i].evID, gEventUPPs[i], true)) == noErr)
		{
			DisposeAEEventHandlerUPP(gEventUPPs[i]);
			gEventUPPs[i] = NULL;
		}
	}
}