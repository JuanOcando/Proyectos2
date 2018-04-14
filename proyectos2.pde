import processing.serial.*;
import processing.sound.*;
 
// SoundFile file  = new SoundFile(this, "sample.mp3") ;       // Alarma
 Serial myPort;        // The serial port

float prevY0;
float prevY1;

int marginN = 100;
int marginS = 300;
int marginW = 50;
int marginE = 300;
int marginE1 = 50;


int timediv = 1;
boolean peace = false;

int lastsec = 0;

float[] DCLight = new float[50];
float[] acce = new float[200];
float[] analog = new float[3];
boolean[] dig = new boolean[4];

PImage img;

Table events;
float distance;


Table table;

void setup() {
  size(800, 700);
  //frameRate(1); To plot the graph at 1 point per second 

  
  frameRate(4000);
  printArray(Serial.list());
  
  
  
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[0], 115200);
  
  //String[] fontList = PFont.list();
 // printArray(fontList);
  
  //table = new Table();
  
  //table.addColumn("y");
  //table.addColumn("m");
  //table.addColumn("d");
  //table.addColumn("h");
  //table.addColumn("min");
  //table.addColumn("sec");
  //table.addColumn("type");
  //table.addColumn("o");
 
  //saveTable(table, "data/events.csv");
 
  
  
  // file.play();
  
  
  events = loadTable("data/events.csv", "header");
  
  img = loadImage("man.png");
   
  drawStuff();
 
}


void drawStuff() {
  
  background(40,62,74);
  fill(255);
  
  textSize(26);
  text("Servidor de Seguridad Para Museos" , width/2 - 225, marginN/2);
  textSize(12);
  
  text("Fecha", width - marginE + 25 , marginN  + 40 );
  text("Hora", width - marginE + 90, marginN   + 40);
  text("Valor", width - marginE + 150, marginN  + 40 );
  text("Evento", width - marginE + 220, marginN   + 40);
  
   fill(20);
   rect(marginW + 1, marginN + 1, width - (marginW + marginE) - 2, height - ( marginN + marginS) -2 );
   fill(255);
 
  for(int i = 6; i>=0; i--){
   stroke(255);
   text(nf(3.0/6.0*i,1,1) , marginW - 20, marginN + (height-marginN-marginS)/6*(6-i)+5);
   line(marginW,  marginN + (height-marginN-marginS)/6*(i) , width - marginE , marginN + (height-marginN-marginS)/6*(i) );
  
   line(marginW + (width - marginW - marginE)/6*(i), marginN , marginW  + (width - marginW - marginE)/6*(i), height - marginS - 2);
   }
   
 
  
  stroke(255);
  
  
  
  fill(255, 96, 0);
  ellipse(marginW, height - marginS + 20, 10, 10 );
  fill(255);
  text("Acelerómetro", marginW + 10, height - marginS + 25);
  
  fill(0, 0, 255);
  ellipse(marginW + 100, height - marginS + 20, 10, 10 );
  fill(255);
  text("Fotorresistencia", marginW + 110, height - marginS + 25);
  
  text("Sonido", marginW + 250, height - marginS + 25 );
  
  text("Cuadro ausente", marginW + 120 , height - marginS + 45 );
  
  text("Evento de proximidad", marginW + 280 , height - marginS + 45 );
  
  fill(122,231,99);
  
  rect(marginW , height - marginS/1.5, (width - marginE1 - marginW)/10, 50);
  
  //image(img, marginW + (width - marginE1 - marginW) * (ultra /1081.0), height - marginS/1.5, 100, 100);
  //line(marginW - 5, height - marginS + 1, width - marginE , height - marginS + 1);
  //line(marginW - 5, marginN ,marginW - 5, height - marginS);
  frameCount = marginW + 1; 
}

void draw() {
  
  //Serial Port Value Parsing
  fate();

  //Graph
  graphRefresh(analog);
  
  //Sensors Data Processing
  checkFlash(DCLight, analog[1]);
  checkAcce(acce,analog[0]);
  checkUltra(analog[2]);
  checkButton(dig[1]);
  
  //Event Processing in the table
  seeEvents();
  
}
 
 boolean alarm;
 
void checkButton(boolean dig){
  
  if(dig)
    alarm = !alarm;
  
}

void seeEvents(){
  

  
  fill(40,62,74);
  noStroke();
  rect(width - marginE + 1, marginN - 20, marginE, height/3);
  
  events = loadTable("data/events.csv", "header");
  
  println("rows:", events.getRowCount());
  
  stroke(255);
  fill(255);
  
  text("Fecha", width - marginE + 25 , marginN  + 35 );
  text("Hora", width - marginE + 105, marginN   + 35);
  text("Valor", width - marginE + 170, marginN  + 35 );
  text("Evento", width - marginE + 220, marginN   + 35);
  
  if(events.getRowCount() < 10){
    int i = 0, j = 0; 
    
    for (TableRow row : events.rows()) {
    
      
      text(row.getInt("y"), width - marginE + 20 , marginN + j *10  );
      
      text(row.getInt("m"), width - marginE + 55 , marginN + j * 10 );
      text(row.getInt("d"), width - marginE + 70 , marginN + j * 10 );
      text(row.getInt("h"), width - marginE + 90, marginN + j * 10 );
      text(row.getInt("min"), width - marginE + 105, marginN + j * 10 );
      text(row.getInt("sec"), width - marginE + 120, marginN + j * 10 );
      text(nf(row.getFloat("o"),1,2), width - marginE + 160, marginN + j * 10 );
      text(row.getString("type"), width - marginE + 210, marginN + j * 10 );
    j++;   
    i++;
    }
    j = 0;
    i = 0;
   
  }else{
    
    for(int i = events.getRowCount() - 10 , j=0 ; i <  events.getRowCount() ; i++,j++){
      TableRow row = events.getRow(i);
      
      
      //Fecha
      text(row.getInt("y"), width - marginE + 20 , marginN + j * 15 + 50  );
      text("/", width - marginE +50 , marginN + j * 15 + 50  );
      text(row.getInt("m"), width - marginE + 55 , marginN + j * 15 + 50 );
      text("/", width - marginE +62 , marginN + j * 15 + 50  );
      text(row.getInt("d"), width - marginE + 70 , marginN + j * 15 + 50);
      
      //Hora
      text(row.getInt("h"), width - marginE + 90, marginN + j * 15  + 50);
      text(":", width - marginE + 105 , marginN + j * 15 + 50  );
      text(row.getInt("min"), width - marginE + 110, marginN + j * 15 + 50 );
      text(":", width - marginE +125 , marginN + j * 15 + 50  );
      text(row.getInt("sec"), width - marginE + 130, marginN + j * 15  + 50 );
      
      //Valor y evento
      text(nf(row.getFloat("o"),1,2), width - marginE + 160, marginN + j * 15  + 50 );
      text(row.getString("type"), width - marginE + 210, marginN + j * 15   + 50);
      
    }

    
    
    
  }
  
  
  
  
}


void graphRefresh(float[] analog){
  
  float plotVar0 = analog[0] * (height - marginN - marginS);
  float plotVar1 = analog[1] * (height - marginN - marginS);
 
  stroke(255, 96, 0);  
  
  if(peace)
    line(frameCount-timediv,  height - marginS - prevY0 - 3, frameCount, height - marginS - plotVar0 - 3);
  
  else peace = true;
 
  stroke(0, 0, 255);  
  
  if(peace)
    line(frameCount-timediv, height - marginS  -  prevY1 - 3, frameCount, height - marginS - plotVar1 - 3);
  else peace = true;
  
  
  stroke(0);
 /* for(int i = 0; i < 10; i++)
    line(frameCount+i, marginN, frameCount+1+i, height - marginS);    
  */
  
  
  if(frameCount > (width - marginE)){
    frameCount = marginW;
    fill(20);
    rect(marginW + 1, marginN + 1, width - (marginW + marginE) - 2, height - ( marginN + marginS) -2 );

   stroke(255);
   
   for(int i = 6; i>=0; i--){
     line(marginW ,  marginN + (height-marginN-marginS)/6*(6-i) , width - marginE , marginN + (height-marginN-marginS)/6*(6-i) );
     line(marginW  + (width - marginW - marginE)/6*(i), marginN , marginW  + (width - marginW - marginE)/6*(i), height - marginS - 2  );
   }
    
    peace = false;
   }
  
  if(alarm)
    fill(27, 232, 116);
  else fill(153);
  
  ellipse(marginW + 230 , height - marginS + 20, 15, 15 );
  
  if(angleb)
    fill(123, 13, 30);
  else fill(153);
  
  ellipse(marginW + 100 , height - marginS + 40, 15, 15 );
  
  if(close)
    fill(123, 13, 30);
  else fill(153);
  
  ellipse(marginW + 260, height - marginS + 40, 15, 15 );
  

  
  
  frameCount += timediv - 1;
  prevY0 = plotVar0;
  prevY1 = plotVar1;
  
}


int h;
int t;
int put;

void fate(){

  short number;
  short inByte = 0;
  boolean free = false;
  int  buff=0;
  int i;
  
 
  
  while (myPort.available() > 0) {
   
    
    do{
      number = (short) myPort.read();
     
    }while( (number >> 4) != 0xF && myPort.available() > 0);
   
  
      
      for(i = 0; i < 2; i++){
        
        do{
          inByte = (short) myPort.read();
        }while((inByte>>7) != 0 && myPort.available() > 0);
  
       
        dig[i*2] = (((inByte & 0x40) >> 6) == 1 );
        dig[1+2*i] = (((inByte & 0x20) >> 5) == 1 );
        
        buff = inByte & 0x1F;
        
        do{
          inByte = (short) myPort.read();
        }while((inByte>>7) != 0 && myPort.available() > 0); 
      
    
        analog[i] = (float) inByte + (buff << 7);
        analog[i] = analog[i] / 4096.0;
   
        inByte = 0;

    }
      do{
        inByte = (short) myPort.read();
      }while((inByte>>7) != 0 && myPort.available() > 0); 
      
      buff =  inByte & 0x7F;
      
      do{
        inByte = (short) myPort.read();
      }while((inByte>>7) != 0 && myPort.available() > 0); 
      
      analog[i] = (float) inByte + (buff << 7);
      analog[i] = analog[i] * 0.066;
      inByte = 0;
      
    free = true;
    
    if(put > 0){
     free = !free;
     put = 0;
     myPort.clear();
     break;
    }
      
  
  }

  put++;


}

void keyPressed() {
 
  if (key == CODED) {
    if (keyCode == UP && timediv < 10) {
      timediv++;
    } else if (keyCode == DOWN && timediv>1) {
      timediv--;
    } 
  } 
}

float average(float[] a){
  
 float sum = 0;
 
 for(int i=0; i< a.length ; i++)
   sum += a[i];
   
 return sum/a.length; 
}

void addLight(float[] a, float b){
  
   for(int i=0; i< a.length - 1 ; i++)
      a[i] = a[i+1];
      
  a[a.length - 1] = b;
  
}

boolean angleb;
boolean lastAngle; 

void checkAcce(float[] a, float in){
  
  addLight(a,in);
  
  
  float b = (average(a)*3 - 2.09)/0.7;
  float angle = asin(b) * 180 / PI;
 
  if(angle > -70)
    angleb = true;
  else angleb = false;
    
    
  if(angleb && !lastAngle && lastsec != second() ){
       events = loadTable("data/events.csv", "header");
       TableRow newRow = events.addRow();
       newRow.setInt("y", year());
       newRow.setInt("m", month());
       newRow.setInt("d", day());
       newRow.setInt("h", hour());
       newRow.setInt("min", minute());
       newRow.setInt("sec", second());
       newRow.setString("type", "Angulo");
       newRow.setFloat("o" , angle);
       lastsec = second();
       saveTable(events,"data/events.csv");
  }
    
    
 lastAngle = angleb;
  
  
  
}


void checkFlash(float[] a, float in){
  
   addLight(a,in);
   
   // println(average(a)); 
   
   
   if( in < (average(a)*0.80) && (average(a) > 0.15) && lastsec != second() ){
         events = loadTable("data/events.csv", "header");
         TableRow newRow = events.addRow();
         newRow.setInt("y", year());
         newRow.setInt("m", month());
         newRow.setInt("d", day());
         newRow.setInt("h", hour());
         newRow.setInt("min", minute());
         newRow.setInt("sec", second());
         newRow.setString("type", "flash");
         lastsec = second();
         newRow.setFloat("o" , in/average(a));
         saveTable(events,"data/events.csv");
   }
     
   
}


  boolean close;
  boolean lastClose;
  boolean lastDig = false;
  boolean flag = false;
  int counter = 0; 
  float lastX;

void checkUltra(float ultra){

  fill(40,62,74);
  noStroke();
  rect(marginW, height - marginS/1.30, 2000, 150);
  
  if(ultra/1081.0 < 0.6){
    
    if(ultra < 150)
      close = true;
    else close = false;
    
    if(close && !lastClose){
       events = loadTable("data/events.csv", "header");
       TableRow newRow = events.addRow();
       newRow.setInt("y", year());
       newRow.setInt("m", month());
       newRow.setInt("d", day());
       newRow.setInt("h", hour());
       newRow.setInt("min", minute());
       newRow.setInt("sec", second());
       newRow.setString("type", "Proximidad");
       newRow.setFloat("o" , ultra/100);
       saveTable(events,"data/events.csv");

    }
    

    
  
  
    image(img, marginW + (width - marginE1 - marginW) * (ultra /1081.0), height - marginS/1.5, 100, 100);
    stroke(255);
    fill(255);
    text(nf(ultra/100,1,2),   marginW + (width - marginE1 - marginW) * (ultra /1081.0) + 25 , height - marginS/1.5 - 20);
    text("m", marginW + (width - marginE1 - marginW) * (ultra /1081.0) + 55 , height - marginS/1.5 - 20);
    text("Distancia Actual", marginW + (width - marginE1 - marginW) * (ultra /1081.0),  height - marginS/1.5 - 10);
  }

  fill(206,13,10);
  rect(marginW + 50, height - marginS/1.5 + 100, (width - marginE1 - marginW)/7, 25);
  
  fill(107,13,10);
  rect(marginW + 50, height - marginS/1.5 + 100, (width - marginE1 - marginW)/21, 25);
  
  fill(100,168,75);
  rect(marginW + 50 + (width - marginE1 - marginW)/7, height - marginS/1.5 + 100, 4*(width - marginE1 - marginW)/7, 25);
  
  lastClose = close;
  lastX = marginW + (width - marginE1 - marginW) * (ultra /10812);
}
  