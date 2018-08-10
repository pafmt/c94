module src.mcu.interrupts;

version (LDC)
{
	import ldc.attributes;
}
else
{
	private string section(string str) { return str; }
}
import src.mcu.op;


///
alias Callback = void delegate() @nogc nothrow;

///
__gshared Callback onTim2;

///
void set(ref Callback target, void function(void* param) @nogc nothrow callback, void* param) pure @nogc nothrow @trusted
{
	union CallbackImpl
	{
		Callback dg;
		struct
		{
			void* contextPtr;
			typeof(callback) funcPtr;
		}
	}
	CallbackImpl impl = {contextPtr: param, funcPtr:callback};
	target = impl.dg;
}

///
void set(ref Callback target, void function() @nogc nothrow callback) pure @nogc nothrow @trusted
{
	union CallbackImpl
	{
		Callback dg;
		struct
		{
			void* contextPtr;
			typeof(callback) funcPtr;
		}
	}
	CallbackImpl impl = {contextPtr: null, funcPtr:callback};
	target = impl.dg;
}

/// ditto
void set(ref Callback target, void delegate() @nogc nothrow callback)
{
	target = callback;
}

///
extern(C) void entry() @nogc nothrow;

///
extern(C) void isrDefaultHandler() @nogc nothrow
{
	bkpt();
	while (1)
		wfi();
}

///
extern (C) void isrTim2() @nogc nothrow
{
	import src.mcu.regs;
	NVIC.SETPEND28 = true;
	TIM2.UIF = false;
	if (onTim2 !is null)
		onTim2();
	NVIC.CLRPEND28 = true;
}


///
extern(C) alias ISR = void function() @nogc nothrow;
///
@section(".isr_vector.power_on_reset")
extern(C) immutable ISR _power_on_reset = &entry;
///
@section(".isr_vector.interrupts")
extern(C) immutable ISR[14] _isr_exception = [
	&isrDefaultHandler, // 0x0008 NMI
	&isrDefaultHandler, // 0x000C HardFault
	&isrDefaultHandler, // 0x0010 MemManage
	&isrDefaultHandler, // 0x0014 BusFault
	&isrDefaultHandler, // 0x0018 UsageFault
	null,               // 0x001C reserved
	null,               // 0x0020 reserved
	null,               // 0x0024 reserved
	null,               // 0x0028 reserved
	&isrDefaultHandler, // 0x002C SVCall
	&isrDefaultHandler, // 0x0030 Debug Monitor
	null,               // 0x0034 reserved
	&isrDefaultHandler, // 0x0038 PendSV
	&isrDefaultHandler, // 0x003C Systick
];
///
@section(".isr_vector.interrupts")
extern(C) immutable ISR[85] _isr_inerrupts = [
	&isrDefaultHandler, // 0x0040 WWDG
	&isrDefaultHandler, // 0x0044 EXTI16 / PVD
	&isrDefaultHandler, // 0x0048 EXTI21 / TAMP_STAMP
	&isrDefaultHandler, // 0x004C EXTI22 / RTC_WKUP
	&isrDefaultHandler, // 0x0050 FLASH
	&isrDefaultHandler, // 0x0054 RCC
	&isrDefaultHandler, // 0x0058 EXTI0
	&isrDefaultHandler, // 0x005C EXTI1
	&isrDefaultHandler, // 0x0060 EXTI2
	&isrDefaultHandler, // 0x0064 EXTI3
	&isrDefaultHandler, // 0x0068 EXTI4
	&isrDefaultHandler, // 0x006C DMA1_Stream0
	&isrDefaultHandler, // 0x0070 DMA1_Stream1
	&isrDefaultHandler, // 0x0074 DMA1_Stream2
	&isrDefaultHandler, // 0x0078 DMA1_Stream3
	&isrDefaultHandler, // 0x007C DMA1_Stream4
	&isrDefaultHandler, // 0x0080 DMA1_Stream5
	&isrDefaultHandler, // 0x0084 DMA1_Stream6
	&isrDefaultHandler, // 0x0088 ADC
	null,               // 0x008C reserved
	null,               // 0x0090 reserved
	null,               // 0x0094 reserved
	null,               // 0x0098 reserved
	&isrDefaultHandler, // 0x009C EXTI9_5
	&isrDefaultHandler, // 0x00A0 TIM1_BRK_TIM9
	&isrDefaultHandler, // 0x00A4 TIM1_UP_TIM10
	&isrDefaultHandler, // 0x00A8 TIM1_TRG_COM_TIM11
	&isrDefaultHandler, // 0x00AC TIM1_CC
	&isrTim2,           // 0x00B0 TIM2
	&isrDefaultHandler, // 0x00B4 TIM3
	&isrDefaultHandler, // 0x00B8 TIM4
	&isrDefaultHandler, // 0x00BC I2C1_EV
	&isrDefaultHandler, // 0x00C0 I2C1_ER
	&isrDefaultHandler, // 0x00C4 I2C2_EV
	&isrDefaultHandler, // 0x00C8 I2C2_ER
	&isrDefaultHandler, // 0x00CC SPI1
	&isrDefaultHandler, // 0x00D0 SPI2
	&isrDefaultHandler, // 0x00D4 USART1
	&isrDefaultHandler, // 0x00D8 USART2
	null,               // 0x00DC reserved
	&isrDefaultHandler, // 0x00E0 EXTI15_10
	&isrDefaultHandler, // 0x00E4 EXTI17 / RTC_Alarm
	&isrDefaultHandler, // 0x00E8 EXTI18 / OTG_FSWKUP
	null,               // 0x00EC reserved
	null,               // 0x00F0 reserved
	null,               // 0x00F4 reserved
	null,               // 0x00F8 reserved
	&isrDefaultHandler, // 0x00FC DMA1_Stream7
	null,               // 0x0100 reserved
	&isrDefaultHandler, // 0x0104 SDIO
	&isrDefaultHandler, // 0x0108 TIM5
	&isrDefaultHandler, // 0x010C SPI3
	null,               // 0x011C reserved
	null,               // 0x0110 reserved
	null,               // 0x0114 reserved
	null,               // 0x0118 reserved
	&isrDefaultHandler, // 0x0120 DMA2_Stream0
	&isrDefaultHandler, // 0x0124 DMA2_Stream1
	&isrDefaultHandler, // 0x0128 DMA2_Stream2
	&isrDefaultHandler, // 0x012C DMA2_Stream3
	&isrDefaultHandler, // 0x0130 DMA2_Stream4
	null,               // 0x0134 reserved
	null,               // 0x0138 reserved
	null,               // 0x013C reserved
	null,               // 0x0140 reserved
	null,               // 0x0144 reserved
	null,               // 0x0148 reserved
	&isrDefaultHandler, // 0x014C OTG_FS
	&isrDefaultHandler, // 0x0150 DMA2_Stream5
	&isrDefaultHandler, // 0x0154 DMA2_Stream6
	&isrDefaultHandler, // 0x0158 DMA2_Stream7
	&isrDefaultHandler, // 0x015C USART6
	&isrDefaultHandler, // 0x0160 I2C3_EV
	&isrDefaultHandler, // 0x0164 I2C3_ER
	null,               // 0x0168 reserved
	null,               // 0x016C reserved
	null,               // 0x0170 reserved
	null,               // 0x0174 reserved
	null,               // 0x0178 reserved
	null,               // 0x017C reserved
	null,               // 0x0180 reserved
	&isrDefaultHandler, // 0x0184 FPU
	null,               // 0x0188 reserved
	null,               // 0x018C reserved
	&isrDefaultHandler, // 0x0190 SPI4
];

