//
//  EOCAutoDictionary.m
//  TestOC
//
//  Created by Utopia on 2017/3/21.
//  Copyright © 2017年 Utopia. All rights reserved.
//

#import "EOCAutoDictionary.h"
#import <objc/runtime.h>

@interface EOCAutoDictionary()

@property (nonatomic, strong)NSMutableDictionary *backingStore;

@end

@implementation EOCAutoDictionary

@dynamic string, number, date, opaqueObject;

- (instancetype)init{
    if (self = [super init]) {
        _backingStore = [NSMutableDictionary new];
    }
    return self;
}


+ (BOOL)resolveInstanceMethod:(SEL)selector {
    
    NSString *selectorString = NSStringFromSelector(selector);
    
    if ([selectorString hasPrefix:@"set"]){
        class_addMethod(self, selector, (IMP)autoDictionarySetter, "v@:@");
        
    } else {
        
        class_addMethod(self, selector, (IMP)autoDictionaryGetter, "@@:");
        
    } return YES;
    
}

id autoDictionaryGetter(id self, SEL _cmd) {
    
    // Get the backing store from the object
    
    EOCAutoDictionary *typedSelf = (EOCAutoDictionary*)self;
    NSMutableDictionary *backingStore = typedSelf.backingStore;
    
    // The key is simply the selector name
    NSString *key = NSStringFromSelector(_cmd);
    
    // Return the value
    return [backingStore objectForKey:key];
    
}

void autoDictionarySetter(id self, SEL _cmd, id value) {
    
    // Get the backing store from the object
    EOCAutoDictionary *typedSelf = (EOCAutoDictionary*)self;
    
    NSMutableDictionary *backingStore = typedSelf.backingStore;
    /** The selector will be for example, "setOpaqueObject:".
     * We need to remove the "set", ":" and lowercase the first
     * letter of the remainder.
     */
    
    NSString *selectorString = NSStringFromSelector(_cmd);
    
    NSMutableString *key = [selectorString mutableCopy];
    
    // Remove the ':' at the end [key deleteCharactersInRange:NSMakeRange(key.length - 1, 1)];
    
    // Remove the 'set' prefix
    [key deleteCharactersInRange:NSMakeRange(0, 3)];
    
    // Lowercase the first character
    NSString *lowercaseFirstChar = [[key substringToIndex:1] lowercaseString];
    
    [key replaceCharactersInRange:NSMakeRange(0, 1) withString:lowercaseFirstChar];
    
    if (value) {
        [backingStore setObject:value forKey:key];
    } else {
        [backingStore removeObjectForKey:key];
    }
}


@end
