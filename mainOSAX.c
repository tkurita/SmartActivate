#include "SmartActivate.h"
#include "AEUtils.h"

#include <Carbon/Carbon.h>
#include <ApplicationServices/ApplicationServices.h>

#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_5
typedef SInt32                          SRefCon;
#endif

#define useLog 0

#define BUNDLE_ID CFSTR("Scriptfactory.osax.SmartActivate")
#define kSmartActivateSuite  'smAt'
#define kActivateProcessEvent	'smAt'
#define kGetVersionEvent	'Vers'
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

#if !__LP64__
int main(int argc, char *argv[])
{
	InstallMyEventHandlers();
    RunApplicationEventLoop();
	RemoveMyEventHandlers();
}
#endif

// =============================================================================

OSErr versionHandler(const AppleEvent *ev, AppleEvent *reply, SRefCon refcon)
{
#if useLog
	fprintf(stderr, "start versionHandler\n");
#endif			
	gAdditionReferenceCount++;
	OSErr err;
	CFBundleRef	bundle = CFBundleGetBundleWithIdentifier(BUNDLE_ID);
	CFDictionaryRef info = CFBundleGetInfoDictionary(bundle);
	
	CFStringRef vers = CFDictionaryGetValue(info, CFSTR("CFBundleShortVersionString"));
	err = putStringToEvent(reply, keyAEResult, vers, kCFStringEncodingUnicode);
	gAdditionReferenceCount--;
	return err;
}

OSErr activateProcessHandler(const AppleEvent *ev, AppleEvent *reply, SRefCon refcon)
{
#if useLog
	NSLog(@"start activateProcessHandler");
#endif	
	++gAdditionReferenceCount;  // increment the reference count first thing!
	
	OSErr resultCode = noErr;
	OSErr err;
	
	CFStringRef targetCreator = CFStringCreateWithEvent(ev, kCreatorParam, &err);
	CFStringRef targetIdentifier = CFStringCreateWithEvent(ev, kBundleIDParam, &err);
	CFStringRef targetName = CFStringCreateWithEvent(ev, keyDirectObject, &err);
	
	Boolean isSuccess = 0;
	CFDictionaryRef pdict = NULL;
	if (targetName || targetCreator || targetIdentifier) {
		pdict = getProcessInfo(targetCreator, targetName, targetIdentifier);
		if (pdict != NULL) {
			err = activateForProcessInfo(pdict);
			if (err == noErr) isSuccess = 1;
		}
		resultCode = noErr;
	} else {
		ProcessSerialNumber psn = {kNoProcess, kNoProcess};
		resultCode = GetCurrentProcess(&psn);
		if (resultCode != noErr) 
			goto bail;
		resultCode = SetFrontProcessWithOptions(&psn,kSetFrontProcessFrontWindowOnly);
		if (resultCode == noErr) 
			isSuccess = 1;
		else
			goto bail;		
	}

bail:
	putBoolToReply(isSuccess, reply);
	--gAdditionReferenceCount;  // don't forget to decrement the reference count when you leave!
	safeRelease(targetCreator);
	safeRelease(targetName);
	safeRelease(targetIdentifier);
	safeRelease(pdict);
	
#if useLog
	printf("end activateProcessHandler\n");
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
	{ kSmartActivateSuite, kActivateProcessEvent, activateProcessHandler },
	{ kSmartActivateSuite, kGetVersionEvent, versionHandler }
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
