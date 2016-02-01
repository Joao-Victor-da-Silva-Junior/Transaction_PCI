
#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (strong, nonatomic) NSMutableDictionary *mainDictionary; //Нужен ли словарь? Нужно ли создавать объект класса или можно обойтись методами класса?

+ (NSMutableDictionary *) returnRandomValues;

@end