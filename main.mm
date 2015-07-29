#include <unistd.h>
#include <stdio.h>
#include <errno.h>

int main(int argc, char **argv, char **envp) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:@"/usr/bin/cycript"]) {
        if (argc == 1) {
            printf("Usage: screenshot img.jpg\n");
            return 1;
        }
        else if(argc > 2) {
            printf("screenshot only uses one argument\n");
            return 1;
        }
        NSArray *folders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/mobile/Media/DCIM" error:nil];
        //get most recent folder
        NSString *mostrecentfolder = [NSString stringWithFormat:@"/var/mobile/Media/DCIM/%@",[folders objectAtIndex:[folders count] -1]];
        NSArray *filesinfolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mostrecentfolder error:nil];
        int precount = [filesinfolder count];
        //mute and take screenshot. piping directly to cycript doesnt work every time, save cycript script to file
        system([@"echo 'backup = SBHUDController.messages[\"presentHUDView:autoDismissWithDelay:\"];SBHUDController.messages[\"presentHUDView:autoDismissWithDelay:\"] = function() {return null;};[[VolumeControl sharedVolumeControl]toggleMute];[[SBScreenShotter sharedInstance]saveScreenshot:0]' >/tmp/.system; cycript -p SpringBoard /tmp/.system >/dev/null;rm /tmp/.system" UTF8String]);
        //check for new files
        NSString *savethisfile;
        while (1) {
            NSArray *newfiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:mostrecentfolder error:nil];
            if ([newfiles count] != precount) {
                savethisfile = [NSString stringWithFormat:@"%@/%@",mostrecentfolder,[newfiles objectAtIndex:[newfiles count] -1]];
                NSData *filedata = [[NSFileManager defaultManager] contentsAtPath:savethisfile];
                [filedata writeToFile:[NSString stringWithFormat:@"%s",argv[1]] atomically:YES];
                char cwd[1024];
                if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%s",argv[1]]]) {
                    printf("%s",[[NSString stringWithFormat:@"screenshot saved to %s/%s\n",cwd,argv[1]] UTF8String]);
                }
                break;
            }
            [NSThread sleepForTimeInterval:0.2];
        }
        //restore HUD
        system([@"echo '[[VolumeControl sharedVolumeControl]toggleMute];' >/tmp/.system; cycript -p SpringBoard /tmp/.system >/dev/null 2>&1;rm /tmp/.system;echo 'SBHUDController.messages[\"presentHUDView:autoDismissWithDelay:\"] = backup;' | cycript -c >/tmp/.system; cycript -p SpringBoard /tmp/.system >/dev/null 2>&1;rm /tmp/.system" UTF8String]);
    }
    else {
        printf("Requires Cycript, please install with cydia ");
    }
	return 0;
}

// vim:ft=objc
