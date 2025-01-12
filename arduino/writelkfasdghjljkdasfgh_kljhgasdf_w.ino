#include <SPI.h>
#include <SD.h>

const int chipSelect = 10;
const int width = 160;
const int height = 120;
const int sclkPin = 0;
const int statusLed = A5;
const int dataPins[] = {2, 3, 4, 5, 6, 7, 8, 9};
const int startSignalPin = A0;

// Adjusted timing constants
const unsigned long PIXEL_TIMEOUT = 500;    // 500ms timeout for each pixel
const unsigned long ROW_TIMEOUT = 10000;    // 10s timeout for each row
const unsigned long CAPTURE_TIMEOUT = 600000; // 10 minutes total capture timeout
const unsigned long NEXT_FILE_DELAY = 1000;  // 1s delay between files

File bmpFile;
uint32_t rowSize;
uint32_t expectedFileSize;
bool lastSCLK = LOW;
bool isCapturing = false;
unsigned long lastDataTime;
uint8_t lastPixelValue = 0;
bool captureComplete = false;

void setup() {
  Serial.begin(9600);
  while (!Serial) {
    ; // Wait for Serial port to connect
  }

  pinMode(sclkPin, INPUT);
  pinMode(startSignalPin, INPUT);
  for (int i = 0; i < 8; i++) {
    pinMode(dataPins[i], INPUT);
  }
  pinMode(statusLed  ,OUTPUT);
  Serial.print("Initializing SD card...");
  if (!SD.begin(chipSelect)) {
    Serial.println("Initialization failed!");
    return;
  }
  Serial.println("Initialization done.");
  
  rowSize = ((width + 3) & ~3);
  expectedFileSize = 54 + 1024 + (rowSize * height);
  
  Serial.print("Expected file size: ");
  Serial.println(expectedFileSize);
}

void loop() {
  // Check if previous capture is complete and start signal is LOW before starting new capture
  if (captureComplete && digitalRead(startSignalPin) == LOW) {
    delay(NEXT_FILE_DELAY);  // Wait before starting next capture
    captureComplete = false;
    Serial.println("Ready for next capture");
  }

  if (digitalRead(startSignalPin) == HIGH && !isCapturing && !captureComplete) {
    startCapture();
  }

  if (isCapturing) {
    digitalWrite(statusLed,HIGH);
    processImageData();
    digitalWrite(statusLed,LOW);}
}

void startCapture() {
  char filename[13];
  createNewFileName(filename);
  
  Serial.print("Creating file: ");
  Serial.println(filename);
  
  bmpFile = SD.open(filename, FILE_WRITE);
  if (!bmpFile) {
    Serial.println("Error creating file!");
    return;
  }
  
  writeBMPHeader();
  writeColorPaletteRGB332();
  
  isCapturing = true;
  captureComplete = false;
  lastDataTime = millis();
  Serial.println("Started capture...");
}

void processImageData() {
  static int currentX = 0;
  static int currentY = 0;
  static uint32_t bytesWritten = 54 + 1024;
  static unsigned long rowStartTime = millis();
  bool dataReceived = false;
  
  // Check for total capture timeout
  if (millis() - lastDataTime > CAPTURE_TIMEOUT) {
    Serial.println("Capture timeout - completing file with fill data");
    completeFileWithFill(currentX, currentY, bytesWritten);
    return;
  }

  // Check for row timeout
  if (currentX > 0 && (millis() - rowStartTime > ROW_TIMEOUT)) {
    Serial.println("Row timeout - filling remainder of row");
    fillRestOfRow(currentX, currentY, bytesWritten);
    currentX = 0;
    currentY++;
    rowStartTime = millis();
  }

  bool currentSCLK = digitalRead(sclkPin);
  
  if (currentSCLK == HIGH && lastSCLK == LOW) {
    uint8_t pixelValue = readDataPins();
    if (writePixel(pixelValue, currentX, currentY, bytesWritten)) {
      lastPixelValue = pixelValue;
      lastDataTime = millis();
      dataReceived = true;
      currentX++;
      rowStartTime = millis(); // Reset row timeout on successful data reception
    }
  }
  
  if (currentX >= width) {
    // Add padding to make row size multiple of 4
    while (currentX % 4 != 0) {
      bmpFile.write((uint8_t)0);
      bytesWritten++;
      currentX++;
    }
    
    currentX = 0;
    currentY++;
    rowStartTime = millis();
    
    if (currentY % 10 == 0) {
      Serial.print("Row ");
      Serial.print(currentY);
      Serial.print("/");
      Serial.println(height);
      bmpFile.flush();
    }
  }

  if (currentY >= height) {
    finishCapture(bytesWritten);
    // Reset static variables for next capture
    currentX = 0;
    currentY = 0;
    bytesWritten = 54 + 1024;
    return;
  }
  
  lastSCLK = currentSCLK;
}

bool writePixel(uint8_t value, int x, int y, uint32_t &bytesWritten) {
  if (bmpFile.write(value)) {
    bytesWritten++;
    return true;
  }
  return false;
}

void fillRestOfRow(int &currentX, int currentY, uint32_t &bytesWritten) {
  while (currentX < width) {
    bmpFile.write(lastPixelValue);
    bytesWritten++;
    currentX++;
  }
  
  // Add padding
  while (currentX % 4 != 0) {
    bmpFile.write((uint8_t)0);
    bytesWritten++;
    currentX++;
  }
  
  Serial.print("Filled row ");
  Serial.println(currentY);
}

void completeFileWithFill(int currentX, int currentY, uint32_t &bytesWritten) {
  Serial.println("Completing file with fill data...");
  
  // Complete current row if needed
  if (currentX > 0) {
    fillRestOfRow(currentX, currentY, bytesWritten);
    currentY++;
  }
  
  // Fill remaining rows
  while (currentY < height) {
    // Fill entire row with last valid pixel
    for (int x = 0; x < width; x++) {
      bmpFile.write(lastPixelValue);
      bytesWritten++;
    }
    
    // Add padding
    int padding = rowSize - width;
    while (padding-- > 0) {
      bmpFile.write((uint8_t)0);
      bytesWritten++;
    }
    
    currentY++;
    if (currentY % 10 == 0) {
      Serial.print("Filled row ");
      Serial.println(currentY);
      bmpFile.flush();
    }
  }
  
  finishCapture(bytesWritten);
}

void finishCapture(uint32_t bytesWritten) {
  bmpFile.flush();
  bmpFile.close();
  isCapturing = false;
  captureComplete = true;  // Set flag for next capture
  
  Serial.println("Capture complete!");
  Serial.print("Final size: ");
  Serial.print(bytesWritten);
  Serial.print(" / Expected: ");
  Serial.println(expectedFileSize);
  Serial.println("Waiting for start signal to return LOW before next capture...");
}

// [Previous helper functions remain the same: writeBMPHeader, writeColorPaletteRGB332, 
// writeUint32, writeUint16, readDataPins, createNewFileName]

void writeBMPHeader() {
  uint32_t imageSize = rowSize * height;
  uint32_t fileSize = 54 + 1024 + imageSize;
  
  // BMP Header
  bmpFile.write('B');
  bmpFile.write('M');
  writeUint32(fileSize);
  writeUint32(0);
  writeUint32(54 + 1024);
  
  // DIB Header
  writeUint32(40);
  writeUint32(width);
  writeUint32(height);
  writeUint16(1);
  writeUint16(8);
  writeUint32(0);
  writeUint32(imageSize);
  writeUint32(2835);
  writeUint32(2835);
  writeUint32(256);
  writeUint32(0);
  
  bmpFile.flush();
}

void writeColorPaletteRGB332() {
  for (int i = 0; i < 256; i++) {
    uint8_t r = (i >> 5) & 0x07;
    uint8_t g = (i >> 2) & 0x07;
    uint8_t b = i & 0x03;

    uint8_t red = (r * 255) / 7;
    uint8_t green = (g * 255) / 7;
    uint8_t blue = (b * 255) / 3;

    bmpFile.write(blue);
    bmpFile.write(green);
    bmpFile.write(red);
    bmpFile.write((uint8_t)0);
  }
  bmpFile.flush();
}

void writeUint32(uint32_t value) {
  bmpFile.write((uint8_t)(value & 0xFF));
  bmpFile.write((uint8_t)((value >> 8) & 0xFF));
  bmpFile.write((uint8_t)((value >> 16) & 0xFF));
  bmpFile.write((uint8_t)((value >> 24) & 0xFF));
}

void writeUint16(uint16_t value) {
  bmpFile.write((uint8_t)(value & 0xFF));
  bmpFile.write((uint8_t)((value >> 8) & 0xFF));
}

uint8_t readDataPins() {
  uint8_t value = 0;
  for (int i = 0; i < 8; i++) {
    if (digitalRead(dataPins[i])) {
      value |= (1 << i);
    }
  }
  return value;
}

void createNewFileName(char *filename) {
  int fileIndex = 0;
  do {
    sprintf(filename, "IMG%03d.BMP", fileIndex++);
  } while (SD.exists(filename));
}
