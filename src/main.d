module src.main;

import src.mcu.peripherals;
import src.mcu.op;

///
void initAwake() nothrow @nogc
{
	// ハードウェアの初期化
	initHardware();
	
}

///
void runAwake() nothrow @nogc
{
	// Do nothing
}

///
void initStead() nothrow @nogc
{
	
}

///
void wait() nothrow @nogc
{
	foreach (i; 0..1000000)
		nop();
}

///
void runStead() nothrow @nogc
{
	while (1)
	{
//		setLedOn();
//		wait();
//		setLedOff();
		wait();
	}
}
///
void initShutdown() nothrow @nogc
{
	
}
///
void runShutdown() nothrow @nogc
{
	// Do nothing
}

///
extern (C) void myMain() nothrow @nogc
{
	initAwake();
	runAwake();
	initStead();
	runStead();
	initShutdown();
	runShutdown();
}
