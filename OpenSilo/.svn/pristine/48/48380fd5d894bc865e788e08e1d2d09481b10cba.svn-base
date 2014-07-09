//  Ties-CH
//
//  Created by  on 3/4/14.
//  Copyright (c) 2014 Nova Infotech Corp. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

- (NSString *)documentsDirectoryPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];

	return documentsDirectory;
}

- (NSString *)pathInDocumentDirectory {
	NSString *documentsDirectory = [self documentsDirectoryPath];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:self];
	
	return path;
}

- (NSString *)pathInDirectory:(NSString *)dir {
	NSString *documentsDirectory = [self documentsDirectoryPath];
	NSString *dirPath = [documentsDirectory stringByAppendingString:dir];
	NSString *path = [dirPath stringByAppendingString:self];
	
	NSFileManager *manager = [NSFileManager defaultManager];
	[manager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
	
	return path;
}

- (NSString *)removeWhiteSpace {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString*)stringByNormalizingCharacterInSet:(NSCharacterSet*)characterSet withString:(NSString*)replacement {
	NSMutableString* result = [NSMutableString string];
	NSScanner* scanner = [NSScanner scannerWithString:self];
	while (![scanner isAtEnd]) {
		if ([scanner scanCharactersFromSet:characterSet intoString:NULL]) {
			[result appendString:replacement];
		}
		NSString* stringPart = nil;
		if ([scanner scanUpToCharactersFromSet:characterSet intoString:&stringPart]) {
			[result appendString:stringPart];
		}
	}
			
	return [[result copy] autorelease];
}


- (NSString *)bindSQLCharacters {
	NSString *bindString = self;

	bindString = [bindString stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
	
	return bindString;
}


- (NSString *)trimSpaces {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t\n "]];
}

- (NSString *)initialStringForString {
    NSArray *comps = [self componentsSeparatedByString:@" "];
    
    NSString *sortName = @"";
    for (int i = 0; i < [comps count]; i++) {
        sortName = [sortName stringByAppendingString:[comps[i] substringToIndex:1]];
    }
    
    return sortName;
}

+ (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
	
    return [emailTest evaluateWithObject:candidate];
}

+(BOOL)validateForNumericAndCharacets:(NSString*)candidate WithLengthRange:(NSString*)strRange{
	BOOL valid = NO;
	NSCharacterSet *alphaNums = [NSCharacterSet alphanumericCharacterSet];
	NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:candidate];
	BOOL isAlphaNumeric = [alphaNums isSupersetOfSet:inStringSet];
	if(isAlphaNumeric){
		NSString *emailRegex = [NSString stringWithFormat:@"[%@]%@",candidate, strRange]; 
		NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
		valid =[emailTest evaluateWithObject:candidate];
	}
	return valid;
}

-(void)writeToLogFile {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *logFilePath = [documentsDirectory stringByAppendingString:@"/Log.txt"];
    NSString *result = self;
    NSError *error= NULL;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:logFilePath]) {
        id resultData = [NSString stringWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:&error];
        if (error == NULL) {
            result = [resultData stringByAppendingFormat:@"\n%@",result];
        }
    }
    [result writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

@end