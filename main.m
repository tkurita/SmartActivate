#import "SmartActivate.h"
#include <unistd.h>

#define useLog 0

void usage() {
	printf("Usage: activate [-t] [Creator Type] [-i] [Bundle Identifier] [Process Name]\n");
	exit(-1);
}

extern char *optarg;
extern int optind, opterr, optopt;

int main (int argc, char * const argv[]) {
	if (argc > 6) {
		// too many arguments
		printf("Too many arguments.\n");
		usage();
	}

#if useLog
	printf("argc %i\n",argc);
	for (int i=0; i < argc; i++) {
		printf("%i\t%s\n",i,argv[i]);
	}
#endif
	
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	/* get arguments */
	NSString *targetCreator = nil;
	NSString *targetName = nil;
	NSString *targetIdentifier = nil;
	
	while(getopt(argc, argv, "t:i:") != -1 ){
		switch(optopt){
			case 't': 
				targetCreator = [NSString stringWithCString:optarg];
				break;
			case 'i': 
				targetIdentifier = [NSString stringWithCString:optarg];
				break;				
			case '?':
			default	:
				printf("There is unknown option.\n");
				usage(); break;
		}
		optarg	=	NULL;
	}

#if useLog
	printf("%i\t%i\n",argc,optind);
#endif
	
	if (optind < argc) {		
		targetName = [NSString stringWithCString:argv[optind]];
	}
#if useLog
	NSLog(targetCreator);
	NSLog(targetName);
#endif
	
	BOOL isSuccess = [SmartActivate activateAppOfType:targetCreator processName:targetName identifier:targetIdentifier];
    [pool release];
	
	if (isSuccess)
		return 0;
	else
		return 1;
}
