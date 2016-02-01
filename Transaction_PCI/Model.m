
#import "Model.h"

@implementation Model

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mainDictionary = [NSMutableDictionary dictionary];
        _mainDictionary[@"Scale"] = @60.f;
        _mainDictionary[@"Frame End"] = @660.f;
    }
    return self;
}

+ (NSMutableDictionary *) returnRandomValues {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    return dictionary;
}
@end
