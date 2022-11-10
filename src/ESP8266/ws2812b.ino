
#define BLINKER_PRINT Serial
#define BLINKER_WIFI
#define BLINKER_MIOT_LIGHT
#include <Blinker.h>
#include <Wire.h>
BlinkerSlider Slider1("bright");
unsigned char testcode[8] = {0x40,0x05,0xa0,0x00,0x00,0x00,0x00,0xbc};
char auth[] = "07e3da7c26ad";
char ssid[] = "A92s";
char pswd[] = "12345678";
int bright;
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
  
    Slider1.attach(slider1_callback);
    BlinkerMIOT.attachBrightness(miotBright);
    Blinker.begin(auth, ssid, pswd);
}

void loop() {
       Blinker.run();
}
