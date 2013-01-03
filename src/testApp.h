#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

//ofkTools
#include "ofkMultiTouchEvent.h"

//Addons
#include "ofxUI.h"
#include "ofxTweener.h"

#define SANDRES (6)
#define POINT_MAXSIZE (8.00)

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

    static const int DOT_HORIZONAL_NUM = 640 / SANDRES / 2 * 1.2;  //touch reaction Buffer
    static const int DOT_VERTICAL_NUM = 1136 / SANDRES * 1.2;   //touch reaction Buffer
    
    ofEasyCam cam; // camera
    ofVbo myVbo; // VBO
    ofVec3f myVerts[DOT_HORIZONAL_NUM * DOT_VERTICAL_NUM];
    ofFloatColor myColor[DOT_HORIZONAL_NUM * DOT_VERTICAL_NUM];
    float myVectors[DOT_HORIZONAL_NUM * DOT_VERTICAL_NUM];
    float myForces[DOT_HORIZONAL_NUM * DOT_VERTICAL_NUM];
    
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
    bool mIsSpace;
    
    void guiEvent(ofxUIEventArgs &e);
    
    
private:
    
    void initGUILayout();
    ofxUICanvas *guiCanvas;
    ofxUILabel *label;
    
    enum WidgetState
    {
        WidgetOpened,
        WidgetClosed
    };
    
    WidgetState mWidgetState;
    float mGUISlidePos;             //結局の制御ターゲットはこの変数

    bool isGUIWidgetActive();
    void changeWidgetState( WidgetState nextState );
    
};


