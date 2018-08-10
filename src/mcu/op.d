module src.mcu.op;

version (LDC)
{
	import ldc.llvmasm;
	///
	pragma(LDC_intrinsic, "ldc.bitop.vld")
		void* volatileLoad(in void** ptr) pure nothrow @nogc @trusted;
	///
	pragma(LDC_intrinsic, "ldc.bitop.vld")
		ubyte volatileLoad(in ubyte* ptr) pure nothrow @nogc @trusted;
	///
	pragma(LDC_intrinsic, "ldc.bitop.vld")
		ushort volatileLoad(in ushort* ptr) pure nothrow @nogc @trusted;
	///
	pragma(LDC_intrinsic, "ldc.bitop.vld")
		uint volatileLoad(in uint* ptr) pure nothrow @nogc @trusted;
	///
	pragma(LDC_intrinsic, "ldc.bitop.vld")
		ulong volatileLoad(in ulong* ptr) pure nothrow @nogc @trusted;
	
	///
	pragma(LDC_intrinsic, "ldc.bitop.vst")
		void volatileStore(void** ptr, void* value) pure nothrow @nogc @trusted;
	///
	pragma(LDC_intrinsic, "ldc.bitop.vst")
		void volatileStore(ubyte* ptr, ubyte value) pure nothrow @nogc @trusted;
	///
	pragma(LDC_intrinsic, "ldc.bitop.vst")
		void volatileStore(ushort* ptr, ushort value) pure nothrow @nogc @trusted;
	///
	pragma(LDC_intrinsic, "ldc.bitop.vst")
		void volatileStore(uint* ptr, uint value) pure nothrow @nogc @trusted;
	///
	pragma(LDC_intrinsic, "ldc.bitop.vst")
		void volatileStore(ulong* ptr, ulong value) pure nothrow @nogc @trusted;
	///
	pragma(LDC_intrinsic, "ldc.bitop.bt")
		int bt(in size_t* p, size_t bitnum) pure nothrow @nogc @trusted;
	///
	pragma(LDC_intrinsic, "ldc.bitop.btc")
		int btc(size_t* p, size_t bitnum) pure nothrow @nogc @trusted;
	///
	pragma(LDC_intrinsic, "ldc.bitop.btr")
		int btr(size_t* p, size_t bitnum) pure nothrow @nogc @trusted;
	///
	pragma(LDC_intrinsic, "ldc.bitop.bts")
		int bts(size_t* p, size_t bitnum) pure nothrow @nogc @trusted;
	
	///
	pragma(inline) void bkpt() pure nothrow @nogc @trusted
	{
		pragma(LDC_allow_inline);
		__asm("bkpt", "");
	}
	
	///
	pragma(inline) void nop() pure nothrow @nogc @trusted
	{
		pragma(LDC_allow_inline);
		__asm("nop", "");
	}
	
	///
	pragma(inline) void wfi() pure nothrow @nogc @trusted
	{
		pragma(LDC_allow_inline);
		__asm("wfi", "");
	}
	
	///
	pragma(inline) void disable_irq() pure nothrow @nogc @trusted
	{
		pragma(LDC_allow_inline);
		__asm("cpsid i", "");
	}
	
	///
	pragma(inline) void enable_irq() pure nothrow @nogc @trusted
	{
		pragma(LDC_allow_inline);
		__asm("cpsie i", "");
	}
	
	///
	pragma(inline) void* getAddrOfExtLinkage(string name)() nothrow @nogc @trusted
	{
		enum asmcode = `
			ldr $0, =`~name~`
		`;
		return __asm!(void*)(asmcode, "=&r");
	}

}
else
{
	public import core.bitop: bt, btc, btr, bts;
	
	pragma(inline) private T volatileLoadImpl(T)(T* ptr) nothrow @nogc @trusted
	{
		import core.bitop;
		return core.bitop.volatileLoad(ptr);
	}
	///
	pragma(inline) T volatileLoad(T)(T* ptr) nothrow @nogc @trusted
	{
		import core.bitop;
		import std.traits;
		return (cast(T function(Unqual!T*)pure nothrow @nogc)&volatileLoadImpl!(Unqual!T))(cast(Unqual!T*)ptr);
	}
	
	pragma(inline) private void volatileStoreImpl(T)(T* ptr, T val) nothrow @nogc @trusted
	{
		import core.bitop;
		core.bitop.volatileStore(ptr, val);
	}
	
	///
	pragma(inline) void volatileStore(T)(T* ptr, T val) nothrow @nogc @trusted
	{
		import std.traits;
		(cast(T function(Unqual!T*, Unqual!T)pure nothrow @nogc)&volatileStoreImpl!(Unqual!T))(cast(Unqual!T*)ptr, val);
	}
	
	///
	pragma(inline) void bkpt() pure nothrow @nogc @trusted
	{
	}
	
	///
	pragma(inline) void nop() pure nothrow @nogc @trusted
	{
	}
	
	///
	pragma(inline) void wfi() pure nothrow @nogc @trusted
	{
	}
	
	///
	template getAddrOfExtLinkage(string name)
	{
		mixin(`
			extern extern (C) pragma(mangle, "`~name~`")
			__gshared uint `~name~`;
			pragma(inline) void* getAddrOfExtLinkage() nothrow @nogc @trusted
			{
				return &`~name~`;
			}
		`);
	}

	///
}


