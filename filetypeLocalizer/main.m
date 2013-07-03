//
//  main.m
//  filetypeLocalizer
//
//  Created by Sebastian Husche on 02.07.13.
//  Copyright (c) 2013 doo GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileformatsReader.h"

NSString * ISO639_2_To_ISO639_1(NSString *iso2code);
void logUsage();


void logUsage() {
    
    NSString *usageString = [NSString stringWithFormat:@"\n\nfiletypeLocalizer v1.0 copyright 2013 by doo GmbH\n\nUsage: fileTypeLocalizer -f path to input file -b base localization [-o output folder]\n\n"];
    NSString *exampleString = [NSString stringWithFormat:@"Example: filetypeLocalizer -f /Users/Me/inputJSON.text -b eng -o /Users/Me/Output\n\n"];
    NSLog(@"%@", [usageString stringByAppendingString:exampleString]);
}

int main(int argc, const char * argv[]) {
    
    @autoreleasepool {
        
        NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
        
        NSString *filename = [args stringForKey:@"f"];
        if (!filename.length) {
            NSLog(@"Error: Input file not found");
            logUsage();
            return -1;
        }
        
        NSString *baseCountrycode = [args stringForKey:@"b"];
        if (!baseCountrycode.length) {
            NSLog(@"Error: Base translation not found");
            logUsage();
            return -1;
        }
        
        NSString *outputFolder = [args stringForKey:@"o"];
        if (!outputFolder) {
            outputFolder = [filename stringByDeletingLastPathComponent];
        }
        
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDir;
        if (![fm fileExistsAtPath:outputFolder isDirectory:&isDir] || !isDir) {
            [fm createDirectoryAtPath:outputFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        
        FileFormatsReader *reader = [FileFormatsReader instanceFromFile:filename];
        if (!reader) {
            NSLog(@"Error: Invalid input file");
            return -1;
        }
        
        
        //extensions to group mapping
        NSMutableDictionary *extensionToGroupMapping = [[NSMutableDictionary alloc]init];
        
        for (Fileformat *format in reader.fileformats) {
            for (NSString *extension in format.extensions) {
                Group *group = [reader groupWithID:format.group];
                Translation *groupTranslation = [group translationWithLanguageCode:baseCountrycode];
                NSString *groupName = groupTranslation.translation;
                [extensionToGroupMapping setObject:groupName forKey:extension];
            }
        }
        NSLog(@"%@", extensionToGroupMapping);
        
        
        //extensions to filetype mapping
        NSMutableDictionary *extensionToTypeMapping = [[NSMutableDictionary alloc]init];
        
        for (Fileformat *format in reader.fileformats) {
            Translation *translation = [format translationWithLanguageCode:baseCountrycode];
            for (NSString *extension in format.extensions) {
                NSString *formatName = translation.translation;
                [extensionToTypeMapping setObject:formatName forKey:extension];
            }
        }
        NSLog(@"%@", extensionToTypeMapping);
        
        
        
        //localize groups
        NSMutableDictionary *localizedGroups = [[NSMutableDictionary alloc]init];
        for (Group *group in reader.groups) {
            Translation *baseTranslation = [group translationWithLanguageCode:baseCountrycode];
            for (Translation *translation in group.translations) {
                
                NSString *currentCountrycode = translation.languagecode;
                
                NSMutableDictionary *translationDict = localizedGroups[currentCountrycode];
                if (!translationDict) {
                    translationDict = [[NSMutableDictionary alloc]init];
                    localizedGroups[currentCountrycode] = translationDict;
                }
                translationDict[baseTranslation.translation] = translation.translation;
            }
        }
        NSLog(@"%@", localizedGroups);
        
        //localize extensions
        NSMutableDictionary *localizedExtensions = [[NSMutableDictionary alloc]init];
        for (Fileformat *format in reader.fileformats) {
            Translation *baseTranslation = [format translationWithLanguageCode:baseCountrycode];
            for (Translation *translation in format.translations) {
                NSString *currentCountrycode = translation.languagecode;
                
                NSMutableDictionary *translationDict = localizedExtensions[currentCountrycode];
                if (!translationDict) {
                    translationDict = [[NSMutableDictionary alloc]init];
                    localizedExtensions[currentCountrycode] = translationDict;
                }
                translationDict[baseTranslation.translation] = translation.translation;
            }
        }
        NSLog(@"%@", localizedExtensions);
        
        
        //write to files
        NSString *groupMappingFile = [outputFolder stringByAppendingPathComponent:@"fileExtensionToGroupMap.plist"];
        [extensionToGroupMapping writeToFile:groupMappingFile atomically:YES];
        
        NSString *extensionMappingFile = [outputFolder stringByAppendingPathComponent:@"fileExtensionToTypeMap.plist"];
        [extensionToTypeMapping writeToFile:extensionMappingFile atomically:YES];
        
        
        // write strings files
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterMediumStyle;
        
        for (NSString *languageCode in localizedGroups.allKeys) {
            
            NSString *languageOutputFolder = [outputFolder stringByAppendingPathComponent:
                                              [NSString stringWithFormat:@"%@.lproj", ISO639_2_To_ISO639_1(languageCode)]];
            
            BOOL isDir;
            if (![fm fileExistsAtPath:languageOutputFolder isDirectory:&isDir] || !isDir) {
                [fm createDirectoryAtPath:languageOutputFolder withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            NSMutableString *s = [[NSMutableString alloc]initWithString:@"/* Autogenerated localization of file groups and file types */\n"];
            //            [s appendFormat:@"/* Created: %@ */\n", [formatter stringFromDate:[NSDate date]]];
            
            [s appendString:@"\n\n\n/* Filetype groups */\n"];
            NSDictionary *groups = localizedGroups[languageCode];
            for (NSString *key in groups.allKeys) {
                [s appendFormat:@"\n\"%@\" = \"%@\";\n", key, groups[key]];
            }
            
            [s appendString:@"\n\n\n/* Filetype extensions */\n"];
            
            NSDictionary *extensions = localizedExtensions[languageCode];
            for (NSString *key in extensions.allKeys) {
                [s appendFormat:@"\n\"%@\" = \"%@\";\n", key, extensions[key]];
            }
            
            NSString *filename = [languageOutputFolder stringByAppendingPathComponent:@"fileTypes.strings"];
            [s writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
        }
        
    }
    return 0;
}

NSString * ISO639_2_To_ISO639_1(NSString *iso2code) {
    
    static NSDictionary *_isoMapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _isoMapping = @{
                        @"aar": @"aa",
                        @"abk": @"ab",
                        @"afr": @"af",
                        @"aka": @"ak",
                        @"sqi": @"sq",
                        @"amh": @"am",
                        @"ara": @"ar",
                        @"arg": @"an",
                        @"hye": @"hy",
                        @"asm": @"as",
                        @"ava": @"av",
                        @"ave": @"ae",
                        @"aym": @"ay",
                        @"aze": @"az",
                        @"bak": @"ba",
                        @"bam": @"bm",
                        @"eus": @"eu",
                        @"bel": @"be",
                        @"ben": @"bn",
                        @"bih": @"bh",
                        @"bis": @"bi",
                        @"bod": @"bo",
                        @"bos": @"bs",
                        @"bre": @"br",
                        @"bul": @"bg",
                        @"mya": @"my",
                        @"cat": @"ca",
                        @"ces": @"cs",
                        @"cha": @"ch",
                        @"che": @"ce",
                        @"zho": @"zh",
                        @"chu": @"cu",
                        @"chv": @"cv",
                        @"cor": @"kw",
                        @"cos": @"co",
                        @"cre": @"cr",
                        @"cym": @"cy",
                        @"ces": @"cs",
                        @"dan": @"da",
                        @"deu": @"de",
                        @"div": @"dv",
                        @"nld": @"nl",
                        @"dzo": @"dz",
                        @"ell": @"el",
                        @"eng": @"en",
                        @"epo": @"eo",
                        @"est": @"et",
                        @"eus": @"eu",
                        @"ewe": @"ee",
                        @"fao": @"fo",
                        @"fas": @"fa",
                        @"fij": @"fj",
                        @"fin": @"fi",
                        @"fra": @"fr",
                        @"fra": @"fr",
                        @"fry": @"fy",
                        @"ful": @"ff",
                        @"kat": @"ka",
                        @"deu": @"de",
                        @"gla": @"gd",
                        @"gle": @"ga",
                        @"glg": @"gl",
                        @"glv": @"gv",
                        @"ell": @"el",
                        @"grn": @"gn",
                        @"guj": @"gu",
                        @"hat": @"ht",
                        @"hau": @"ha",
                        @"heb": @"he",
                        @"her": @"hz",
                        @"hin": @"hi",
                        @"hmo": @"ho",
                        @"hrv": @"hr",
                        @"hun": @"hu",
                        @"hye": @"hy",
                        @"ibo": @"ig",
                        @"isl": @"is",
                        @"ido": @"io",
                        @"iii": @"ii",
                        @"iku": @"iu",
                        @"ile": @"ie",
                        @"ina": @"ia",
                        @"ind": @"id",
                        @"ipk": @"ik",
                        @"isl": @"is",
                        @"ita": @"it",
                        @"jav": @"jv",
                        @"jpn": @"ja",
                        @"kal": @"kl",
                        @"kan": @"kn",
                        @"kas": @"ks",
                        @"kat": @"ka",
                        @"kau": @"kr",
                        @"kaz": @"kk",
                        @"khm": @"km",
                        @"kik": @"ki",
                        @"kin": @"rw",
                        @"kir": @"ky",
                        @"kom": @"kv",
                        @"kon": @"kg",
                        @"kor": @"ko",
                        @"kua": @"kj",
                        @"kur": @"ku",
                        @"lao": @"lo",
                        @"lat": @"la",
                        @"lav": @"lv",
                        @"lim": @"li",
                        @"lin": @"ln",
                        @"lit": @"lt",
                        @"ltz": @"lb",
                        @"lub": @"lu",
                        @"lug": @"lg",
                        @"mkd": @"mk",
                        @"mah": @"mh",
                        @"mal": @"ml",
                        @"mri": @"mi",
                        @"mar": @"mr",
                        @"msa": @"ms",
                        @"mkd": @"mk",
                        @"mlg": @"mg",
                        @"mlt": @"mt",
                        @"mon": @"mn",
                        @"mri": @"mi",
                        @"msa": @"ms",
                        @"mya": @"my",
                        @"nau": @"na",
                        @"nav": @"nv",
                        @"nbl": @"nr",
                        @"nde": @"nd",
                        @"ndo": @"ng",
                        @"nep": @"ne",
                        @"nld": @"nl",
                        @"nno": @"nn",
                        @"nob": @"nb",
                        @"nor": @"no",
                        @"nya": @"ny",
                        @"oci": @"oc",
                        @"oji": @"oj",
                        @"ori": @"or",
                        @"orm": @"om",
                        @"oss": @"os",
                        @"pan": @"pa",
                        @"fas": @"fa",
                        @"pli": @"pi",
                        @"pol": @"pl",
                        @"por": @"pt",
                        @"pus": @"ps",
                        @"qaa-que": @"qu",
                        @"roh": @"rm",
                        @"ron": @"ro",
                        @"ron": @"ro",
                        @"run": @"rn",
                        @"rus": @"ru",
                        @"sag": @"sg",
                        @"san": @"sa",
                        @"sin": @"si",
                        @"slk": @"sk",
                        @"slk": @"sk",
                        @"slv": @"sl",
                        @"sme": @"se",
                        @"smo": @"sm",
                        @"sna": @"sn",
                        @"snd": @"sd",
                        @"som": @"so",
                        @"sot": @"st",
                        @"spa": @"es",
                        @"sqi": @"sq",
                        @"srd": @"sc",
                        @"srp": @"sr",
                        @"ssw": @"ss",
                        @"sun": @"su",
                        @"swa": @"sw",
                        @"swe": @"sv",
                        @"tah": @"ty",
                        @"tam": @"ta",
                        @"tat": @"tt",
                        @"tel": @"te",
                        @"tgk": @"tg",
                        @"tgl": @"tl",
                        @"tha": @"th",
                        @"bod": @"bo",
                        @"tir": @"ti",
                        @"ton": @"to",
                        @"tsn": @"tn",
                        @"tso": @"ts",
                        @"tuk": @"tk",
                        @"tur": @"tr",
                        @"twi": @"tw",
                        @"uig": @"ug",
                        @"ukr": @"uk",
                        @"urd": @"ur",
                        @"uzb": @"uz",
                        @"ven": @"ve",
                        @"vie": @"vi",
                        @"vol": @"vo",
                        @"cym": @"cy",
                        @"wln": @"wa",
                        @"wol": @"wo",
                        @"xho": @"xh",
                        @"yid": @"yi",
                        @"yor": @"yo",
                        @"zha": @"za",
                        @"zho": @"zh",
                        @"zul": @"zu"
                        };
    });
    
    iso2code = [iso2code lowercaseString];
    NSString *result = _isoMapping[iso2code];
    if (!result) {
        result = iso2code;
    }
    
    return result;
    
}


