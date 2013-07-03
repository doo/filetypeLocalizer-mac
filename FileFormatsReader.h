#import <Foundation/Foundation.h>
#import "Group.h"
#import "Fileformat.h"
#import "Translation.h"

@interface FileFormatsReader : NSObject

@property (nonatomic, copy) NSArray *fileformats;
@property (nonatomic, copy) NSArray *groups;

+ (FileFormatsReader *)instanceFromFile:(NSString *)path;
+ (FileFormatsReader *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

- (Group *)groupWithID:(NSString *)groupID;

@end
