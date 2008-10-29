#include <Carbon/Carbon.r>

#define Reserved8   reserved, reserved, reserved, reserved, reserved, reserved, reserved, reserved
#define Reserved12  Reserved8, reserved, reserved, reserved, reserved
#define Reserved13  Reserved12, reserved
#define dp_none__   noParams, "", directParamOptional, singleItem, notEnumerated, Reserved13
#define reply_none__   noReply, "", replyOptional, singleItem, notEnumerated, Reserved13
#define synonym_verb__ reply_none__, dp_none__, { }
#define plural__    "", {"", kAESpecialClassProperties, cType, "", reserved, singleItem, notEnumerated, readOnly, Reserved8, noApostrophe, notFeminine, notMasculine, plural}, {}

resource 'aete' (0, "SmartActivate Terminology") {
	0x1,  // major version
	0x0,  // minor version
	english,
	roman,
	{
		"SmartActivate Suite",
		"Activate specified application with a smart way.",
		'smAt',
		1,
		1,
		{
			/* Events */

			"activate process",
			"Activate an application process with only font window",
			'smAt', 'smAt',
			'bool',
			"true if successed to activate specified process.",
			replyRequired, singleItem, notEnumerated, Reserved13,
			'TEXT',
			"process name. The value of \"CFBundleName\" in info.plist of an application bundle",
			directParamOptional,
			singleItem, notEnumerated, Reserved13,
			{
				"creatorType", 'cTyp', 'TEXT',
				"creator type of the process. The value of \"CFBundleSignature\" in info.plist of an application bundle",
				optional,
				singleItem, notEnumerated, Reserved13,
				"identifier", 'buID', 'TEXT',
				"Bundle Identifer of the process",
				optional,
				singleItem, notEnumerated, Reserved13
			}
		},
		{
			/* Classes */

		},
		{
			/* Comparisons */
		},
		{
			/* Enumerations */
		}
	}
};
