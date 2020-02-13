//
//  autorelease_pool_stack.c
//  HRAutoreleasePool
//
//  Created by Dmitry Rykun on 2/13/20.
//  Copyright © 2020 Dmitry Rykun. All rights reserved.
//

#include "autorelease_pool_stack.h"

autorelease_pool_stack *autorelease_pool_stack_create() {
    autorelease_pool_stack *stack = (autorelease_pool_stack *)malloc(sizeof(autorelease_pool_stack));
    stack->current = -1;
    memset(stack->pools, (int)NULL, AUTORELEASE_POOL_STACK_SIZE);
    return stack;
}

void autorelease_pool_stack_delete(autorelease_pool_stack *stack) {
    free(stack);
}

void autorelease_pool_stack_push_autorelease_pool(autorelease_pool_stack *stack, autorelease_pool* pool) {
    assert(stack->current + 1 < AUTORELEASE_POOL_STACK_SIZE);
    stack->current += 1;
    stack->pools[stack->current] = pool;
}

autorelease_pool* autorelease_pool_stack_pop_autorelease_pool(autorelease_pool_stack *stack) {
    assert(stack->current >= 0);
    autorelease_pool *pool = stack->pools[stack->current];
    stack->pools[stack->current] = NULL;
    stack->current -= 1;
    return pool;
}

autorelease_pool* autorelease_pool_stack_get_topmost_autorelease_pool(autorelease_pool_stack *stack) {
    if (stack->current < 0) {
        return NULL;
    }
    return stack->pools[stack->current];
}
