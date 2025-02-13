import controlP5.*;
import processing.svg.*;

ControlP5 cp5;
PImage img;
int pixelSize = 10; // Default pixel size
boolean drawingMode = false; // Flag to toggle drawing mode
boolean eraseMode = false; // Flag to toggle erase mode
boolean rotate45 = false; // Flag to toggle 45-degree rotation
boolean resizeRectangles = false; // Flag to toggle resizing of rectangles
boolean smallerRectanglesMode = false; // Flag for drawing smaller rectangles

boolean showInstructions = false; // Flag to toggle instructions visibility

ArrayList<Rect> smallerRectangles = new ArrayList<Rect>(); // List to store smaller rectangles drawn during drag

float brightnessThreshold = 128; // Default brightness threshold for midtones

void setup() {
  size(800, 800);
  background(color(33, 9, 0)); // Set background to #210900
  cp5 = new ControlP5(this);

  // Create a button to load an image
  cp5.addButton("loadImage")
     .setLabel("Load\nImage")
     .setPosition(20, 20)
     .setSize(60, 60)
     .setColorBackground(color(253, 83, 79)) // #fd534f
     .setColorForeground(color(200, 50, 50)) // Hover color
     .setColorActive(color(200, 50, 50)); // Active color

  // Create a slider for pixel size
  cp5.addSlider("pixelSize")
     .setLabel("Pixel Size")
     .setRange(10, 25) // Set the range to go from 10 to 25
     .setValue(10)     // Set the initial value to 10
     .setPosition(100, 20)
     .setSize(200, 20)
     .setNumberOfTickMarks(4) // Tick marks for values 10, 15, 20, and 25
     .setSliderMode(ControlP5.HORIZONTAL)
     .setColorBackground(color(253, 83, 79)) // Slider background
     .setColorForeground(color(200, 50, 50)) // Slider foreground
     .setColorActive(color(200, 50, 50)); // Slider active color

  // Create a button to rotate pixels 45 degrees
  cp5.addButton("rotatePixels45")
     .setLabel("Rotate 45°")
     .setPosition(360, 20)
     .setSize(60, 60)
     .setColorBackground(color(253, 83, 79))
     .setColorForeground(color(200, 50, 50))
     .setColorActive(color(200, 50, 50));

  // Create a button to resize rectangles to 0.75x
  cp5.addButton("resizeRectanglesButton")
     .setLabel("Resize\nPixels")
     .setPosition(430, 20)
     .setSize(60, 60)
     .setColorBackground(color(253, 83, 79))
     .setColorForeground(color(200, 50, 50))
     .setColorActive(color(200, 50, 50));

  // Create a button to export SVG
  cp5.addButton("exportSVG")
     .setLabel("Export\nSVG")
     .setPosition(500, 20)
     .setSize(60, 60)
     .setColorBackground(color(253, 83, 79))
     .setColorForeground(color(200, 50, 50))
     .setColorActive(color(200, 50, 50));

  // Create a label to display the current mode
  cp5.addLabel("modeLabel")
     .setText(" ")
     .setPosition(20, 320)
     .setSize(200, 20)
     .setColor(color(255)); // Text color white

  // Create an instructions button
  cp5.addButton("instructionsButton")
     .setLabel("?")
     .setPosition(760, 20) // Same level as Load Image button
     .setSize(20 , 20)
     .setColorBackground(color(253, 83, 79))
     .setColorForeground(color(200, 50, 50))
     .setColorActive(color(200, 50, 50));

  // Create a UI Textarea for instructions
  cp5.addTextarea("instructions")
     .setText("Press 'D' to draw\nPress 'E' to erase\nPress 'S' for smaller rectangles\nUse the slider to adjust pixel size.")
     .setPosition((width / 2 -100), height - 100) // Centered at the bottom
     .setSize(200, 60)
     .setColor(color(255)) // Text color white
     .setColorForeground(color(200, 50, 50))
     .setLineHeight(14)
     .hide(); // Initially hidden

  // Create a slider for controlling the brightness threshold for midtones
  cp5.addSlider("brightnessThreshold")
     .setLabel("Threshold")  // Change label to "Threshold"
     .setRange(0, 255)      // Set the range from 0 to 255
     .setValue(brightnessThreshold) // Set the initial value to 128
     .setPosition(100, 60)
     .setSize(200, 20)
     .setNumberOfTickMarks(6) // Add tick marks for clarity
     .setSliderMode(ControlP5.HORIZONTAL)
     .setColorBackground(color(253, 83, 79)) // Slider background
     .setColorForeground(color(200, 50, 50)) // Slider foreground
     .setColorActive(color(200, 50, 50)); // Slider active color

  img = null; // Start with no image
}

void draw() {
  background(color(33, 9, 0)); // Dark background
  if (showInstructions) {
    cp5.get("instructions").show(); // Show instructions if flag is true
  } else {
    cp5.get("instructions").hide(); // Hide instructions if flag is false
  }

  if (img != null) {
    img.resize(width, height); // Resize image to fit the window
    img.filter(GRAY); // Convert to grayscale

    // Apply rectangle resizing logic if the resize flag is active
    float rectSize = resizeRectangles ? pixelSize * 0.75 : pixelSize;

    for (int y = 0; y < img.height; y += pixelSize) {
      for (int x = 0; x < img.width; x += pixelSize) {
        color c = img.get(x, y);
        float brightnessValue = brightness(c);

        if (brightnessValue < brightnessThreshold) { // Darker pixel based on threshold
          pushMatrix();
          translate(x + pixelSize / 2, y + pixelSize / 2);
          if (rotate45) rotate(radians(45));
          fill(255);
          noStroke();
          rectMode(CENTER);
          rect(0, 0, rectSize, rectSize); // Use normal rectangle size
          popMatrix();
        } else if (brightnessValue >= brightnessThreshold && brightnessValue < 192) { // Midtones based on threshold
          float smallerRectSize = rectSize * 0.75; // Make it 25% smaller
          pushMatrix();
          translate(x + pixelSize / 2, y + pixelSize / 2);
          if (rotate45) rotate(radians(45));
          fill(255);
          noStroke();
          rectMode(CENTER);
          rect(0, 0, smallerRectSize, smallerRectSize); // Draw smaller rectangle for midtones
          popMatrix();
        }
      }
    }
  }

  // Draw all the smaller rectangles
  for (Rect rect : smallerRectangles) {
    float smallerSize = resizeRectangles ? pixelSize * 0.75 * 0.75 : pixelSize * 0.75; // Factor in resizing for smaller rectangles
    float x = rect.x;
    float y = rect.y;

    // Adjust position and size to scale with the pixel grid
    float adjustedX = floor(x / pixelSize) * pixelSize + pixelSize / 2;
    float adjustedY = floor(y / pixelSize) * pixelSize + pixelSize / 2;

    pushMatrix();
    translate(adjustedX, adjustedY);
    if (rotate45) rotate(radians(45));
    fill(255); // Red for smaller rectangles
    noStroke();
    rectMode(CENTER);
    rect(0, 0, smallerSize, smallerSize); // Smaller rectangle size
    popMatrix();
  }
}

// Show/hide instructions on hover over the instructions button
void instructionsButton() {
  showInstructions = !showInstructions;
}

// Function to load an image
void loadImage() {
  selectInput("Select an image to convert to pixel art.", "fileSelected");
}

// Callback function for selectInput
void fileSelected(File selection) {
  if (selection != null) {
    img = loadImage(selection.getAbsolutePath());
  }
}

// Update pixel size from slider
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController() && theEvent.getController().getName().equals("pixelSize")) {
    pixelSize = (int) theEvent.getValue();
  } else if (theEvent.isController() && theEvent.getController().getName().equals("brightnessThreshold")) {
    brightnessThreshold = theEvent.getValue(); // Update brightness threshold based on slider
  }
}

// Rotate pixels 45 degrees
void rotatePixels45() {
  rotate45 = !rotate45;
}

// Resize rectangles to 0.75x the size
void resizeRectanglesButton() {
  resizeRectangles = !resizeRectangles; // Toggle resizing of rectangles
  String mode = "Mode: ";
  mode += resizeRectangles ? "Resized Rectangles (0.75x)" : "Normal Rectangles";
  cp5.getController("modeLabel").setLabel(mode);
  updateModeLabel(); // Update the mode label after changing rectangle resizing mode
}

// Enable smaller rectangle drawing mode with 'S'
void smallerRectanglesButton() {
  smallerRectanglesMode = !smallerRectanglesMode;
  String mode = "Mode: ";
  mode += smallerRectanglesMode ? "Smaller Rectangles" : "Normal Rectangles";
  cp5.getController("modeLabel").setLabel(mode);
  updateModeLabel(); // Update the mode label after changing smaller rectangle mode
}

// MousePressed function to draw or erase on the image
// Draw or erase when dragging the mouse
void mouseDragged() {
  if (img != null) {
    int gridX = floor(mouseX / pixelSize) * pixelSize;
    int gridY = floor(mouseY / pixelSize) * pixelSize;

    // Handle drawing and erasing
    if (drawingMode) {
      // Draw the rectangle at the current mouse location
      img.loadPixels();
      for (int y = gridY; y < gridY + pixelSize; y++) {
        for (int x = gridX; x < gridX + pixelSize; x++) {
          if (x >= 0 && x < img.width && y >= 0 && y < img.height) {
            img.set(x, y, color(0)); // Draw black color (or any color for pixels)
          }
        }
      }
    } else if (eraseMode) {
      // Erase the drawn rectangles
      img.loadPixels();
      for (int y = gridY; y < gridY + pixelSize; y++) {
        for (int x = gridX; x < gridX + pixelSize; x++) {
          if (x >= 0 && x < img.width && y >= 0 && y < img.height) {
            img.set(x, y, color(255)); // Erase to white (or any background color)
          }
        }
      }

      // Erase the smaller rectangles
      for (int i = smallerRectangles.size() - 1; i >= 0; i--) {
        Rect rect = smallerRectangles.get(i);
        float rectX = floor(rect.x / pixelSize) * pixelSize + pixelSize / 2;
        float rectY = floor(rect.y / pixelSize) * pixelSize + pixelSize / 2;

        if (dist(mouseX, mouseY, rectX, rectY) < pixelSize) {
          smallerRectangles.remove(i); // Remove smaller rectangle if close to the mouse position
        }
      }
    }

    // Draw smaller rectangles only if the mode is active
    if (smallerRectanglesMode) {
      smallerRectangles.add(new Rect(gridX, gridY)); // Store smaller rectangles' positions
    }
  }
}

// Update the mode label based on the current mode
void updateModeLabel() {
  String mode = "Mode: ";
  if (drawingMode) {
    mode += "Drawing";
  } else if (eraseMode) {
    mode += "Erasing";
  } else if (smallerRectanglesMode) {
    mode += "Smaller Rectangles";
  } else {
    mode += "None";
  }
  cp5.getController("modeLabel").setLabel(mode);
}

// KeyPressed function to toggle modes with 'e', 'd', and 's'
void keyPressed() {
  if (key == 'd' || key == 'D') {
    drawingMode = true;
    eraseMode = false;
    smallerRectanglesMode = false;
    updateModeLabel();
  } else if (key == 'e' || key == 'E') {
    eraseMode = true;
    drawingMode = false;
    smallerRectanglesMode = false;
    updateModeLabel();
  } else if (key == 's' || key == 'S') {
    smallerRectanglesMode = !smallerRectanglesMode;
    drawingMode = false;
    eraseMode = false;
    updateModeLabel();
  }
}

void exportSVG() {
  String fileName = "pixel_art_export.svg";
  beginRecord(SVG, fileName);

  if (img != null) {
    img.resize(width, height);

    // Apply rectangle resizing logic if the resize flag is active
    float rectSize = resizeRectangles ? pixelSize * 0.75 : pixelSize;

    // Export the rectangles based on the image's pixels
    for (int y = 0; y < img.height; y += pixelSize) {
      for (int x = 0; x < img.width; x += pixelSize) {
        color c = img.get(x, y);
        float brightnessValue = brightness(c);

        if (brightnessValue < brightnessThreshold) { // Darker pixel based on threshold
          float rectX = x + pixelSize / 2;
          float rectY = y + pixelSize / 2;
          pushMatrix();
          translate(rectX, rectY);
          if (rotate45) rotate(radians(45));
          fill(0);
          noStroke();
          rectMode(CENTER);
          rect(0, 0, rectSize, rectSize);
          popMatrix();
        } else if (brightnessValue >= brightnessThreshold && brightnessValue < 192) { // Midtones based on threshold
          float smallerRectSize = rectSize * 0.75;
          float rectX = x + pixelSize / 2;
          float rectY = y + pixelSize / 2;
          pushMatrix();
          translate(rectX, rectY);
          if (rotate45) rotate(radians(45));
          fill(0);
          noStroke();
          rectMode(CENTER);
          rect(0, 0, smallerRectSize, smallerRectSize);
          popMatrix();
        }
      }
    }

    // ✅ Export the manually drawn smaller rectangles
    for (Rect rect : smallerRectangles) {
      float smallerSize = resizeRectangles ? pixelSize * 0.75 * 0.75 : pixelSize * 0.75;
      float rectX = floor(rect.x / pixelSize) * pixelSize + pixelSize / 2;
      float rectY = floor(rect.y / pixelSize) * pixelSize + pixelSize / 2;

      pushMatrix();
      translate(rectX, rectY);
      if (rotate45) rotate(radians(45));
      fill(0);
      noStroke();
      rectMode(CENTER);
      rect(0, 0, smallerSize, smallerSize); // Export smaller rectangles
      popMatrix();
    }
  }

  endRecord();
  println("Exported SVG as " + fileName);
}

// Define the Rect class for smaller rectangles
class Rect {
  float x, y;

  Rect(float x, float y) {
    this.x = x;
    this.y = y;
  }
}
