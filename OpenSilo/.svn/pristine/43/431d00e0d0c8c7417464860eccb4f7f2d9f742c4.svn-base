
#import "NSMutableDictionary+Extension.h"

@implementation NSMutableDictionary (Extension)

-(void)handleNullValues {
    NSArray *keys = [self allKeys];
    for (int i = 0; i < [keys count]; i++) {
        id object = [self objectForKey:[keys objectAtIndex:i]];
        if ([object isKindOfClass:[NSNull class]]) {
            [self setObject:@"" forKey:[keys objectAtIndex:i]];
        }
    }
}

@end
