module src.mcu.startup;

import src.mcu.op;
import src.mcu.regs;
version (LDC)
	import ldc.llvmasm;
private extern (C) void myMain() nothrow @nogc;


/*******************************************************************************
 * クロックの初期化
 */
private void initClock() nothrow @nogc
{
	SCB.CP10 = 0b11;
	SCB.CP11 = 0b11;
	
	// リセット直後は内臓クロックが有効になっている。
	// 外部クロックOFFして
	// 準備ができるまでループ
	/* Set HSION bit */
	RCC.HSION = true;
	while (!RCC.HSIRDY)
		nop();
	
	/* Reset CFGR register */
	RCC.CFGR = 0x00000000;
	
	/* Reset HSEON, CSSON and PLLON bits */
	RCC.CR = RCC.CR & 0xFEF6FFFF;
	
	/* Reset PLLCFGR register */
	RCC.PLLCFGR = 0x24003010;
	
	/* Reset HSEBYP bit */
	RCC.CR = RCC.CR & 0xFFFBFFFF;
	
	/* Disable all interrupts */
	RCC.CIR = 0x00000000;
	
	// PLL停止
	RCC.PLLI2SON = false;
	RCC.PLLON = false;
	while (RCC.PLLRDY)
		nop();
	while (RCC.PLLI2SRDY)
		nop();
	
	// FLASHの速度設定
	FLASH.LATENCY = 2;
	FLASH.PRFTEN  = true;
	FLASH.ICEN    = true;
	
	// 電源供給
	RCC.PWREN = true;
	nop();
	PWR.VOS = 0b10;
	nop();
	while (PWR.VOSRDY)
		nop();
	
	// 外部クロック開始
	RCC.HSEBYP = true;
	RCC.HSEON = true;
	while (!RCC.HSERDY)
		nop();
	
	// 周辺(AHB)は84MHzで動作
	RCC.HPRE = 0b000;
	// 周辺(APB1)は42MHzで動作
	RCC.PPRE1 = 0b100;
	// 周辺(APB2)は84MHzで動作
	RCC.PPRE2 = 0b000;
	// RTC不使用
	RCC.RTCPRE = 0b000;
	
	// 00000111_01000001_00101010_00001000
	// 00000000_01000000_00000000_00000000 // PLLSRC = 1
	// 00000111_00000000_00000000_00000000 // PLLQ = 7 = 111
	// 00000000_00000001_00000000_00000000 // PLLP = 4 -> 0b01
	// 00000000_00000000_01010100_00‬000000 // PLLN = 336 = 101010000
	// 00000000_00000000_00000000_00001000 // PLLM = 8 = 1000
	// 外部クロックを使用
	RCC.PLLSRC = 1;
	// PLLClock = Fin / M * N / P
	// メインクロックは8分周する(VOC = 8 / 8 = 1MHz < 2MHz)
	RCC.PLLM   = 8;
	// 336 / 4 を設定する = VOC * 336
	//RCC.PLLN   = 336;
	RCC.PLLN   = 336;
	// PLLCLKは MainClock / 4 = 84MHz
	RCC.PLLP   = 0b01;
	// USBは7分周する(MainClock * 336 / 7 = 48MHz)
	RCC.PLLQ   = 7;
	// PLL開始
	RCC.PLLON = true;
	while (!RCC.PLLRDY)
		nop();
	RCC.SW = 0b10;
	while (RCC.SWS != 0b10)
		nop();
}

private void initData(void* sdata, void* edata, in void* sidata) @nogc nothrow
{
	uint* dst = cast(uint*)sdata;
	uint* src = cast(uint*)sidata;
	while (dst < cast(uint*)edata)
		*dst++ = *src++;
}
private void initBss(void* sbss, void* ebss) @nogc nothrow
{
	uint* dst = cast(uint*)sbss;
	while (dst < cast(uint*)ebss)
		*dst++ = 0;
}

/// primitive functions
extern (C) void __aeabi_memclr4(void* p, size_t n)
{
	auto ptr = cast(uint*)p;
	auto cnt = n/4;
	while (cnt--)
		*ptr++ = 0;
}

/// ditto
extern (C) void __aeabi_memclr(void* p, size_t n)
{
	auto ptr = cast(ubyte*)p;
	while (n--)
		*ptr++ = 0;
}

/// ditto
extern (C) void __aeabi_memset4(void* p, size_t n, uint c)
{
	auto ptr = cast(uint*)p;
	auto cnt = n/4;
	while (cnt--)
		*ptr++ = c;
}

/// ditto
extern (C) void __aeabi_memset(void* p, size_t n, uint c)
{
	auto ptr = cast(ubyte*)p;
	while (n--)
		*ptr++ = cast(ubyte)c;
}

/// ditto
extern (C) void __aeabi_memcpy4(void* dst, const void* src, size_t n)
{
	auto dptr = cast(uint*)dst;
	auto sptr = cast(uint*)src;
	auto cnt = n/4;
	while (cnt--)
		*dptr++ = *sptr;
}

/// ditto
extern (C) void __aeabi_memcpy(void* dst, const void* src, size_t n)
{
	auto dptr = cast(ubyte*)dst;
	auto sptr = cast(ubyte*)src;
	while (n--)
		*dptr++ = *sptr;
}

/// ditto
extern (C) int memcmp(const void* buf1, const void* buf2, size_t len)
{
	auto ptr1 = cast(const(ubyte)*)buf1;
	auto ptr2 = cast(const(ubyte)*)buf2;
	while (len--)
	{
		if (*ptr1++ != *ptr2++)
			return false;
	}
	return true;
}


///
extern (C) void entry() nothrow @nogc
{
	version(LDC) pragma(LDC_never_inline);
	initClock();
	initBss(getAddrOfExtLinkage!"_sbss"(),
	        getAddrOfExtLinkage!"_ebss"());
	initData(getAddrOfExtLinkage!"_sdata"(),
	         getAddrOfExtLinkage!"_edata"(),
	         getAddrOfExtLinkage!"_sidata"());
	myMain();
	while (1)
	{
		// Do nothing for unlimited loop.
		// Program is terminated by this loop.
	}
}



version (X86)
{
	///
	extern (C) pragma(mangle, "_sbss")   __gshared uint _sbss   = 1;
	///
	extern (C) pragma(mangle, "_ebss")   __gshared uint _ebss   = 1;
	///
	extern (C) pragma(mangle, "_sidata") __gshared uint _sidata = 1;
	///
	extern (C) pragma(mangle, "_sdata")  __gshared uint _sdata  = 1;
	///
	extern (C) pragma(mangle, "_edata")  __gshared uint _edata  = 1;
}

version (unittest) version (DigitalMars)
{
	private extern (C) void dmd_coverDestPath( string pathname );
	private extern (C) void dmd_coverSetMerge( bool flag );
	shared static this()
	{
		import std.file;
		import core.stdc.stdio;
		setvbuf(stdout, null, _IONBF, 0);
		if (!"cov".exists)
		{
			mkdir("cov");
		}
		else
		{
			dmd_coverSetMerge(true);
		}
		dmd_coverDestPath("cov");
	}
}