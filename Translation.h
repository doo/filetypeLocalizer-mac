#import <Foundation/Foundation.h>

@interface Translation : NSObject

@property (nonatomic, copy) NSString *languagecode;
@property (nonatomic, copy) NSString *translation;

+ (Translation *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
