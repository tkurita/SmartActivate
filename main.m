//activate -- activate an application process with bringing only one window to frontmost.
//Copyright (C) 2005  Tetsuro KURITA <tkurita@mac.com>
//
//This program is free software; you can redistribute it and/or
//modify it under the terms of the GNU General Public License
//as published by the Free Software Foundation; either version 2
//of the License, or (at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with this program; if not, write to the Free Software
//Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

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

int main (int argc, char * const argv[]) {

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
