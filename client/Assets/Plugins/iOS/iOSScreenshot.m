//
//  iOSScreenshot.m
//  
//
//  Created by xl.s on 01/23/2016.
//
//

bool saveToGallery( const char * path )
{
	NSString *imagePath = [NSString stringWithUTF8String:path];
	
    NSLog(@"###### This is the file path being passed: %@", imagePath);
    
	if( ![[NSFileManager defaultManager] fileExistsAtPath:imagePath] ) {
        NSLog(@"###### Early exit - file doesn't exist");
        return false;
    }
    
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	
	if( image ) {
        NSLog(@"###### Trying to write image");
		UIImageWriteToSavedPhotosAlbum( image, nil, NULL, NULL );
        return true;
    }
    
    return false;
}
