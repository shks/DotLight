#include "testApp.h"

#define BUFSIZE (9216 * 4)
#define DISP_RATIO ((ofGetWidth() / 768.0))

#define WIDGET_OPENED_POSX (0)
#define WIDGET_CLOSED_POSX ( - ofGetWidth() * 0.7)

//--------------------------------------------------------------
void testApp::setup(){	
	// initialize the accelerometer
	ofxAccelerometer.setup();
	//iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
	
	ofBackground(0,0,0);
    ofBackgroundHex(0x000000);
    
    initGUILayout();

    int WIDTH = DOT_HORIZONAL_NUM;
    int HEIGHT = DOT_VERTICAL_NUM;
    for (int i = 0; i < WIDTH; i++) {
        for (int j = 0; j < HEIGHT; j++) {
            myVerts[j * WIDTH + i].set(i * SANDRES, (j - HEIGHT/2) * SANDRES, 0);
            
            myVectors[j * WIDTH + i] = 0.0;
            myForces[j * WIDTH + i] = 0.0f;
            
            ofColor col;
            col.setHsb(255.0 * ( mHuePos + (float)j / (float)HEIGHT * 0.2 ) , 255.0 * 0.5, 255.0 * 0.7);
            
            float a = ((j + i) % 2 == 0) ? 1.0 : 0.0;
            myColor[j * WIDTH + i].set(col.r / 255.5, col.g / 255.5, col.b / 255.5, a);
        }
    }
    
    int NUM_PARTICLES = DOT_HORIZONAL_NUM * DOT_VERTICAL_NUM;
    myVbo.setVertexData(myVerts, NUM_PARTICLES, GL_DYNAMIC_DRAW);
    myVbo.setColorData(myColor, NUM_PARTICLES, GL_DYNAMIC_DRAW);
    
    mPointIntervalRate = 1.0;
    mPointSize = 2.0;
    mIsSmoothPoint = true;
    mHuePos = 0.0;
    mHueScale = 6.0;
    mPointBrightNess = 0.9;
    
    mIsSpace = true;

    //multiTouch Enable
    multiTouchEvent.enable();
    ofAddListener(multiTouchEvent.touchTwoFingerEvent, this, &testApp::touchTwoFinger);
}

//--------------------------------------------------------------
void testApp::update(){
    
    const static float springK = 1.4;
    const static float DumperK = -0.1;
    
    int WIDTH = DOT_HORIZONAL_NUM;
    int HEIGHT = DOT_VERTICAL_NUM;
    
    for (int i = 0; i < WIDTH; i++) {
        for (int j = 0; j < HEIGHT; j++) {
            int index = j * WIDTH + i;

            if(j % 2 == 0)
            {
                //even
                myVerts[index].x = 2 * i * SANDRES * mPointIntervalRate;
                myVerts[index].y = (1 * j) * SANDRES * mPointIntervalRate;
                myVerts[index].z += 0.05 * myVectors[index];

            }else
            {
                //odd
                myVerts[index].x = (2 * i + 1) * SANDRES * mPointIntervalRate;
                myVerts[index].y = (1 * j) * SANDRES * mPointIntervalRate;
                myVerts[index].z += 0.05 * myVectors[index];
            }
            
            myForces[index] = springK * (0 - myVerts[index].z) + DumperK * myVectors[index];
            myVectors[index] += myForces[index];
            
            /// ----------- COLOR ------------- //
            
            float sat = 0.5;//
            float bri = 1.0;//

            ofColor col;
            //TODO
            int HUE = (int)(255.0 * ( mHuePos + (float)j / ((float)HEIGHT * mHueScale ) ));
            
            while (HUE < 0) {
                HUE += 255;
            }
            
            HUE = HUE % 255;
            col.setHsb(HUE , 255.0 * sat, 255.0 * bri);
            
            float a = mPointBrightNess;
            
            myColor[j * WIDTH + i].set(col.r / 255.5, col.g / 255.5, col.b / 255.5, a);
            
            // touch なにかする？
            if(isTouched && !isGUIWidgetActive())
            {
                 float targetZ = ((myVerts[index].x - mTouchPos.x) * (myVerts[index].x - mTouchPos.x)
                                           +
                                           (myVerts[index].y - mTouchPos.y) * (myVerts[index].y - mTouchPos.y)
                                           );
                
                targetZ = 500*exp(-0.00005 * targetZ);
                
                myVerts[index].z += ( targetZ - myVerts[index].z) * 0.5;
            }
        }
    }
    int NUM_PARTICLES = DOT_HORIZONAL_NUM * DOT_VERTICAL_NUM;
    myVbo.updateVertexData(myVerts, NUM_PARTICLES);
    myVbo.updateColorData(myColor, NUM_PARTICLES);
    
    Tweener.update();
}

//--------------------------------------------------------------
void testApp::draw(){
	//rendering here something..
    
    ofPushMatrix();
    
    glTranslatef(-640 * 0.1, - 1136 * 0.1, 0);
    
    if(mIsSmoothPoint)
    {
        glEnable(GL_POINT_SMOOTH);
    }else
    {
        glDisable(GL_POINT_SMOOTH);
    }
    
    ofEnableBlendMode(OF_BLENDMODE_ADD);
    static GLfloat distance[] = { 0.0, 0.0, 0.0001 };
    glPointParameterfv(GL_POINT_DISTANCE_ATTENUATION, distance);
    glPointSize(20 * mPointSize * mPointIntervalRate);
    myVbo.draw(GL_POINTS, 0, DOT_HORIZONAL_NUM * DOT_VERTICAL_NUM);
    ofPopMatrix();
    
    ofSetColor(255, 255, 255);
    
    ofSetupScreen();
    
    ofTranslate(mGUISlidePos, 0);
}

//--------------------------------------------------------------
void testApp::exit(){

}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){

    isTouched = true;

    mTouchPos.x = touch.x * 1;
    mTouchPos.y = touch.y * 1;// -ofGetHeight() * 1.0;

    mTouchPosEx = mTouchDownPos = mTouchPos;
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){
        
    if(touch.numTouches != 1)
        return;
    
    mTouchPos.x = touch.x * 1;
    mTouchPos.y = touch.y * 1;// -ofGetHeight() * 1.0;
    mHuePos += (mTouchPos.y - mTouchPosEx.y) * -0.001;
    
    //-----Widgetz 初期の動きFBを付けること。
    if( abs(mTouchDownPos.x - mTouchPos.x) >  2 * abs(mTouchDownPos.y - mTouchPos.y))
    {
        //横方向への移動が支配的の時、
        
        if(mTouchPos.x - mTouchDownPos.x > 0)
        {
            //右方向へのDrag
                    
            if( mTouchPos.x - mTouchDownPos.x > ofGetWidth() * 0.33)
            {
                //OPEN
                changeWidgetState(WidgetOpened);
                
            }else if( mTouchPos.x - mTouchDownPos.x > ofGetWidth() * 0.20)
            {
                mGUISlidePos += (mTouchPos.x - mTouchPosEx.x) * 0.5;
            }
            
        }else
        {
            //左方向へのDrag
            if(mTouchPos.x - mTouchDownPos.x < - ofGetWidth() * 0.33)
            {
                //CLOSE
                changeWidgetState(WidgetClosed);
            }else if( mTouchPos.x - mTouchDownPos.x < - ofGetWidth() * 0.20)
            {
                mGUISlidePos += (mTouchPos.x - mTouchPosEx.x) * 0.5;
            }
            
            
        }
    }
    
    /////
    mTouchPosEx = mTouchPos;
    
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    
    isTouched = false;
    mTouchPos.x = touch.x * 1;
    mTouchPos.y = touch.y * 1;// -ofGetHeight() * 1.0;
    
    //吸着させる。
    changeWidgetState(mWidgetState);
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){

    static bool isshow = false;
    guiCanvas->setVisible(isshow);
    isshow = !isshow;
}


//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch){
    
}

void testApp :: touchTwoFinger ( ofkMultiTouchEventArgs &multiTouch )
{
    //Check GUI Widget
    if(isGUIWidgetActive())
        return;
    
    if(abs(multiTouch.angleDif) > 2.0)
    {
        //ROTATE
        
        mPointSize += multiTouch.angleDif * -0.1;
        
        if(mPointSize < 0.5)
        {
            mPointSize = 0.5;
        }
        
        if(mPointSize > 3.3)
        {
            mPointSize = 3.3;
        }
        
    }else{
        //PINCH
        mPointIntervalRate += multiTouch.pinchLengthDif * 0.01;
        
        if(mPointIntervalRate <1.0)
        {
            mPointIntervalRate = 1.0;
        }
    }

}

//--------------------------------------------------------------
void testApp::lostFocus(){

}

//--------------------------------------------------------------
void testApp::gotFocus(){

}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){

}


void testApp::initGUILayout()
{
    float WidgetWidth = ofGetWidth() * 0.7;
    int xInit = OFX_UI_GLOBAL_WIDGET_SPACING;
    int FONT_LARGE = (int) 30 * DISP_RATIO;
    int FONT_MID= (int) 25 * DISP_RATIO;
    int FONT_SMALL= (int) 20 * DISP_RATIO;
    int dim =  70;
    float length = WidgetWidth - xInit;
    
    //-guiHeader-----------------------------------------------------------//
    
    float guiHeaderHEIGHT = 2.0;
    
    guiCanvas = new ofxUICanvas(0,0 ,WidgetWidth,ofGetHeight() * guiHeaderHEIGHT);
    
    //guiCanvas->setTheme(OFX_UI_THEME_HACKER);
    
    ofColor cb = ofColor( 0*255.0, 0*255.0, 0*255.0, 0.7*255.0 );
     ofColor co = ofColor( 0.254902*255.0, 0.239216*255.0, 0.239216*255.0, 0.392157*255.0 );
     ofColor coh = ofColor( 0.294118*255.0, 0*255.0, 0.0588235*255.0, 0.784314*255.0 );
     ofColor cf = ofColor( 0.784314*255.0, 1*255.0, 0*255.0, 0.784314*255.0 );
     ofColor cfh = ofColor( 0.980392*255.0, 0.00784314*255.0, 0.235294*255.0, 1*255.0 );
     ofColor cp = ofColor( 0.0156863*255.0, 0*255.0, 0.0156863*255.0, 0.392157*255.0 );
     ofColor cpo = ofColor( 0.254902*255.0, 0.239216*255.0, 0.239216*255.0, 0.784314*255.0 );
     guiCanvas->setUIColors( cb, co, coh, cf, cfh, cp, cpo );
     
    guiCanvas->setFont("Roboto-Light.ttf");
    guiCanvas->setFontSize(OFX_UI_FONT_LARGE , FONT_LARGE);
    guiCanvas->setFontSize(OFX_UI_FONT_MEDIUM , FONT_MID);
    guiCanvas->setFontSize(OFX_UI_FONT_SMALL , FONT_SMALL);
    
    /*
    {
        guiCanvas->addFPSSlider("FPS", length-xInit, 50);
        guiCanvas->addWidgetDown(new ofxUILabel("Dot Light Debug", OFX_UI_FONT_LARGE));
        guiCanvas->addWidgetDown(new ofxUILabel("Double Tap to Swicth Debug", OFX_UI_FONT_LARGE));
        //guiCanvas->addWidgetDown(new ofxUIFPSSlider("FPS", ofGetWidth() - 2 * xInit, 50,15));
        guiCanvas->addWidgetDown(new ofxUISpacer(length-xInit, 1));
        
        guiCanvas->addSlider("POINT_SIZE", 1.0, 10.0, &mPointSize, length-xInit, 60);
        guiCanvas->addSlider("POINT_INTERVAL", 1.0, 10.0, &mPointIntervalRate, length-xInit, 60);
        guiCanvas->addSlider("POINT_BrightNess", 0.1, 1.0, &mPointBrightNess, length-xInit, 60);
        
        guiCanvas->addToggle("POINT_SMOOTH", &mIsSmoothPoint, dim, 60);
        
        guiCanvas->addWidgetDown(new ofxUISpacer(length-xInit, 1));

        guiCanvas->addSlider("HUE", 1.0, 10.0, &mHuePos, length-xInit, 60);
        guiCanvas->addSlider("HUE_SCALE", 1.0, 10.0, &mHueScale, length-xInit, 60);
    
    }
     */
    
    {

        guiCanvas->addWidgetDown(new ofxUILabel("DotLight Settings", OFX_UI_FONT_LARGE));

        guiCanvas->addSpacer(length-xInit, 100)->setVisible(false);
        guiCanvas->addSpacer(length-xInit, 1)->setVisible(true);
        
        guiCanvas->addWidgetDown(new ofxUILabel("Dot Size", OFX_UI_FONT_MEDIUM));
        ofxUISlider *pSlider = new ofxUISlider(length-xInit, 60, 0.5, 3.3, &mPointSize, "");
        pSlider->getLabel()->setVisible(false);
        guiCanvas->addWidgetDown(pSlider);
        
        guiCanvas->addWidgetDown(new ofxUILabel("Dot Interval", OFX_UI_FONT_MEDIUM));
        pSlider = new ofxUISlider(length-xInit, 60, 1.0, 10.0, &mPointIntervalRate, "");
        pSlider->getLabel()->setVisible(false);
        guiCanvas->addWidgetDown(pSlider);

        guiCanvas->addWidgetDown(new ofxUILabel("Brightness", OFX_UI_FONT_MEDIUM));
        pSlider = new ofxUISlider(length-xInit, 60, 0.1, 1.0, &mPointBrightNess, "");
        pSlider->getLabel()->setVisible(false);
        guiCanvas->addWidgetDown(pSlider);
        
        guiCanvas->addWidgetDown(new ofxUISpacer(length-xInit, 1));
    }
    
    ofAddListener(guiCanvas->newGUIEvent, this, &testApp::guiEvent);
    
    
    // ----------- Widget State Init -------//
    
    mWidgetState = WidgetClosed;
    mGUISlidePos = WIDGET_CLOSED_POSX;
}

void testApp::guiEvent(ofxUIEventArgs &e)
{
    /*
    bool SyncEvent = false;
    
    if(e.widget->getName() == "BEST")
    {
		ofxUIButton *button = (ofxUIButton *) e.widget;
        if(button->getValue())
        {
            mUDPjpegStream.setjpegQuality(OF_IMAGE_QUALITY_BEST);
        }
    }
    else if(e.widget->getName() == "HIGH")
    {
		ofxUIButton *button = (ofxUIButton *) e.widget;
        if(button->getValue())
        {
            mUDPjpegStream.setjpegQuality(OF_IMAGE_QUALITY_HIGH);
        }
    }
    else if(e.widget->getName() == "MEDIUM")
    {
		ofxUIButton *button = (ofxUIButton *) e.widget;
        if(button->getValue())
        {
            mUDPjpegStream.setjpegQuality(OF_IMAGE_QUALITY_MEDIUM);
        }
    }
    else if(e.widget->getName() == "LOW")
    {
		ofxUIButton *button = (ofxUIButton *) e.widget;
        if(button->getValue())
        {
            mUDPjpegStream.setjpegQuality(OF_IMAGE_QUALITY_LOW);
        }
    }
    else if(e.widget->getName() == "WORST")
    {
		ofxUIButton *button = (ofxUIButton *) e.widget;
        if(button->getValue())
        {
            mUDPjpegStream.setjpegQuality(OF_IMAGE_QUALITY_WORST);
        }
    }
     */
}

bool testApp::isGUIWidgetActive()
{
    bool res = false;
    
    if(WIDGET_OPENED_POSX == mWidgetState)
    {
        if( abs( WIDGET_OPENED_POSX - mGUISlidePos ) < 2.0 )
        {
            res = true;
        }
    }
    return res;
}

void testApp::changeWidgetState( WidgetState nextState)
{
    //アニメーション追加する；
    if(true)//s mWidgetState != nextState)
    {
        if(WidgetOpened == nextState)
        {
            Tweener.addTween(mGUISlidePos, WIDGET_OPENED_POSX, 0.2, &ofxTransitions::easeOutQuint);
            //guiCanvas->setState(int _state);
            
        }else if (WidgetClosed == nextState)
        {
            Tweener.addTween(mGUISlidePos, WIDGET_CLOSED_POSX, 0.2, &ofxTransitions::easeOutQuint);
        }
        
        mWidgetState = nextState;
    }
}

