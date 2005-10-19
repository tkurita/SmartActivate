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
		"Things that this addition supports",
		'smAt',
		1,
		1,
		{
			/* Events */

			"ActivateProcess",
			"Activate application with only frontmost window",
			'smAt', 'smAt',
			'bool',
			"true if successed to activate process, ",
			replyRequired, singleItem, notEnumerated, Reserved13,
			'TEXT',
			"process name",
			directParamOptional,
			singleItem, notEnumerated, Reserved13,
			{
				"creatorType", 'cTyp', 'TEXT',
				"creator type of process",
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
