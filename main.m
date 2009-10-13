//activate -- activate an application process with bringing only one window to frontmost.
//Copyright (C) 2005-2007  Tetsuro KURITA <tkurita@mac.com>
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
#include <stdlib.h>
#include <getopt.h>
#include <locale.h>
#include <langinfo.h>
#include <iconv.h>
#include <errno.h>

#define BufferSize 256

static iconv_t utf8conv_t;
static char *current_charset;

#define useLog 0

void usage() {
	printf("Usage: activate [-t creator_type] [-i bundle_identifier] [process_name]\n");
}

void showHelp() {
	usage();
	printf("\nset front process to the specified process with only front window.\n");
	printf("The process is specified with following parameters.\n\n");
	printf("Process Name -- Usually the name of application process shown in the menu bar.\n");
	printf("                The value of CFBundleName of the application bundle.\n\n");
	printf("Creator Type -- The value of CFBundleSignagure of the application bundle.\n\n");
	printf("Bundle Identifier -- The value of CFBundleIdentifier of the application bundle.\n");
}

void showVersion() {
	printf("activate 1.0.6 copyright 2005-2009, Tetsuro KURITA\n");
}

NSString *stringForUTF8(char *inbuf) {
	return [NSString stringWithUTF8String:inbuf];
}

NSString *stringWithConvert(char *inbuf) {
	const size_t initial_size = strlen(inbuf);
	size_t inbyteleft = initial_size;
	
	char *inbuf_p = inbuf;
	size_t current_buffsize = BufferSize;
	
	size_t conv_result;
	#if useLog
	NSLog([NSString stringWithFormat:@"inbuf :%@", [NSString stringWithUTF8String:inbuf]]);	 
	#endif
	NSMutableString *new_string = [NSMutableString string];
	conv_result = iconv(utf8conv_t, NULL, NULL, NULL, NULL);
	if (conv_result == (size_t)-1) {
		perror("Error : iconv");
		goto bail;
	}
	while (inbyteleft > 0) {
		char outbuf[BufferSize]="";
		char *outbuf_p = outbuf;
		size_t outbyteleft = BufferSize-1;
		conv_result = iconv(utf8conv_t, (char **)&inbuf, &inbyteleft, &outbuf_p, &outbyteleft);
		if (conv_result == (size_t)-1) {
			switch (errno) {
				case E2BIG:
					#if useLog
					printf("E2BIG : There is not sufficient room at *outbuf.\n");
					#endif
					break;
				case EILSEQ:
					perror("Error : iconv");
					//printf("EILSEQ : An invalid multibyte sequence has been encountered in the input.\n");
					return nil;
					break;
				case EINVAL:
					perror("Error : iconv");
					//printf("EINVAL : An incomplete multibyte sequence has been encountered in the input.\n");
					return nil;
					break;
				default :
					perror("Error : iconv");
					break;
			}
		}
		#if useLog
		NSString *outstr = [NSString stringWithUTF8String:outbuf];
		NSLog([NSString stringWithFormat:@"outstr : %@", outstr]);
		#endif
		[new_string appendString:[NSString stringWithUTF8String:outbuf] ];
	}
	
	#if useLog
	NSLog([NSString stringWithFormat:@"new_string : %@", new_string]);
	#endif
bail:	
	iconv_close(utf8conv_t);
	return new_string;
}

void *converter_with_locale() {
	char *current_locale = setlocale(LC_CTYPE, "");
	#if useLog
	printf("Current Locale: %s :%d\n", current_locale, strlen(current_locale));
	#endif
	if (!current_locale) return stringForUTF8;
	if (strcmp(current_locale, "C") == 0) return stringForUTF8;
	
	current_charset = nl_langinfo(CODESET);
	#if useLog
	printf("CODESET : %s\n", current_charset);
	#endif
	
	if (strcmp(current_charset, "UTF-8") != 0) {
		utf8conv_t = iconv_open ("UTF-8", current_charset);
		if (utf8conv_t < 0) {
			perror("Error : iconv_open");
			return NULL;
		}
		return stringWithConvert;
	} else {
		return stringForUTF8;
	}
	
}

NSString *normalizeString(NSString *inString, CFStringNormalizationForm normForm)
{
	NSMutableString *mutable_string = [inString mutableCopy];
	CFStringNormalize((CFMutableStringRef) mutable_string, normForm);
	return mutable_string;
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
				targetCreator = [NSString stringWithUTF8String:optarg];
				break;
			case 'i': 
				targetIdentifier = [NSString stringWithUTF8String:optarg];
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
	NSLog([NSString stringWithFormat:@"targetCreator : %@", targetCreator]);
	NSLog([NSString stringWithFormat:@"targetName : %@", targetName]);
	printf("%i\t%i\n",argc,optind);
#endif
	
	if (optind < argc) {		
		NSString * (* stringFromLocaleString)(char *inbuf) = converter_with_locale();
		if (stringFromLocaleString != NULL) {
			targetName = stringFromLocaleString(argv[optind]);
			if (targetName) 
				targetName = normalizeString(targetName, kCFStringNormalizationFormKC);
		}
	}
	
	BOOL isSuccess = NO;
	if (targetName || targetCreator || targetIdentifier) {
		isSuccess = [SmartActivate activateAppOfType:targetCreator processName:targetName identifier:targetIdentifier];
	} else {
		fprintf(stdout, "No valid arguments.\n");
	}
	
    [pool release];

	if (isSuccess)
		return 0;
	else
		return 1;
}
