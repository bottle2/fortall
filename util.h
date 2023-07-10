#ifndef UTIL_H
#define UTIL_H

#include <assert.h>
#include <stdarg.h>
#include <stdio.h>

// Inline string formatting.
// TODO Document better.
static inline char *util_ifmt(char fmt[static 1], ...)
{
    static _Thread_local char string[80];
    va_list ap;
    va_start(ap, fmt);

    int code = vsnprintf(string, 80, fmt, ap);

    va_end(ap);

    assert(code >= 0);

    if (code >= 80)
    {
        string[76] = string[77] = string[78] = '.';
        string[79] = '\n';
    }

    return string;
}

#endif
