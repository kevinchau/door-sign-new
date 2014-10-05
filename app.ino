#include "application.h"
#include "LiquidCrystal_I2C.h"

LiquidCrystal_I2C   *lcd;
String line0 = "";
String line1 = "";
String line2 = "";
String line3 = "";

void setup()
{
    lcd = new LiquidCrystal_I2C(0x3F, 20, 4);
    lcd->init();
    lcd->backlight();
    lcd->clear();

    // Placeholder text before we recieve first update
    lcd->setCursor(0,0);
    lcd->print("Waiting for Update..");

    // Register the Spark cloud functions
    Spark.function("update", update);
    Spark.function("backlight", backlight);
}

// Don't need anything here
void loop() {

}

// Backlight on/off function
int backlight(String args) {
  if (args == "on") {
    lcd->backlight();
  } else if (args == "off") {
    lcd->noBacklight();
  }

  return 1;
}

// Runs to update the screen
int update(String args) {

    String temp = getValue(args, '|', 0);
    line0 = temp;

    String temp1 = getValue(args, '|', 1);
    line1 = temp1;

    String temp2 = getValue(args, '|', 2);
    line2 = temp2;

    String temp3 = getValue(args, '|', 3);
    line3 = temp3;

    lcd->setCursor(0, 0);
    lcd->print("                    ");
    lcd->setCursor(0, 0);
    lcd->print(line0);

    lcd->setCursor(0, 1);
    lcd->print("                    ");
    lcd->setCursor(0, 1);
    lcd->print(line1);

    lcd->setCursor(0, 2);
    lcd->print("                    ");
    lcd->setCursor(0, 2);
    lcd->print(line2);

    lcd->setCursor(0, 3);
    lcd->print("                    ");
    lcd->setCursor(0, 3);
    lcd->print(line3);

    return 1;

}

// Helper function to split strings by the "|" seperator
String getValue(String data, char separator, int index) {
  int found = 0;
  int strIndex[] = {0, -1};
  int maxIndex = data.length()-1;

  for(int i = 0; i <= maxIndex && found <= index; i++){
    if(data.charAt(i) == separator || i == maxIndex){
        found++;
        strIndex[0] = strIndex[1]+1;
        strIndex[1] = (i == maxIndex) ? i+1 : i;
    }
  }


  return found>index ? data.substring(strIndex[0], strIndex[1]) : "";
}
