//
//  iOSUtilityImpl.m
//  BaoyugameSdk
//
//  Created by Mac-baoyu on 13-10-26.
//  Copyright (c) 2013年 Mac-baoyu. All rights reserved.
//
#include "iOSGlobalUserData.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <AdSupport/AdSupport.h>
extern "C"
{
    void _XcodeLog ( const char * message )
    {
        NSString * str = [[NSString alloc] initWithUTF8String:message];
        NSLog(@"%@",str);
#if !__has_feature(objc_arc)
        [str release];
#endif
    }
    
    unsigned int _GetFreeMemory ( )
    {
        mach_port_t host_port;
        mach_msg_type_number_t host_size;
        vm_size_t pagesize;
        
        host_port = mach_host_self();
        host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
        host_page_size(host_port, &pagesize);
        
        vm_statistics_data_t vm_stat;
        
        if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        {
            NSLog(@"Failed to fetch vm statistics");
            return 0L;
        }
        
        natural_t mem_free = (vm_stat.free_count + vm_stat.inactive_count) * pagesize;
        return mem_free>>10;
    }
    
    //KB
    unsigned int _GetTotalMemory ( )
    {
        return (unsigned int)([[NSProcessInfo processInfo] physicalMemory]>>10);
    }
    
    float _GetTotalDiskSpaceInBytes ( )
    {
        /*
        float totalSpace = 0.0f;
        NSError *error = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
        
        if (dictionary) {
            NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
            totalSpace = [fileSystemSizeInBytes floatValue];
        } else {
            NSLog(@"Error Obtaining File System Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
        }
        return totalSpace;
         */
        return [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] floatValue];
    }
    
    float _GetFreeDiskSpaceInBytes ( )
    {
        /*
        float totalSpace = 0.0f;
        NSError *error = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
        
        if (dictionary) {
            NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemFreeSize];
            totalSpace = [fileSystemSizeInBytes floatValue];
        } else {
            NSLog(@"Error Obtaining File System Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
        }
        
        return totalSpace;
         */
        return [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] floatValue];
    }
    
    bool _IsBattleCharging( )
    {
        return [iOSGlobalUserData isBatteryCharging];
    }
    
    float _GetBatteryLevel( )
    {
        return [iOSGlobalUserData batteryLevel];
    }
    
    float _GetBrightness()
    {
        return [iOSGlobalUserData getBrightness];
    }
    
    void _SetBrightness(float brightness)
    {
        [iOSGlobalUserData setBrightness:brightness];
    }
    
    char* _GetBundleId()
    {
        NSString *bundleIdentifier = [[NSBundle mainBundle]bundleIdentifier];
        const char *string = [bundleIdentifier UTF8String];
        char* res = (char*)malloc(strlen(string) + 1);
        strcpy(res, string);
        return res;
    }

    void _ExcludeFromBackupUrl( const char * url )
    {
        
        NSString * excludeUrl = [[NSString alloc] initWithUTF8String:url];
        [iOSGlobalUserData addSkipBackupAttributeToFileAtPath:excludeUrl];
    }

    char * _GetAdId()
    {
        NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        NSLog(@"_GetAdId=%@", adId);
        const char *string = [adId UTF8String];
        char* res = (char*)malloc(strlen(string) + 1);
        strcpy(res, string);
        return res;
    }
    
    char * _GetIdfv()
    {
        NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSLog(@"_GetIdfv=%@", idfv);
        const char *string = [idfv UTF8String];
        char* res = (char*)malloc(strlen(string) + 1);
        strcpy(res, string);
        return res;
    }
    
    // 干扰打包临时屏蔽以下代码
    void _SaveKeychainData(const char *key,const char *data)
    {
        // NSString *keystr = [[NSString alloc] initWithUTF8String:key];
        // NSString *datastr = [[NSString alloc] initWithUTF8String:data];
        // [LRKeychain addKeychainData:datastr forKey:keystr];
    }
    
    char* _GetKeychainData(const char *key)
    {
        // NSString *keystr = [[NSString alloc] initWithUTF8String:key];
        // id ret = [LRKeychain getKeychainDataForKey:keystr];
        // if(ret)
        // {
        //     const char *string = [[NSString stringWithFormat:@"%@",ret] UTF8String];
        //     char * res = (char*)malloc(strlen(string)+1);
        //     strcat(res, string);
        //     return res;
        // }
        return nil;
    }
}