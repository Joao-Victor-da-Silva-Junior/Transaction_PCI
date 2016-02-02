
#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (strong, nonatomic) NSMutableDictionary *mainDictionary; //Нужен ли словарь? Нужно ли создавать объект класса или можно обойтись методами класса?

+ (NSMutableDictionary *) returnRandomValues;

+ (NSMutableDictionary *) returnDictionaryUsingCells:(BOOL) isCells
                                          parameters:(CGFloat) param
                                             bitWord:(NSInteger) bitWord
                                             command:(NSInteger) cmd
                                        digitAddress:(NSInteger) digAdr
                                          accessTime:(NSInteger) access
                                       andViewAccess:(NSString *) view;
@end