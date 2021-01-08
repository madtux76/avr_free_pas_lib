unit Servoa;

interface
const
  Min_pulse = 800;
  Max_pulse = 5000;
var
  pin_servo :byte ; // pin to servo connected;
procedure initservo(i:byte);      // init servosystem
procedure move_servo(i:integer); // move servo 0-180 G
function read_servo():integer;   // read current servo position

implementation
uses Delay;

var
  tik:integer;
  pbr:integer;
procedure Timer0_Interrupt; public name 'TIMER0_COMPA_ISR'; interrupt;
  begin
    TCNT0 := $54;
    PORTD := PORTD or (1 shl pin_servo);
    delay_us(tik);
    PORTD := PORTD and not (1 shl pin_servo);
  end;

function mapg(i:integer):integer;
  begin
  if i = 0 then mapg := Min_pulse
  else
      if i >180 then mapg := Max_pulse
      else
         mapg := Min_pulse+(i*pbr);
  end;

procedure initservo(i:byte);
begin
// disable interrupt
   asm
     cli
   end;
 //
   pbr:=Max_pulse div 180; //pulse on 1 G
   pin_servo := i;
   DDRD := DDRD or (1 shl pin_servo);

   // Initialize timer0
   TCCR0A := 0;                        // Normal mode
   TCCR0B := %101;                     // CPU clock / 1024
   TIMSK0  := TIMSK0 or (1 shl OCIE0A);  // Timer0 should trigger an interrupt

   // enable interrupt
   asm
    sei
  end;
//
PORTD := PORTD or (1 shl pin_servo); // set pin servo to low
end;

procedure move_servo(i:integer); // move servo 0-180 G
begin
tik := mapg(i);
end;

function read_servo():integer;   // read current servo positio
begin
if tik = Min_pulse then read_servo:=0
 else
    if tik = Max_pulse then read_servo:=180
    else
      read_servo := tik div pbr;
end;
end.


