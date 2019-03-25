// conditional casting if object corresponds to ClassType
// TCN_CAST_OR_NIL([userInfo valueForKey:kLINETSessionControllerEventType], NSString)
#define TCN_CAST_OR_NIL(Object, ClassType)  \
({                                                   \
id obj = Object;                                     \
bool isKind = [obj isKindOfClass:[ClassType class]]; \
isKind ? (ClassType *)obj : nil;                     \
})

// macro for casting a nullable variable to its nonnull equivalent, once its nil-ness has already been checked
#define TCN_FORCE_UNWRAP(Variable) ({ __auto_type _Nonnull nonnull_Variable = Variable; nonnull_Variable; })

// logs an error and asserts if in debug mode
#ifdef DEBUG
#define TCN_ASSERT_FAILURE(FORMAT, ...) \
raise(SIGABRT); \
NSLog(FORMAT, ##__VA_ARGS__);
#else
#define TCN_ASSERT_FAILURE(FORMAT, ...) \
NSLog(FORMAT, ##__VA_ARGS__);
#endif
