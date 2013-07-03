#import "FileFormatsReader.h"

#import "Fileformat.h"
#import "Group.h"

@implementation FileFormatsReader

+ (FileFormatsReader *)instanceFromDictionary:(NSDictionary *)aDictionary {

    FileFormatsReader *instance = [[FileFormatsReader alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

+ (FileFormatsReader *)instanceFromFile:(NSString *)path {
    
    NSData *data = [[NSData alloc]initWithContentsOfFile:path];
    if (!data) {
        return nil;
    }
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [self instanceFromDictionary:jsonDict];
}


- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forKey:(NSString *)key {

    if ([key isEqualToString:@"fileformats"]) {

        if ([value isKindOfClass:[NSArray class]]) {

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                Fileformat *populatedMember = [Fileformat instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.fileformats = myMembers;

        }

    } else if ([key isEqualToString:@"groups"]) {

        if ([value isKindOfClass:[NSArray class]]) {

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                Group *populatedMember = [Group instanceFromDictionary:valueMember];
                [myMembers addObject:populatedMember];
            }

            self.groups = myMembers;

        }

    } else {
        [super setValue:value forKey:key];
    }

}

- (Group *)groupWithID:(NSString *)groupID {
    return [[self.groups filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"groupId == %@", groupID]]lastObject];
}



@end
