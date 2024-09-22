#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <objc/runtime.h>
#include <substrate.h>
#import "CCEControlViewController.h"

namespace cce_UIScene {
    namespace _sceneForFBSScene_create_withSession_connectionOptions {
        void *key = &key;
        __kindof UIScene * (*original)(Class, SEL, id, BOOL, id, id);
        __kindof UIScene * custom(Class cls, SEL _cmd, id fbScene, BOOL create, id session, id connectionOptions) {
            UIWindowScene *windowScene = original(cls, _cmd, fbScene, create, session, connectionOptions);
            
            if ([windowScene isKindOfClass:objc_lookUpClass("SBSystemApertureWindowScene")]) {
                UIWindow *window = ((id (*)(id, SEL, id))objc_msgSend)([objc_lookUpClass("SBFSecureTouchPassThroughWindow") alloc], @selector(initWithWindowScene:), windowScene);
                CCEControlViewController *rootViewController = [CCEControlViewController new];
                window.rootViewController = rootViewController;
                [rootViewController release];
                [window makeKeyAndVisible];
                objc_setAssociatedObject(windowScene, key, window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                [window release];
            }
            
            return windowScene;
        }
        void hook() {
            // MSHookMessageEx(
            //     [UIScene class],
            //     sel_registerName("_sceneForFBSScene:create:withSession:connectionOptions:"),
            //     reinterpret_cast<IMP>(&custom),
            //     reinterpret_cast<IMP *>(&original)
            // );
            Method method = class_getClassMethod([UIScene class], sel_registerName("_sceneForFBSScene:create:withSession:connectionOptions:"));
            original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
            method_setImplementation(method, reinterpret_cast<IMP>(&custom));
        }
    }
}

// +[SBCaptureHardwareButton simulateCaptureButtonWithActionButton]
// +[SBCaptureHardwareButton deviceSupportsCaptureButton]
// -[SpringBoard captureHardwareButton]
// MGGetBoolAnswer @"CameraButtonCapability"
// SBCaptureButtonSuppressionManager
// _OBJC_IVAR_$_SpringBoard._captureButtonSuppressionManager
// -[SBVolumeHardwareButton volumeIncreasePress:]
// -[SBCaptureHardwareButton _handleButtonUpAtTimestamp:forDownTimestamp:]
// /System/Library/PrivateFrameworks/CameraOverlayServices.framework/CameraOverlayServices 
namespace cce_SBCaptureHardwareButton {
    namespace deviceSupportsCaptureButton {
        BOOL (*original)();
        BOOL custom() {
            // return original();
            // return original();
            return YES;
        }
        void hook() {
            MSImageRef image = MSGetImageByName("/System/Library/PrivateFrameworks/SpringBoard.framework/SpringBoard");
            void *symbol = MSFindSymbol(image, "+[SBCaptureHardwareButton deviceSupportsCaptureButton]");
            MSHookFunction(symbol, reinterpret_cast<void *>(&custom), reinterpret_cast<void **>(&original));
        }
    }
}

__attribute__((constructor)) static void init() {
    cce_SBCaptureHardwareButton::deviceSupportsCaptureButton::hook();
    cce_UIScene::_sceneForFBSScene_create_withSession_connectionOptions::hook();
}