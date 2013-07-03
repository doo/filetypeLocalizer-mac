#import "Fileformat.h"

#import "Translation.h"

@implementation Fileformat
+ (Fileformat *)instanceFromDictionary:(NSDictionary *)aDictionary {

    Fileformat *instance = [[Fileformat alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forKey:(NSString *)key {

    if ([key isEqualToString:@"extensions"]) {

        if ([value isKindOfClass:[NSArray class]]) {

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                [myMembers addObject:valueMember];
            }

            self.extensions = myMembers;

        }

    } else if ([key isEqualToString:@"mimetypes"]) {

        if ([value isKindOfClass:[NSArray class]]) {

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                [myMembers addObject:valueMember];
            }

            self.mimetypes = myMembers;

        }

    } else if ([key isEqualToString:@"translations"]) {

        if ([value isKindOfClass:[NSArray class]]) {

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                Translation *populatedMember = [Translation instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.translations = myMembers;

        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

    if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionText"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }

}

- (Translation *)translationWithLanguageCode:(NSString *)languageCode {
    for (Translation *trans in self.translations) {
        if ([trans.languagecode isEqualToString:languageCode])
            return trans;
    }
    return nil;
}



@end
