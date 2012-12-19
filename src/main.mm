#include "ofMain.h"
#include "testApp.h"

int main(){
    
    ofAppiPhoneWindow * iOSWindow = new ofAppiPhoneWindow();
    iOSWindow->enableRetinaSupport();
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    iOSWindow->enableRetinaSupport();
    
    ofSetupOpenGL(iOSWindow, 480, 320, OF_FULLSCREEN);
	//ofSetupOpenGL(1024,768, OF_FULLSCREEN);			// <-------- setup the GL context

	ofRunApp(new testApp);
}
