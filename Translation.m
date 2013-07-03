#import "Translation.h"

@implementation Translation
+ (Translation *)instanceFromDictionary:(NSDictionary *)aDictionary {

    Translation *instance = [[Translation alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];

}


@end
