/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.

  This example code is in the public domain.
 */

#include <YunClient.h>
#include <YunServer.h>

// Pin 13 has an LED connected on most Arduino boards.
// give it a name:
int led = 13;

int colorSize = 30*4*3;

String _command = "blink";

// Create an instance of the YunServer to listen for HTTP requests.
YunServer server;

// the setup routine runs once when you press reset:
void setup() {
  // initialize the digital pin as an output.
  pinMode(led, OUTPUT);
  
  Serial.begin(115200);

  // Initialize Yun bridge library.
  Bridge.begin();
  
  // Initialize the neo pixel strip.
//  strip.begin();
//  strip.show();

  // Connect the server library to the Linio OS and start listening for connections.
  server.listenOnLocalhost();
  server.begin();

}

int x2i(char *s) 
{
  int x = 0;
  for(;;) {
    char c = *s;
    if (c >= '0' && c <= '9') {
      x *= 16;
      x += c - '0'; 
    }
    else if (c >= 'A' && c <= 'F') {
      x *= 16;
      x += (c - 'A') + 10; 
    }
    else break;
    s++;
  }
  return x;
}

// the loop routine runs over and over again forever:
void loop() {

  // Handle any HTTP connections.
  YunClient client = server.accept();
  if (client) {

    // Read the command and value.
    String commandLabel = client.readStringUntil('/');
    String commandValue = client.readStringUntil('/');
    String colorLabel = client.readStringUntil('/');
    
    int colors[colorSize];
    
    int ndx = 0;
    while(client.available() > 0) {
      
      char buff[2];
      client.readBytes(buff, 2);
      
      // TODO: verify buffed = 2;
      
      colors[ndx] = x2i(buff);
         
      ++ndx;
    }
    
    for(int i=0; i<colorSize; i=i+3) {
      client.println("Color[" + String(i/3) + "] => rgb(" +colors[i]+","+colors[i+1]+","+colors[i+2]+")");
    }
    
    client.println("got command: " + commandValue);
//    client.println("got withColors: " + colors);
        
    _command = commandValue;
    
    // Send an empty response and close the connection.
    // Note that sending a custom status code and content type as below is not
    // documented officially: http://forum.arduino.cc/index.php?PHPSESSID=es72i5nserl8lojnk3vl86d8r6&topic=191895.0
    client.println();
    client.stop();

  }
  
  int delTime = 0;
  
  if(_command == "blink") {
    delTime = 1000;
  } else if(_command == "blink_fast") {
    delTime = 100;
  }

  digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(delTime);               // wait for a second
  digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
  delay(delTime);               // wait for a second

}
