#include <stdlib.h>
#include <Cocoa/Cocoa.h>
#include <unistd.h>

inline int min(int a, int b);
inline int max(int a, int b);

void fatalError(NSString* string);

BOOL isPropertyList(NSString* path);