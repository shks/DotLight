#include "testApp.h"

#define BUFSIZE (9216 * 4)
#define DISP_RATIO ((ofGetWidth() / 768.0))

//--------------------------------------------------------------
void testApp::setup(){	
	// initialize the accelerometer
	ofxAccelerometer.setup();
	//iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
	
	ofBackground(0,0,0);
    ofBackgroundHex(0x000000);
    
    initGUILayout();

    int WIDTH = ofGetWidth() * 2 / SANDRES;
    int HEIGHT = ofGetHeight() * 2 / SANDRES;
    for (int i = 0; i < WIDTH; i++) {
        for (int j = 0; j < HEIGHT; j++) {
            myVerts[j * WIDTH + i].set(i * SANDRES, (j - HEIGHT/2) * SANDRES, 0);
            
            ofColor col;
            col.setHsb(255.0 * ( mHuePos + (float)j / (float)HEIGHT * 0.2 ) , 255.0 * 0.5, 255.0 * 0.7);
            
            float a = ((j + i) % 2 == 0) ? 1.0 : 0.0;
            myColor[j * WIDTH + i].set(col.r / 255.5, col.g / 255.5, col.b / 255.5, a);
        }
    }
    
    myVbo.setVertexData(myVerts, NUM_PARTICLES, GL_DYNAMIC_DRAW);
    myVbo.setColorData(myColor, NUM_PARTICLES, GL_DYNAMIC_DRAW);
    
    mPointIntervalRate = 1.0;
    mPointSize = 2.0;
    mIsSmoothPoint = true;
    mHuePos = 0.0;
    mHueScale = 2.0;
    mPointBrightNess = 0.7;

    //multiTouch Enable
    multiTouchEvent.enable();
    ofAddListener(multiTouchEvent.touchTwoFingerEvent, this, &testApp::touchTwoFinger) ;

}

//--------------------------------------------------------------
void testApp::update(){
    
    int WIDTH = ofGetWidth() * 2 / SANDRES;
    int HEIGHT = ofGetHeight() * 2 / SANDRES;
    
    for (int i = 0; i < WIDTH; i++) {
        for (int j = 0; j < HEIGHT; j++) {
            int index = j * WIDTH + i;
            /*
            
            myVerts[i].z = pow( (mTouchPos.x - myVerts[i].x), 2 )
            + pow( (mTouchPos.y - myVerts[i].y), 2 );
            myVerts[i].z = 100 / (1 + sqrt(myVerts[i].z ));
            */
            
            //mPointIntervalRate
            myVerts[index].set(i * SANDRES * mPointIntervalRate,
                                       (j - HEIGHT/2) * SANDRES * mPointIntervalRate, 0);
            
            /// ----------- COLOR ------------- //
            

            float sat = 0.5;//
            float bri = 1.0;//
            //0.8 + 1.0 / ( 1.0 + 0.05 * (float)sqrt( pow( (mTouchPos.x - myVerts[index].x), 2 )
            //+ pow( (mTouchPos.y - myVerts[index].y), 2 ) ) );
            
            ofColor col;
            //TODO
            int HUE = (int)(255.0 * ( mHuePos + (float)j / ((float)HEIGHT * mHueScale ) ));
            
            while (HUE < 0) {
                HUE += 255;
            }
            
            HUE = HUE % 255;
            col.setHsb(HUE , 255.0 * sat, 255.0 * bri);
            
            float a = ((j + i) % 2 == 0) ? mPointBrightNess : 0.0;
            
            myColor[j * WIDTH + i].set(col.r / 255.5, col.g / 255.5, col.b / 255.5, a);
        }
    }
    
    myVbo.updateVertexData(myVerts, NUM_PARTICLES);
    myVbo.updateColorData(myColor, NUM_PARTICLES);///(/myVerts, NUM_PARTICLES);

}

//--------------------------------------------------------------
void testApp::draw(){
	//rendering here something..
    
    ofPushMatrix();
    
    if(mIsSmoothPoint)
    {
        glEnable(GL_POINT_SMOOTH);
    }else
    {
        glDisable(GL_POINT_SMOOTH);
    }
    
    glPointSize(mPointSize);
    
    ofEnableBlendMode(OF_BLENDMODE_ADD);
 
//    static GLfloat distance[] = { 0.0, 0.0, 1.0 };
//    glPointParameterfv(GL_POINT_DISTANCE_ATTENUATION, distance);
//    glPointSize(5000);
    
    myVbo.draw(GL_POINTS, 0, NUM_PARTICLES);
    
    ofPopMatrix();
    
    
    ofSetColor(255, 255, 255);
    ofDrawBitmapString("dot light version 000 : " + ofToString( ofGetFrameRate() ), 0.0, 10.0);
    ofDrawBitmapString("Time : " + ofToString( ofGetElapsedTimeMillis() ), 0.0, 30.0);
    
    ofSetupScreen();
    
    ofTranslate(0, - ofGetHeight());
    
}

//--------------------------------------------------------------
void testApp::exit(){

}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
    isTouched = true;

    mTouchPos.x = touch.x * 1;
    mTouchPos.y = touch.y * 1 -ofGetHeight() * 1.0;
    
    mTouchPosEx = mTouchDownPos = mTouchPos;
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){
    mTouchPos.x = touch.x * 1;
    mTouchPos.y = touch.y * 1 -ofGetHeight() * 1.0;

    mHuePos += (mTouchPos.y - mTouchPosEx.y) * -0.001;
    
    mTouchPosEx = mTouchPos;
    
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    isTouched = false;
    mTouchPos.x = touch.x * 1;
    mTouchPos.y = touch.y * 1 -ofGetHeight() * 1.0;

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
    cout << multiTouch.pinchLengthDif << "\n";
    
    mHueScale += multiTouch.pinchLengthDif * 0.01;

    if(mHueScale < 0.5)
    {
        mHueScale = 0.5;
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
    int xInit = OFX_UI_GLOBAL_WIDGET_SPACING;
    int FONT_LARGE = (int) 30 * DISP_RATIO;
    int FONT_MID= (int) 25 * DISP_RATIO;
    int FONT_SMALL= (int) 20 * DISP_RATIO;
    int dim =  70;
    float length = ofGetWidth() - xInit;
    
    //-guiHeader-----------------------------------------------------------//
    
    float guiHeaderHEIGHT = 2.0;
    
    guiCanvas = new ofxUICanvas(0,0 ,ofGetWidth(),ofGetHeight() * guiHeaderHEIGHT);
    
    guiCanvas->setTheme(OFX_UI_THEME_HACKER);
    
    guiCanvas->setFont("Roboto-Light.ttf");
    guiCanvas->setFontSize(OFX_UI_FONT_LARGE , FONT_LARGE);
    guiCanvas->setFontSize(OFX_UI_FONT_MEDIUM , FONT_MID);
    
    guiCanvas->setFontSize(OFX_UI_FONT_SMALL , FONT_SMALL);
    
    {
        guiCanvas->addWidgetDown(new ofxUILabel("Dot Light Debug", OFX_UI_FONT_LARGE));
        guiCanvas->addWidgetDown(new ofxUILabel("Double Tap to Swicth Debug", OFX_UI_FONT_LARGE));
        //guiCanvas->addWidgetDown(new ofxUIFPSSlider("FPS", ofGetWidth() - 2 * xInit, 50,15));
        guiCanvas->addWidgetDown(new ofxUISpacer(length-xInit, 1));
        
        guiCanvas->addSlider("POINT_SIZE", 1.0, 10.0, &mPointSize, length-xInit, 60);
        guiCanvas->addSlider("POINT_INTERVAL", 1.0, 10.0, &mPointIntervalRate, length-xInit, 60);
        guiCanvas->addSlider("POINT_BrightNess", 0.1, 1.0, &mPointBrightNess, length-xInit, 60);
        
        guiCanvas->addToggle("POINT_SMOOTH", &mIsSmoothPoint, dim, 60);

        //guiCanvas
        
        guiCanvas->addWidgetDown(new ofxUISpacer(length-xInit, 1));

        guiCanvas->addSlider("HUE", 1.0, 10.0, &mHuePos, length-xInit, 60);
        guiCanvas->addSlider("HUE_SCALE", 1.0, 10.0, &mHueScale, length-xInit, 60);

        
        
        guiCanvas->addWidgetDown(new ofxUISpacer(length-xInit, 1));
        
        vector<string> names;
        names.push_back("PointSmooth");
        names.push_back("HIGH");
        names.push_back("MEDIUM");
        names.push_back("LOW");
        names.push_back("WORST");
        
//       guiCanvas->addWidgetDown(new ofxUIRadio( dim *2, dim, "Debug", names, OFX_UI_ORIENTATION_VERTICAL));
        
        //label = new ofxUILabel("Data size", 70);
        //guiCanvas->addWidgetDown(label);
        
    }
    
    ofAddListener(guiCanvas->newGUIEvent, this, &testApp::guiEvent);
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
    
    /*
     
     names.push_back("BEST");
     names.push_back("HIGH");
     names.push_back("MEDIUM");
     names.push_back("LOW");
     names.push_back("WORST");
     
     */
}

