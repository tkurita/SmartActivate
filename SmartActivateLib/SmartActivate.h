#include <ApplicationServices/ApplicationServices.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface SmartActivate : NSObject {

}

+ (BOOL)activateAppOfType:(NSString *)targetCreator processName:(NSString*)targetName identifier:(NSString*)targetIdentifier;
+ (BOOL)activateAppOfType:(NSString *)targetCreator;
+ (BOOL)activateAppOfName:(NSString *)targetName;
+ (BOOL)activateAppOfIdentifier:(NSString *)targetIdentifier;

+ (NSDictionary *)processInfoOfType:(NSString *)targetCreator processName:(NSString*)targetName identifier:(NSString*)targetIdentifier;
+ (NSDictionary *)processInfoOfIdentifier:(NSString*)targetIdentifier;
+ (NSDictionary *)processInfoOfName:(NSString*)targetName;
+ (NSDictionary *)processInfoOfType:(NSString *)targetCreator;

+ (BOOL)activateAppOfInfo:(NSDictionary *)pDict;
//+ (BOOL)activateSelf:(id)sender;

@end
#endif

CFDictionaryRef getProcessInfo(CFStringRef targetCreator, CFStringRef targetName, CFStringRef targetIdentifier);
OSStatus activateForProcessInfo(CFDictionaryRef pDict);
OSStatus activateSelf();
ProcessSerialNumber getPSNFromDict(CFDictionaryRef pDict);