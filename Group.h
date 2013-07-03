#import <Foundation/Foundation.h>
#import "Translation.h"

@interface Group : NSObject

@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *mimetype;
@property (nonatomic, copy) NSArray *translations;

+ (Group *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (Translation *)translationWithLanguageCode:(NSString *)languageCode;

@end
