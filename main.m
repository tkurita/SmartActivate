#import "SmartActivate.h"
#include <getopt.h>

#define useLog 0

void usage() {
	printf("Usage: activate [-t] [Creator Type] [-i] [Bundle Identifier] [Process Name]\n");
}

void showHelp() {
	usage();
	printf("\nset front process to the specified process with only front window.\n");
	printf("The process is specified with following parameters.\n\n");
	printf("Process Name -- Usually the name of application process shown in menu bar.\n");
	printf("                The value of CFBundleName of an application bundle.\n\n");
	printf("Creator Type -- The value of CFBundleSignagure of an application bundle.\n\n");
	printf("Bundle Identifier -- The value of CFBundleIdentifier of an application bundle.\n");
}

void showVersion() {
	printf("activate 1.0 copyright 2005, Tetsuro KURITA\n");
}

//extern char *optarg;
//extern int optind, opterr, optopt;

int main (int argc, char * const argv[]) {
	/*
	if (argc > 10) {
		// too many arguments
		printf("Too many arguments.\n");
		usage();
		exit(-1);
	}
	 */

#if useLog
	printf("argc %i\n",argc);
	for (int i=0; i < argc; i++) {
		printf("%i\t%s\n",i,argv[i]);
	}
#endif
	
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	/* get arguments */
	static struct option long_options[] = {
		{"version", 0, NULL, 'v'},
		{"help", 0, NULL, 'h'},
		{0, 0, 0, 0}
	};
	int option_index = 0;
	
	NSString *targetCreator = nil;
	NSString *targetName = nil;
	NSString *targetIdentifier = nil;
	
	int c;
	while(1){
		c = getopt_long(argc, argv, "t:i:vh",long_options, &option_index);
        if (c == -1)
            break;

		switch(c){			
			case 'h':
				showHelp();
				exit(0);
			case 'v':
				showVersion();
				exit(0);
			case 't': 
				targetCreator = [NSString stringWithCString:optarg];
				break;
			case 'i': 
				targetIdentifier = [NSString stringWithCString:optarg];
				break;				
			case '?':
			default	:
				printf("There is unknown option.\n");
				usage(); 
				exit(-1);
				break;
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
