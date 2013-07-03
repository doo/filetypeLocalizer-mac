#import <Foundation/Foundation.h>
#import "Translation.h"

@interface Fileformat : NSObject

@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSString *deprecatedsince;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, copy) NSArray *extensions;
@property (nonatomic, copy) NSString *extractionmethod;
@property (nonatomic, copy) NSString *fullname;
@property (nonatomic, copy) NSString *group;
@property (nonatomic, copy) NSArray *mimetypes;
@property (nonatomic, copy) NSString *supportedsince;
@property (nonatomic, copy) NSArray *translations;

+ (Fileformat *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (Translation *)translationWithLanguageCode:(NSString *)languageCode;

@end
