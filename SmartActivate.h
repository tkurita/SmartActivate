#import <Cocoa/Cocoa.h>
#include <ApplicationServices/ApplicationServices.h>
#include <IOKit/IOCFBundle.h>

@interface SmartActivate : NSObject {

}

+(BOOL)activateAppOfType:(NSString *)targetCreator processName:(NSString*)targetName;
+(BOOL)activateAppOfType:(NSString *)targetCreator;
+(BOOL)activateAppOfName:(NSString *)targetName;

@end
