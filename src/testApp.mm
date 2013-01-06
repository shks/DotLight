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
    
    
    
    //Splash Image
    float Delaytime = 1.2;
    if(ofGetHeight() == 960)
    {
        mSplashImage.setImageFile("Default@2x.png");
        Delaytime = 1.0;
    }
    else if(ofGetHeight() == 1136)
    {
        mSplashImage.setImageFile("Default-568h@2x.png");
        Delaytime = 1.5;
    }
    else if(ofGetHeight() == 480)
    {
        mSplashImage.setImageFile("Default.png");
        Delaytime = 0.2;
    }
    
    mSplashImage.useImageSize();
    mSplashImage.x = ofGetWidth() / 2.0;
    mSplashImage.y = ofGetHeight() / 2.0;
    mSplashImage.a = 1.0;
    
    Tweener.addTween(mSplashImage.a, 0.0, 1.0, &ofxTransitions::easeOutQuint, Delaytime);
    
    
    
    
    //mHelpImage
    
    if(ofGetHeight() == 960)
    {
        mHelpImage.setImageFile("help@2x.png");
    }
    else if(ofGetHeight() == 1136)
    {
        mHelpImage.setImageFile("help-568h@2x.png");
    }
    else if(ofGetHeight() == 480)
    {
        mHelpImage.setImageFile("help.png");
    }
    
    mHelpImage.useImageSize();
    mHelpImage.x = ofGetWidth() / 2.0;
    mHelpImage.y = ofGetHeight() / 2.0;
    mHelpImage.a = 0.0;
    
    
    /// -------------- XML Properties  ------------- --------------　 --------------//
    ofkXMLProperties::setXMLFile("mySettings.xml");
    int lastOpenedDay = ofkXMLProperties::getPropertyValue("SETTINGS::LastOpenDateDay", -1);
    
    //cout << "=--------- lastOpenedMonth" << lastOpenedDay << endl;
    //cout << "=--------- lastOpenedSecond" << lastOpenedSEC << endl;

    //NumOpenedEver
    bool isShowHint = false;
    int NumOpenedEver = ofkXMLProperties::getPropertyValue("SETTINGS::NumOpenedEver", -1);
    if(NumOpenedEver == 0 )
    {
        //cout << "=--------- This is first Time Open " << NumOpenedEver << endl;
        isShowHint = true;
        
    }else if( abs(ofGetDay() - lastOpenedDay) > 6 )
    {
        //cout << "=--------- Open in different Week " << lastOpenedDay << endl;
        isShowHint = true;
    }
    
    if(isShowHint)
    {
        Tweener.addTween(mHelpImage.a, 1.0, 1.0, &ofxTransitions::easeOutQuint, Delaytime + 1.0);        
    }
    
    ofkXMLProperties::setLastOpenData();    
    ofkXMLProperties::setPropertyValue("SETTINGS::NumOpenedEver", NumOpenedEver + 1);
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
                myVerts[index].x = 2 * (i - 5) * SANDRES * mPointIntervalRate;
                myVerts[index].y = (1 * (j - 5)) * SANDRES * mPointIntervalRate;
                myVerts[index].z += 0.1* myVectors[index];

            }else
            {
                //odd
                myVerts[index].x = (2 * (i - 5) + 1) * SANDRES * mPointIntervalRate;
                myVerts[index].y = (1 * (j - 5)) * SANDRES * mPointIntervalRate;
                myVerts[index].z += 0.1 * myVectors[index];
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
                                (myVerts[index].y - mTouchPos.y) * (myVerts[index].y - mTouchPos.y));
                
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
    
    ofPushMatrix();
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
    
    ofEnableBlendMode(OF_BLENDMODE_ALPHA);
    mSplashImage.render();
    
    if(mHelpImage.a > 0.01)
    {
        mHelpImage.render();
    }
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
    isRitghDragOneDirection = true;
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){
        
    if(touch.numTouches != 1)
    {
        isTouched = false;
        return;
    }
    
    mTouchPos.x = touch.x * 1;
    mTouchPos.y = touch.y * 1;// -ofGetHeight() * 1.0;
    mHuePos += (mTouchPos.y - mTouchPosEx.y) * -0.001;
        
    //-----Widgetz 初期の動きFBを付けること。
    if( abs(mTouchDownPos.x - mTouchPos.x) >  2 * abs(mTouchDownPos.y - mTouchPos.y))
    {
        //横方向への移動が支配的の時、 // CLOSE TO OPEN
        
        if(mTouchPos.x - mTouchDownPos.x > 0)
        {
            //右方向へのDrag // CLOSE to OPEN
            if(isRitghDragOneDirection)
            {
                if( mTouchPos.x - mTouchDownPos.x > ofGetWidth() * 0.33)
                {
                    //OPEN
                    changeWidgetState(WidgetOpened);
                    
                }else if( mTouchPos.x - mTouchDownPos.x > ofGetWidth() * 0.20)
                {
                    guiCanvas->setVisible(true);
                    
                    //CLOSEDの時に、
                    if( mWidgetState == WidgetClosed)
                    {
                        mGUISlidePos += (mTouchPos.x - mTouchPosEx.x) * 0.9;
                    }
                }
            }

        }else
        {
            //左方向へのDrag // OPEN to CLOSE
            
            isRitghDragOneDirection = false;
            
            
            if( guiCanvas->getWidgetHit(mTouchPos.x, mTouchPos.y) == NULL)
            {
                
                if(mTouchPos.x - mTouchDownPos.x < - ofGetWidth() * 0.25)
                {
                    //CLOSE
                    changeWidgetState(WidgetClosed);
                }else if( mTouchPos.x - mTouchDownPos.x < - ofGetWidth() * 0.10)
                {
                    if( mWidgetState == WidgetOpened)
                    {
                        mGUISlidePos += (mTouchPos.x - mTouchPosEx.x) * 2.0;
                    }
                }                
            }
        }
    }
    
    mTouchPosEx = mTouchPos;
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    
    isTouched = false;
    mTouchPos.x = touch.x * 1;
    mTouchPos.y = touch.y * 1;// -ofGetHeight() * 1.0;
    
    //吸着させる。
    changeWidgetState(mWidgetState);
    
    if(mHelpImage.a > 0.1)
    {
        Tweener.addTween(mHelpImage.a, 0.0, 1.0, &ofxTransitions::easeOutQuint);
    }
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){
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
    
    //ofAddListener(guiCanvas->newGUIEvent, this, &testApp::guiEvent);
    guiCanvas->disableTouchEventCallbacks();
    
    // ----------- Widget State Init -------//
    
    mWidgetState = WidgetClosed;
    mGUISlidePos = WIDGET_CLOSED_POSX;
}

void testApp::guiEvent(ofxUIEventArgs &e)
{
    if(e.widget->getName() == "BEST")
    {
		ofxUIButton *button = (ofxUIButton *) e.widget;
        if(button->getValue())
        {
        }
    }

}

bool testApp::isGUIWidgetActive()
{
    bool res = false;
    
    if(WIDGET_OPENED_POSX == mWidgetState)
    {
        res = true;
    }
    return res;
}

void testApp::changeWidgetState( WidgetState nextState)
{
    //アニメーション追加する；
    if(true)
    {
        if(WidgetOpened == nextState)
        {
            Tweener.addTween(mGUISlidePos, WIDGET_OPENED_POSX, 0.2, &ofxTransitions::easeOutQuint);
            guiCanvas->setVisible(true);
            
            printf("WidgetOpened /n");

        }else if (WidgetClosed == nextState)
        {
            Tweener.addTween(mGUISlidePos, WIDGET_CLOSED_POSX, 0.2, &ofxTransitions::easeOutQuint);
            guiCanvas->disable();
            guiCanvas->setVisible(false);

            printf("WidgetClosed /n");
            
        }
        mWidgetState = nextState;
    }
}

