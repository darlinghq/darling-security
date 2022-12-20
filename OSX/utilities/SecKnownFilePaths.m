
#import <Foundation/Foundation.h>
#import "SecKnownFilePaths.h"
#import "OSX/utilities/SecCFRelease.h"

// This file is separate from SecFileLocation.c because it has a global variable.
// We need exactly one of those per address space, so it needs to live in the Security framework.
static CFURLRef sCustomHomeURL = NULL;

CFURLRef SecCopyHomeURL(void)
{
    // This returns a CFURLRef so that it can be passed as the second parameter
    // to CFURLCreateCopyAppendingPathComponent

    CFURLRef homeURL = sCustomHomeURL;
    if (homeURL) {
        CFRetain(homeURL);
    } else {
#ifdef DARLING
        // ported from an older version of Security
        //
        // i'm not sure how Apple is convincing the compiler that CFCopyHomeDirectoryURL is available on macOS
        // because there's nothing new in the public headers to indicate that the function has suddenly become
        // available on macOS, nor is there any indication in the Xcode build files that this code is being
        // compiled for Catalyst for macOS
        //
        // maybe they're just not using compiler availability warnings/errors
        //
        // either way, this should work fine and provide the same behavior as Apple's code
        homeURL = CFCopyHomeDirectoryURLForUser(NULL);
#else
        homeURL = CFCopyHomeDirectoryURL();
#endif
    }

    return homeURL;
}

CFURLRef SecCopyBaseFilesURL(bool system)
{
    CFURLRef baseURL = sCustomHomeURL;
    if (baseURL) {
        CFRetain(baseURL);
    } else {
#if TARGET_OS_OSX
        if (system) {
            baseURL = CFURLCreateWithFileSystemPath(NULL, CFSTR("/"), kCFURLPOSIXPathStyle, true);
        } else {
            baseURL = SecCopyHomeURL();
        }
#elif TARGET_OS_SIMULATOR
        baseURL = SecCopyHomeURL();
#else
        baseURL = CFURLCreateWithFileSystemPath(NULL, CFSTR("/"), kCFURLPOSIXPathStyle, true);
#endif
    }
    return baseURL;
}

void SecSetCustomHomeURL(CFURLRef url)
{
    sCustomHomeURL = CFRetainSafe(url);
}

void SecSetCustomHomeURLString(CFStringRef home_path)
{
    CFReleaseNull(sCustomHomeURL);
    if (home_path) {
        sCustomHomeURL = CFURLCreateWithFileSystemPath(NULL, home_path, kCFURLPOSIXPathStyle, true);
    }
}
