unit i2Clib;
 Interface
   procedure I2Cinit();
   procedure I2Start(addr:byte);
   procedure I2Stop;
   procedure I2CWrite(data:byte);
   function I2CRead : byte;
   function I2ReadEnd:byte;

 implementation
  const
 CPU_Clock = 8000000; //частота контроллера
 I2C_Clock = 400000; //i2c частота
 I_Read =0;
 I_Write=1;

 procedure I2Cinit;
 const
 IWB_val = byte((CPU_Clock div I2C_Clock)-16) div 2;
 begin
 TWSR:=0;
 TWBR:= byte (IWB_val);
   end;

procedure I2Start(addr:byte);
begin
     TWCR:=0;
     TWCR :=(1 shl TWINT) or (1 shl TWSTA) or (1 shl TWEN);
     while ( TWCR and (1 shl TWINT)) =0  do
     begin
       end;
    TWDR:=addr;
    TWCR:= (1 shl TWINT) or (1 shl TWEN);

    while ( TWCR and (1 shl TWINT)) =0  do
     begin
       end;
 end;

procedure I2Stop;
 begin
    TWCR :=(1 shl TWINT) or (1 shl TWSTO) or (1 shl TWEN);
     end;

procedure I2CWrite(data:byte);
begin
   TWDR:=data;
   TWCR:= (1 shl TWINT) or (1 shl TWEN);

    while ( TWCR and (1 shl TWINT)) =0  do
     begin
       end;
   end;
function  I2CRead : byte;
var
Eflag:byte;
begin
   Eflag:=0;
   TWCR:= (1 shl TWINT) or (1 shl TWEN) or (1 shl TWA);
   while (( TWCR and (1 shl TWINT)) = 0) and (Eflag<255) do
    begin
      inc(Eflag);
      end;
   if Eflag = 255 then Result:=0
   else Result:=TWDR;
  end;

function I2ReadEnd:byte;
begin
   TWCR:= (1 shl TWINT) or (1 shl TWEN);
   while ( TWCR and (1 shl TWINT)) =0  do
     begin
       end;
        Result:=TWDR;
end;

end.
