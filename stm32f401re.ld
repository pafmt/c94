/* Linker script for STM32F401 */
ENTRY(entry);

MEMORY
{
  ROM (r!wxai) :
    ORIGIN = 0x08000000,
    LENGTH = 512K
  RAM (rwxai)  :
    ORIGIN = 0x20000000,
    LENGTH = 96k
}
_stackStart = ORIGIN(RAM)
            + LENGTH(RAM);



SECTIONS
{
	/* We don't need exceptions, and discarding these sections
	   prevents linker errors with LDC */
	/DISCARD/ :
	{
		*(.ARM.extab*)
		*(.ARM.exidx*)
	}
	.isr_vector ORIGIN(ROM): ALIGN(4)
	{
		/* Initial stack pointer */
		LONG(_stackStart);
		/* Interrupt vector table (Entry point) */
		KEEP(*(*.power_on_reset));
		KEEP(*(*.exceptions));
		KEEP(*(*.interrupts));
	}>ROM
	
	
	.text : ALIGN(4)
	{
		_stext = .;
		
		/* the code */
		*(.text)
		*(.text*)
		. = ALIGN(4);
		
		/* constant datas */
		*(.rodata)
		*(.rodata*)
		. = ALIGN(4);
		
		/* glue arm to thumb code */
		*(.glue_7);
		*(.glue_7*);
		. = ALIGN(4);
		
		_etext = .;
		_sidata = LOADADDR(.data);
	}>ROM
	
	
	.bss : ALIGN(4)
	{
		/* non-initilized data */
		_sbss = .;
		
		*(.bss)
		*(.bss.*)
		. = ALIGN(4);
		
		_ebss = .;
	}>RAM
	
	.data : ALIGN(4)
	{
		_sdata = .;
		
		/* initilized data */
		*(.data);
		*(.data.*);
		. = ALIGN(4);
		
		_edata = .;
	}>RAM AT>ROM
	
	/* Need .ctors and probably more as program becomes
	 * More complex */
}