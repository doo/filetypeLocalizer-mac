#import "Group.h"

#import "Translation.h"

@implementation Group
+ (Group *)instanceFromDictionary:(NSDictionary *)aDictionary {

    Group *instance = [[Group alloc] init];
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

    if ([key isEqualToString:@"translations"]) {

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

    if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"groupId"];
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
