Unit i2Cdisplay;

interface
const
F_CPU = 8000000;      //частота процессора в герцах,корректировать
                      //по необходимости
                      // cpu clock frequncy, change this constant, if you need
var
  CuteentDisplay:byte; // адрес активного дисплея,можно менять если нужно
                       // current dislay adress, change if more one display
  Lcd_row:byte;
  Lcd_col:byte;
  Light:byte;
  procedure Lcd_init(addr:byte;rw:byte;col:byte); // инициализация дисплея
                                                  //display init function

  procedure Lcd_write(data:byte); // прямая запись байта
                                  // raw byte output

  procedure Lcd_Light(mode:boolean);  // подсветка дисплея,если используется
                                      // true - вкл,false - выкл
                                      // light display if exist
                                      // true - is on, false - off
  procedure Lcd_clear();  //   очистка дисплея
                          // clear display procedure

  procedure Lcd_Pos(col:byte;row:byte); // установка начальной позиции
                                        // вывода
                                        // set start position of output

  procedure Lcd_Put(data:char); // вывод одного символа
                                // put shar

  procedure Lcd_Print(const data:shortstring);//вывод строки
                                             // print string on lcd
  procedure Lcd_Lscroll(); // сдвиг текста влево на одну позицию
                           // sctoll text left one position

  procedure Lcd_Rscroll(); //сдвиг текста вправо на одну позицию
                          // scroll text right one position

  procedure Lcd_FlowRtoL(); //вывод справа на лево
                            //flow text to left

  procedure Lcd_FlowLtoR(); //вывод слева на право
                            //flow text to right

  procedure Lcd_LoadXchar(location:byte , var charmap[] array of byte);

implementation
uses i2Clib,delay;
const
 // commands
LCD_CLEARDISPLAY = $01;
LCD_RETURNHOME = $02;
LCD_ENTRYMODESET = $04;
  LCD_DISPLAYCONTROL = $08;
  LCD_CURSORSHIFT = $10;
  LCD_FUNCTIONSET = $20;
  LCD_SETCGRAMADDR = $40;
  LCD_SETDDRAMADDR = $80;

// flags for display entry mode
  LCD_ENTRYRIGHT = $00;
  LCD_ENTRYLEFT = $02;
  LCD_ENTRYSHIFTINCREMENT = $01;
  LCD_ENTRYSHIFTDECREMENT = $00;

// flags for display on/off control
  LCD_DISPLAYON = $04;
  LCD_DISPLAYOFF = $00;
  LCD_CURSORON = $02;
  LCD_CURSOROFF = $00;
  LCD_BLINKON = $01;
  LCD_BLINKOFF = $00;

// flags for display/cursor shift
  LCD_DISPLAYMOVE = $08;
  LCD_CURSORMOVE = $00;
  LCD_MOVERIGHT = $04;
  LCD_MOVELEFT = $00;

// flags for function set
  LCD_8BITMODE = $10;
  LCD_4BITMODE = $00;
  LCD_2LINE = $08;
  LCD_1LINE = $00;
  LCD_5x10DOTS = $04;
  LCD_5x8DOTS = $00;

// flags for backlight control
  LCD_BACKLIGHT = $08;
  LCD_NOBACKLIGHT = $00;

  En = %00000100;  // Enable bit
  Rw = %00000010;  // Read/Write bit
  Rs = %00000001;  // Register select bit
var
   display_mod:byte;
  displaycontrol:byte;
procedure RegWrite(data:byte);
  begin
   I2Start(CuteentDisplay);
   I2CWrite(data or Light);
   I2Stop;
    end;
procedure RegTrig(data:byte);
begin
     RegWrite(data or En);
     delay_ms(1);
     RegWrite(data and not En);
     delay_us(500);
  end;
procedure write4bits(data:byte);
begin
     RegWrite(data);
     RegTrig(data);
     end;
procedure send(data:byte;mode:byte);
var
  hib:byte;
  lob:byte;
begin
     hib:=data and $f0;
     lob:=(data shl 4 ) and $f0;
     write4bits(hib or mode);
     write4bits(lob or mode);
     end;

procedure command(data:byte);
begin
     send(data,0)
     end;

procedure Lcd_show();
begin
     displaycontrol := displaycontrol or LCD_DISPLAYON;
	command(LCD_DISPLAYCONTROL or displaycontrol);
end;

procedure Lcd_clear();
begin
        command(LCD_CLEARDISPLAY);// clear display, set cursor position to zero
	delay_us(1000);  // this command takes a long time!
end;

procedure Lcd_home();
begin
        command(LCD_RETURNHOME);  // set cursor position to zero
	delay_us(1000);  // this command takes a long time!
end;

procedure Lcd_init(addr:byte;rw:byte;col:byte);

begin
  CuteentDisplay:=addr shl 1;
  Lcd_row:=rw;
  Lcd_col:=col;
  Light:= LCD_NOBACKLIGHT;
    I2Cinit();
  if Lcd_row = 1 then   display_mod:= LCD_4BITMODE or LCD_1LINE or LCD_5x8DOTS
  else
     display_mod:= LCD_4BITMODE or LCD_2LINE or LCD_5x8DOTS;
  delay_us(50);

   write4bits($03 shl 4);
   delay_us(4500); // wait min 4.1ms

   // second try
   write4bits($03 shl 4);
   delay_us(4500); // wait min 4.1ms

   // third go!
   write4bits($03 shl 4);
   delay_ms(150);

   // finally, set to 4-bit interface
   write4bits($02 shl 4);

   command(LCD_FUNCTIONSET or display_mod);

   displaycontrol:= LCD_DISPLAYON or LCD_CURSOROFF or LCD_BLINKOFF;
   Lcd_show;
   Lcd_clear;
   display_mod:= LCD_ENTRYLEFT or LCD_ENTRYSHIFTDECREMENT;
   command(LCD_ENTRYMODESET or display_mod);
   Lcd_home;
   Light:= LCD_BACKLIGHT;
   RegWrite(0);
  end;

procedure Lcd_write(data:byte);
begin
  send(data, Rs);
  end;
procedure Lcd_Cursor(mode:boolean);
begin
  if mode=true then
  begin
  displaycontrol:= displaycontrol or LCD_CURSORON;
	command(LCD_DISPLAYCONTROL or displaycontrol);
  end
  else
  begin
    displaycontrol:= displaycontrol and not LCD_CURSORON;
	command(LCD_DISPLAYCONTROL or displaycontrol);
  end;
end;

procedure Lcd_CursorBlink(mode:boolean);
begin
  if mode=true then
  begin
  displaycontrol:= displaycontrol or LCD_BLINKON;
	command(LCD_DISPLAYCONTROL or displaycontrol);
  end
  else
  begin
    displaycontrol := displaycontrol and not LCD_BLINKON;
	command(LCD_DISPLAYCONTROL or displaycontrol);
  end;
end;

procedure Lcd_Put(data:char);
begin
  Lcd_Write(ord(data));
end;
procedure Lcd_Print(const data:shortstring);
var i:byte;
begin
for i:=1 to byte(data[0]) do
begin
  Lcd_Put(data[i]);
end;
end;

procedure Lcd_Pos(col:byte;row:byte);
var
  row_offsets:array[0..3] of byte = ($00, $40, $14, $54 );
begin
  if row > Lcd_row  then
  		row := Lcd_row-1;    // we count rows starting w/0

  	command(LCD_SETDDRAMADDR or (col + row_offsets[row]));
end;
 procedure Lcd_Light(mode:boolean);
 begin
  if mode = true then
  begin
        Light := LCD_BACKLIGHT;
	RegWrite(0);
  end
  else
    begin
       Light:= LCD_NOBACKLIGHT;
	RegWrite(0);
      end;
    end;
 procedure Lcd_Lscroll();
 begin
 command(LCD_CURSORSHIFT or LCD_DISPLAYMOVE or LCD_MOVELEFT);
 end;
   procedure Lcd_Rscroll();
 begin
 command(LCD_CURSORSHIFT or LCD_DISPLAYMOVE or LCD_MOVERIGHT);
 end;

   procedure Lcd_FlowRtoL();
   begin
   display_mod := display_mod and not LCD_ENTRYLEFT;
	command(LCD_ENTRYMODESET or display_mod);
   end;
 procedure Lcd_FlowLtoR();
 begin
 display_mod := display_mod or LCD_ENTRYLEFT;
	command(LCD_ENTRYMODESET or display_mod);
 end;
procedure Lcd_LoadXchar(location:byte , var charmap[] array of byte);
var
  i:byte;
begin
location := location and 0x7; // we only have 8 locations 0-7
	command(LCD_SETCGRAMADDR | (location shl 3));
	for int i=0 to 8 do
		write(charmap[i]);
end;
end.

