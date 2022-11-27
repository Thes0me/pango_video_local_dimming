
#define BLINKER_PRINT Serial
#define BLINKER_WIFI
#define BLINKER_MIOT_LIGHT
#include <Blinker.h>
#include <Wire.h>
BlinkerButton Button1("white");
BlinkerButton Button2("color");
BlinkerButton Button3("mutcolor");
BlinkerSlider Slider1("bright");
BlinkerSlider SliderR("R");
BlinkerSlider SliderG("G");
BlinkerSlider SliderB("B");
BlinkerRGB RGB1("RGBKey");
unsigned char testcode[8] = {0x40,0x05,0xa0,0x00,0x00,0x00,0x00,0xbc};
char auth[] = "07e3da7c26ad";
char ssid[] = "A92s";
char pswd[] = "12345678";
int bright;
void button1_callback(const String & state) {
    testcode[2] = 0xa0;
    testcode[6] = 0x00;
    Serial.write(testcode,8);
    delay(10);
    Serial.write(testcode,8);
    delay(10);
    Serial.write(testcode,8);
}
void button2_callback(const String & state) {
    testcode[2] = 0xa1;
    testcode[4] = 0xff;
    testcode[5] = 0x00;
    testcode[6] = 0x00;
    Serial.write(testcode,8);
    delay(10);
    Serial.write(testcode,8);
    delay(10);
    Serial.write(testcode,8);
  
}
void button3_callback(const String & state)
{
    testcode[2] = 0xa2;
    testcode[4] = 0x7d;
    testcode[5] = 0x7d;
    testcode[6] = 0x7d;
    Serial.write(testcode,8);
    delay(10);
    Serial.write(testcode,8);
    delay(10);
    Serial.write(testcode,8);
  }
void slider1_callback(int32_t value)
  {
    bright = value;
    Slider1.color("#1E90FF");
    Slider1.print();
    //Serial.println(bright);
    testcode[6] = 255-bright;
    Serial.write(testcode,8);
    Serial.write(testcode,8);
    Serial.write(testcode,8);
    //BLINKER_LOG("get slider value: ", value);
  }
  void sliderR_callback(int32_t value)
  {
    testcode[4] = value;
    Serial.write(testcode,8);
    delay(10);
    Serial.write(testcode,8);
    delay(10);
    Serial.write(testcode,8);
    //BLINKER_LOG("get slider value: ", value);
  }
  void sliderG_callback(int32_t value)
  {
    testcode[5] = value;
    Serial.write(testcode,8);
    delay(10);
    Serial.write(testcode,8);
    delay(10);
    Serial.write(testcode,8);
    //BLINKER_LOG("get slider value: ", value);
  }
  void sliderB_callback(int32_t value)
  {
    testcode[6] = value;
    Serial.write(testcode,8);
    delay(10);
    Serial.write(testcode,8);
    delay(10);
    Serial.write(testcode,8);
  }
    void rgb1_callback(uint8_t r_value, uint8_t g_value, uint8_t b_value, uint8_t bright_value)
{
    bright = bright_value;
        testcode[4] = r_value;
    testcode[5] = g_value;
    testcode[6] = b_value;
    Serial.write(testcode,8);
}
  void miotColor(int32_t color)
{
    //BLINKER_LOG("need set color: ", color);
    int colorR,colorG,colorB;
    colorR = color >> 16 & 0xFF;
    colorG = color >>  8 & 0xFF;
    colorB = color       & 0xFF;
    testcode[4] = colorR;
    testcode[5] = colorG;
    testcode[6] = colorB;
    //BLINKER_LOG("colorR: ", colorR, ", colorG: ", colorG, ", colorB: ", colorB);
    Serial.write(testcode,8);
    BlinkerMIOT.color(color);
    
    BlinkerMIOT.print();
  }

void miotBright(const String & bright)
  {
    int colorW = bright.toInt();
    colorW = map(colorW,0,100,0,255);
    testcode[6] = 255-colorW;
    //Serial.printf("亮度调节中...%d",testcode[3]);
    BlinkerMIOT.brightness(colorW);
    Serial.write(testcode,8);
    Serial.write(testcode,8);
    Serial.write(testcode,8);
    BlinkerMIOT.print();
    }
void setup() {
    Serial.begin(115200);
    RGB1.attach(rgb1_callback);
    Slider1.attach(slider1_callback);
    SliderR.attach(sliderR_callback);
    SliderG.attach(sliderG_callback);
    SliderB.attach(sliderB_callback);
    BlinkerMIOT.attachBrightness(miotBright);
    BlinkerMIOT.attachColor(miotColor);
    Button1.attach(button1_callback);
    Button2.attach(button2_callback);
    Button3.attach(button3_callback);
    Blinker.begin(auth, ssid, pswd);
}

void loop() {
       Blinker.run();
}
