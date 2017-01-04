//
//  BZScope.h
//  GithubClient
//
//  Created by User on 10.03.16.
//  Copyright © 2016 BZ. All rights reserved.
//

#define weakify(var) __weak typeof(var) AHKWeak_##var = var;

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = AHKWeak_##var; \
_Pragma("clang diagnostic pop")
