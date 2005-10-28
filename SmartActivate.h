#import <Cocoa/Cocoa.h>
#include <ApplicationServices/ApplicationServices.h>
#include <IOKit/IOCFBundle.h>

NSDictionary *getProcessInfo(id targetCreator, id targetName, id targetIdentifier);

@interface SmartActivate : NSObject {

}

+(BOOL)activateAppOfType:(NSString *)targetCreator processName:(NSString*)targetName identifier:(NSString*)targetIdentifier;
+(BOOL)activateAppOfType:(NSString *)targetCreator;
+(BOOL)activateAppOfName:(NSString *)targetName;

@end
