//
//  AutoreleasePool.m
//  HRAutoreleasePool
//
//  Created by Dmitry Rykun on 2/7/20.
//  Copyright © 2020 Dmitry Rykun. All rights reserved.
//

#import "AutoreleasePool.h"
#import "autorelease_pool.h"
#include "autorelease_pool_stack.h"
#import <objc/runtime.h>
#import <pthread.h>

//id __autorelease(id self, SEL _cmd) {
//    [AutoreleasePool addObject:self];
//    return self;
//}

@implementation NSObject (HRAutoreleasePool)

- (id)hrAutorelease {
    [AutoreleasePool addObject:self];
    return self;
}

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Method method = class_getInstanceMethod(self, @selector(autorelease));
//        method_setImplementation(method, (IMP)__autorelease);
//    });
//}

@end


static pthread_key_t autorelease_pool_key;
static pthread_once_t autorelease_pool_key_once = PTHREAD_ONCE_INIT;

static void autorelease_pool_key_make() {
    pthread_key_create(&autorelease_pool_key, NULL);
}

pthread_key_t autorelease_pool_key_get() {
    pthread_once(&autorelease_pool_key_once, autorelease_pool_key_make);
    return autorelease_pool_key;
}

autorelease_pool_stack *autorelease_pool_stack_get_current() {
    autorelease_pool_stack *stack = pthread_getspecific(autorelease_pool_key_get());
    return stack;
}

autorelease_pool* autorelease_pool_get_current() {
    autorelease_pool_stack *stack = autorelease_pool_stack_get_current();
    autorelease_pool *pool = autorelease_pool_stack_get_topmost_autorelease_pool(stack);
    return pool;
}

autorelease_pool* autorelease_pool_push() {
    autorelease_pool *pool = autorelease_pool_create();
    autorelease_pool_stack *stack = autorelease_pool_stack_get_current();
    if (stack == NULL) {
        stack = autorelease_pool_stack_create();
        pthread_setspecific(autorelease_pool_key, stack);
    }
    autorelease_pool_stack_push_autorelease_pool(stack, pool);
    return pool;
}

void autorelease_pool_pop(autorelease_pool *pool) {
    assert(pool == autorelease_pool_get_current());
    autorelease_pool_release_objects(pool);
    autorelease_pool_stack_pop_autorelease_pool(autorelease_pool_stack_get_current());
    autorelease_pool_delete(pool);
}

void thread_delete_autorelease_pool_stack() {
    autorelease_pool_stack *stack = autorelease_pool_stack_get_current();
    if (stack == NULL) {
        return;
    }
    while (stack->current >= 0) {
        autorelease_pool_stack_pop_autorelease_pool(stack);
    }
    pthread_setspecific(autorelease_pool_key, NULL);
    autorelease_pool_stack_delete(stack);
}

@interface AutoreleasePool () {
    autorelease_pool* pool;
}
@end

@implementation AutoreleasePool

- (instancetype)init {
    self = [super init];
    if (self) {
        pool = autorelease_pool_push();
        [self startObservingNotifications];
    }
    return self;
}

- (void)startObservingNotifications {
    id __block token = [NSNotificationCenter.defaultCenter addObserverForName:NSThreadWillExitNotification
                                                                       object:nil
                                                                        queue:nil
                                                                   usingBlock:^(NSNotification * _Nonnull note) {
        [NSNotificationCenter.defaultCenter removeObserver:token];
        thread_delete_autorelease_pool_stack();
//        [super release];
    }];
}

+ (void)addObject:(id)anObject {
    autorelease_pool_add_object(autorelease_pool_get_current(), anObject);
}

- (void)addObject:(id)anObject {
    autorelease_pool_add_object(pool, anObject);
}

- (void)drain {
    autorelease_pool_release_objects(pool);
}

- (oneway void)release {
    [self drain];
}

- (oneway void)_release {
    [super release];
}

- (void)dealloc {
    autorelease_pool_pop(pool);
    [super dealloc];
}

- (instancetype)retain {
    [NSException raise:NSGenericException
                format:@"retain sent to AutoreleasePool"];
    return nil;
}

- (instancetype)autorelease {
    [NSException raise:NSGenericException
                format:@"autorelease sent to AutoreleasePool"];
    return nil;
}

@end
