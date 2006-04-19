#include <ApplicationServices/ApplicationServices.h>

#ifdef __OBJC__
#import <Cocoa/Cocoa.h>

@interface SmartActivate : NSObject {

}

+(BOOL)activateAppOfType:(NSString *)targetCreator processName:(NSString*)targetName identifier:(NSString*)targetIdentifier;
+(BOOL)activateAppOfType:(NSString *)targetCreator;
+(BOOL)activateAppOfName:(NSString *)targetName;

@end
#endif

CFDictionaryRef getProcessInfo(CFStringRef targetCreator, CFStringRef targetName, CFStringRef targetIdentifier);

OSStatus activateForProcessInfo(CFDictionaryRef pDict);