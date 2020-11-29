@import Foundation;

@interface HotKey : NSObject

+ (void)withKey:(NSString *)key mods:(NSArray *)mods handler:(dispatch_block_t)handler;

@end
