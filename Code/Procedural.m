#include "Procedural.h"

BOOL isPropertyList(NSString* path) {
    NSFileHandle* handle=[NSFileHandle fileHandleForReadingAtPath:path];
    int descriptor;
    char buff[6]={0};
    if (! handle) return NO;
    descriptor=[handle fileDescriptor];
    if (! descriptor) return NO;
    if (read(descriptor, buff, 5) != 5) return NO;
    return !strcmp(buff, "<?xml");
}