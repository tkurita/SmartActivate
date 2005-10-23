#import "SmartActivate.h"
#include <Carbon/Carbon.h>

#ifdef __cplusplus
#define EXTERN_C extern "C"
#else
#define EXTERN_C
#endif

#define useLog 0

#define kSmartActivateSuite  'smAt'
#define kActivateProcessEvent	'smAt'

UInt32			gAdditionReferenceCount = 0;
CFBundleRef		gAdditionBundle;

static BOOL isEventsInstalled;
// =============================================================================
// == Entry points.

static OSErr InstallMyEventHandlers();
static void RemoveMyEventHandlers();
void SATerminate();

EXTERN_C OSErr SAInitialize(CFBundleRef theBundle)
{
	/*  Typically, scripting additions either totally succeed to load or totally fail.  This is usually, but not always, the right thing to do -- if you had an addition where part of it relied on a shared library, but part didn't, you might want to run in a reduced mode if the library could not be found. */
	
	gAdditionBundle = theBundle;  // no retain needed.
	
	// Any other setup you need here...
	if (atexit(SATerminate)) {
		return InstallMyEventHandlers();
	}
	else {
		return 0;
	}
}

EXTERN_C void SATerminate()
{
	// Release anything you allocated in SAInitialize here...
#if useLog
	printf("start SATerminate\n");
#endif
	if (isEventsInstalled) {
		RemoveMyEventHandlers();
		isEventsInstalled = NO;
	}
}

EXTERN_C Boolean SAIsBusy()
{
	return true;
	//return gAdditionReferenceCount != 0;
}

int main(int argc, char *argv[])
{
	InstallMyEventHandlers();
    RunApplicationEventLoop();
	RemoveMyEventHandlers();
	//return NSApplicationMain(argc, (const char **) argv);
}

// =============================================================================

OSErr MyEventHandler(const AppleEvent *ev, AppleEvent *reply, long refcon)
{
#if useLog
	NSLog(@"start MyEventHandler");
#endif	
	++gAdditionReferenceCount;  // increment the reference count first thing!
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	OSErr resultCode;
	OSErr err;
#if useLog
//	Handle result;
//	OSStatus resultStatus;
//	resultStatus = AEPrintDescToHandle(ev,&result);
//	printf("%s\n",*result);
#endif
	NSString *targetCreator = nil;
	NSString *targetName = nil;
	NSString *targetIdentifier = nil;
	
	AppleEvent newEv;
	err = AEDuplicateDesc(ev,&newEv);
	NSAppleEventDescriptor *aEvent = [[[NSAppleEventDescriptor alloc] initWithAEDescNoCopy:&newEv] autorelease];
	NSAppleEventDescriptor *creatorDsc = [aEvent paramDescriptorForKeyword:'cTyp'];
	if (creatorDsc != nil) {
#if useLog
		NSLog([creatorDsc stringValue]);
#endif		
		targetCreator = [creatorDsc stringValue];
	}

	NSAppleEventDescriptor *identifierDsc = [aEvent paramDescriptorForKeyword:'buID'];
	if (identifierDsc != nil) {
#if useLog
		NSLog([creatorDsc stringValue]);
#endif		
		targetIdentifier = [identifierDsc stringValue];
	}
	
	NSAppleEventDescriptor *dParamDsc = [aEvent paramDescriptorForKeyword:keyDirectObject];
	if (dParamDsc != nil) {
#if useLog
		NSLog([dParamDsc stringValue]);
#endif		
		targetName = [dParamDsc stringValue];
	}
	
	BOOL isSuccess = NO;
	if (targetName || targetCreator || targetIdentifier) {
		isSuccess = [SmartActivate activateAppOfType:targetCreator processName:targetName identifier:targetIdentifier];
		resultCode = noErr;
	}
	else {
		isSuccess = NO;
		resultCode = errAEDescNotFound;
	}

	//NSAppleEventDescriptor *replayDsc = [[NSAppleEventDescriptor descriptorWithBoolean:isSuccess] retain];
	NSAppleEventDescriptor *replayDsc = [NSAppleEventDescriptor descriptorWithBoolean:isSuccess];
	err=AEPutParamDesc(reply, keyAEResult,[replayDsc aeDesc]);
	[pool release];
	--gAdditionReferenceCount;  // don't forget to decrement the reference count when you leave!
#if useLog
	printf("end MyEventHandler\n");
#endif
	return resultCode;
	//return noErr;
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
	isEventsInstalled = YES;
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
