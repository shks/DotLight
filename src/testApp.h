#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

//ofkTools
#include "ofkMultiTouchEvent.h"

//Addons
#include "ofxUI.h"



#define SANDRES (5)

class testApp : public ofxiPhoneApp{
	
    public:
        void setup();
        void update();
        void draw();
        void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);

        void touchTwoFinger ( ofkMultiTouchEventArgs &touch );
        ofkMultiTouchEvent multiTouchEvent;    
    
    // -------------------------- //

    //static const int NUM_PARTICLES = 960 * 640 ;
    static const int NUM_PARTICLES = 960 / SANDRES * 640 / SANDRES ;
    
    
    ofEasyCam cam; // camera
    ofVbo myVbo; // VBO
    ofVec3f myVerts[NUM_PARTICLES];
    ofFloatColor myColor[NUM_PARTICLES];
    
    bool isTouched;
    ofPoint mTouchPos;
    ofPoint mTouchPosEx;
    
    ofPoint mTouchDownPos;
    
    
    float mHuePos;
    float mHueScale;
    
    float mPointSize;
    float mPointIntervalRate;
    float mPointBrightNess;
    bool mIsSmoothPoint;
    
    
    ///
    //Main
    ofxUICanvas *guiCanvas;
    ofxUILabel *label;
    
    void initGUILayout();
    void guiEvent(ofxUIEventArgs &e);
    
};


