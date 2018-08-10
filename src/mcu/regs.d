module src.mcu.regs;

//##############################################################################
//#####     ヘルパ
//##############################################################################

import src.mcu.op;
private template _offsetSumOfBitfield(Args...)
{
	static if (Args.length < 3)
	{
		enum _offsetSumOfBitfield = 0;
	}
	else
	{
		enum _offsetSumOfBitfield = Args[2] + _offsetSumOfBitfield!(Args[3..$]);
	}
}
static assert(_offsetSumOfBitfield!("", "", 1, "", "", 1) == 2);
static assert(_offsetSumOfBitfield!("", "", 1, "", "", 2, "", "", 3) == 6);
static assert(_offsetSumOfBitfield!("", "", 1, "", "", 5, "", "", 8) == 14);
static assert(_offsetSumOfBitfield!("", "", 6, "", "", 5, "", "", 4) == 15);

enum _maskOfBitfield(uint x) = (1 << x) - 1;
static assert(_maskOfBitfield!1 == 0b00000000000000000000000000000001);
static assert(_maskOfBitfield!2 == 0b00000000000000000000000000000011);
static assert(_maskOfBitfield!3 == 0b00000000000000000000000000000111);
static assert(_maskOfBitfield!4 == 0b00000000000000000000000000001111);
static assert(_maskOfBitfield!5 == 0b00000000000000000000000000011111);

///
template defineBitfields(alias dat, Args...)
{
	static foreach (i; 0..Args.length/3)
	{
		mixin(`pragma(inline) Args[i*3+0] ` ~ Args[i*3 + 1] ~ q{()() nothrow @nogc @trusted const @property
		{
			static if (is(Args[i*3+0] == bool))
			{
				static assert(_offsetSumOfBitfield!(Args[0..i*3]) < dat.sizeof*8);
				return cast(bool)bt(cast(size_t*)&dat, _offsetSumOfBitfield!(Args[0..i*3]));
			}
			else
			{
				enum mask = _maskOfBitfield!(Args[i*3+2]);
				if (!__ctfe)
				{
					return (volatileLoad(&dat) >> _offsetSumOfBitfield!(Args[0..i*3])) & mask;
				}
				else
				{
					return (dat >> _offsetSumOfBitfield!(Args[0..i*3])) & mask;
				}
			}
		}});
		mixin(`pragma(inline) void ` ~ Args[i*3 + 1] ~ q{()(Args[i*3+0] val) nothrow @nogc @trusted @property
		{
			static if (is(Args[i*3+0] == bool))
			{
				static assert(_offsetSumOfBitfield!(Args[0..i*3]) < dat.sizeof*8);
				if (val)
				{
					bts(cast(size_t*)&dat, _offsetSumOfBitfield!(Args[0..i*3]));
				}
				else
				{
					btr(cast(size_t*)&dat, _offsetSumOfBitfield!(Args[0..i*3]));
				}
			}
			else
			{
				enum ofsbits = _offsetSumOfBitfield!(Args[0..i*3]);
				enum bitsmask = _maskOfBitfield!(Args[i*3+2]);
				enum typeof(dat) mask = bitsmask << ofsbits;
				enum typeof(dat) invmask = cast(typeof(dat))~cast(int)mask;
				if (!__ctfe)
				{
					auto tmp = volatileLoad(&dat);
					volatileStore(&dat, cast(typeof(dat))((invmask & tmp) | (val << ofsbits)));
				}
				else
				{
					dat = cast(typeof(dat))((invmask & dat) | (val << ofsbits));
				}
			}
		}});
	}
}
static assert((_maskOfBitfield!(1) << _offsetSumOfBitfield!(
			uint, "PLLM", 6,
			uint, "PLLN", 9,
			uint, "PLLCFGR_reserved_bit15_15", 1,
			uint, "PLLP", 2,
			uint, "PLLCFGR_reserved_bit18_21", 4,
			)) == 0b00000000010000000000000000000000);
static assert(~(_maskOfBitfield!(1) << _offsetSumOfBitfield!(
			uint, "PLLM", 6,
			uint, "PLLN", 9,
			uint, "PLLCFGR_reserved_bit15_15", 1,
			uint, "PLLP", 2,
			uint, "PLLCFGR_reserved_bit18_21", 4,
			)) == 0b11111111101111111111111111111111);

///
mixin template defineVolatileAccessor(alias dat, string name)
{
	mixin(`pragma(inline) auto ` ~ name ~ q{()() nothrow @nogc @safe const @property
	{
		return volatileLoad(&dat);
	}});
	mixin(`pragma(inline) void ` ~ name ~ q{()(typeof(dat) val) nothrow @nogc @safe @property
	{
		return volatileStore(&dat, val);
	}});
}

//##############################################################################
//#####     コアレジスタ
//##############################################################################

/***************************************************************
 * NVIC
 */
struct NVIC_TYPE
{
	/// 
	private uint ISER0_impl;
	mixin defineVolatileAccessor!(ISER0_impl, "ISER0");
	mixin defineBitfields!(ISER0_impl,
		bool, "SETENA0",  1,
		bool, "SETENA1",  1,
		bool, "SETENA2",  1,
		bool, "SETENA3",  1,
		bool, "SETENA4",  1,
		bool, "SETENA5",  1,
		bool, "SETENA6",  1,
		bool, "SETENA7",  1,
		bool, "SETENA8",  1,
		bool, "SETENA9",  1,
		bool, "SETENA10", 1,
		bool, "SETENA11", 1,
		bool, "SETENA12", 1,
		bool, "SETENA13", 1,
		bool, "SETENA14", 1,
		bool, "SETENA15", 1,
		bool, "SETENA16", 1,
		bool, "SETENA17", 1,
		bool, "SETENA18", 1,
		bool, "SETENA19", 1,
		bool, "SETENA20", 1,
		bool, "SETENA21", 1,
		bool, "SETENA22", 1,
		bool, "SETENA23", 1,
		bool, "SETENA24", 1,
		bool, "SETENA25", 1,
		bool, "SETENA26", 1,
		bool, "SETENA27", 1,
		bool, "SETENA28", 1,
		bool, "SETENA29", 1,
		bool, "SETENA30", 1,
		bool, "SETENA31", 1);
	/// 
	private uint ISER1_impl;
	mixin defineVolatileAccessor!(ISER1_impl, "ISER1");
	mixin defineBitfields!(ISER1_impl,
		bool, "SETENA32", 1,
		bool, "SETENA33", 1,
		bool, "SETENA34", 1,
		bool, "SETENA35", 1,
		bool, "SETENA36", 1,
		bool, "SETENA37", 1,
		bool, "SETENA38", 1,
		bool, "SETENA39", 1,
		bool, "SETENA40", 1,
		bool, "SETENA41", 1,
		bool, "SETENA42", 1,
		bool, "SETENA43", 1,
		bool, "SETENA44", 1,
		bool, "SETENA45", 1,
		bool, "SETENA46", 1,
		bool, "SETENA47", 1,
		bool, "SETENA48", 1,
		bool, "SETENA49", 1,
		bool, "SETENA50", 1,
		bool, "SETENA51", 1,
		bool, "SETENA52", 1,
		bool, "SETENA53", 1,
		bool, "SETENA54", 1,
		bool, "SETENA55", 1,
		bool, "SETENA56", 1,
		bool, "SETENA57", 1,
		bool, "SETENA58", 1,
		bool, "SETENA59", 1,
		bool, "SETENA60", 1,
		bool, "SETENA61", 1,
		bool, "SETENA62", 1,
		bool, "SETENA63", 1);
	/// 
	private uint ISER2_impl;
	mixin defineVolatileAccessor!(ISER2_impl, "ISER2");
	mixin defineBitfields!(ISER2_impl,
		bool, "SETENA64", 1,
		bool, "SETENA65", 1,
		bool, "SETENA66", 1,
		bool, "SETENA67", 1,
		bool, "SETENA68", 1,
		bool, "SETENA69", 1,
		bool, "SETENA70", 1,
		bool, "SETENA71", 1,
		bool, "SETENA72", 1,
		bool, "SETENA73", 1,
		bool, "SETENA74", 1,
		bool, "SETENA75", 1,
		bool, "SETENA76", 1,
		bool, "SETENA77", 1,
		bool, "SETENA78", 1,
		bool, "SETENA79", 1,
		bool, "SETENA80", 1,
		bool, "SETENA_reserved_bit81", 1,
		bool, "SETENA_reserved_bit82", 1,
		bool, "SETENA_reserved_bit83", 1,
		bool, "SETENA_reserved_bit84", 1,
		bool, "SETENA_reserved_bit85", 1,
		bool, "SETENA_reserved_bit86", 1,
		bool, "SETENA_reserved_bit87", 1,
		bool, "SETENA_reserved_bit88", 1,
		bool, "SETENA_reserved_bit89", 1,
		bool, "SETENA_reserved_bit90", 1,
		bool, "SETENA_reserved_bit91", 1,
		bool, "SETENA_reserved_bit92", 1,
		bool, "SETENA_reserved_bit93", 1,
		bool, "SETENA_reserved_bit94", 1,
		bool, "SETENA_reserved_bit95", 1);
	private uint[24] ISER_reserved;
	/// 
	private uint ICER0_impl;
	mixin defineVolatileAccessor!(ICER0_impl, "ICER0");
	mixin defineBitfields!(ICER0_impl,
		bool, "CLRENA0",  1,
		bool, "CLRENA1",  1,
		bool, "CLRENA2",  1,
		bool, "CLRENA3",  1,
		bool, "CLRENA4",  1,
		bool, "CLRENA5",  1,
		bool, "CLRENA6",  1,
		bool, "CLRENA7",  1,
		bool, "CLRENA8",  1,
		bool, "CLRENA9",  1,
		bool, "CLRENA10", 1,
		bool, "CLRENA11", 1,
		bool, "CLRENA12", 1,
		bool, "CLRENA13", 1,
		bool, "CLRENA14", 1,
		bool, "CLRENA15", 1,
		bool, "CLRENA16", 1,
		bool, "CLRENA17", 1,
		bool, "CLRENA18", 1,
		bool, "CLRENA19", 1,
		bool, "CLRENA20", 1,
		bool, "CLRENA21", 1,
		bool, "CLRENA22", 1,
		bool, "CLRENA23", 1,
		bool, "CLRENA24", 1,
		bool, "CLRENA25", 1,
		bool, "CLRENA26", 1,
		bool, "CLRENA27", 1,
		bool, "CLRENA28", 1,
		bool, "CLRENA29", 1,
		bool, "CLRENA30", 1,
		bool, "CLRENA31", 1);
	/// 
	private uint ICER1_impl;
	mixin defineVolatileAccessor!(ICER1_impl, "ICER1");
	mixin defineBitfields!(ICER1_impl,
		bool, "CLRENA32", 1,
		bool, "CLRENA33", 1,
		bool, "CLRENA34", 1,
		bool, "CLRENA35", 1,
		bool, "CLRENA36", 1,
		bool, "CLRENA37", 1,
		bool, "CLRENA38", 1,
		bool, "CLRENA39", 1,
		bool, "CLRENA40", 1,
		bool, "CLRENA41", 1,
		bool, "CLRENA42", 1,
		bool, "CLRENA43", 1,
		bool, "CLRENA44", 1,
		bool, "CLRENA45", 1,
		bool, "CLRENA46", 1,
		bool, "CLRENA47", 1,
		bool, "CLRENA48", 1,
		bool, "CLRENA49", 1,
		bool, "CLRENA50", 1,
		bool, "CLRENA51", 1,
		bool, "CLRENA52", 1,
		bool, "CLRENA53", 1,
		bool, "CLRENA54", 1,
		bool, "CLRENA55", 1,
		bool, "CLRENA56", 1,
		bool, "CLRENA57", 1,
		bool, "CLRENA58", 1,
		bool, "CLRENA59", 1,
		bool, "CLRENA60", 1,
		bool, "CLRENA61", 1,
		bool, "CLRENA62", 1,
		bool, "CLRENA63", 1);
	/// 
	private uint ICER2_impl;
	mixin defineVolatileAccessor!(ICER2_impl, "ICER2");
	mixin defineBitfields!(ICER2_impl,
		bool, "CLRENA64", 1,
		bool, "CLRENA65", 1,
		bool, "CLRENA66", 1,
		bool, "CLRENA67", 1,
		bool, "CLRENA68", 1,
		bool, "CLRENA69", 1,
		bool, "CLRENA70", 1,
		bool, "CLRENA71", 1,
		bool, "CLRENA72", 1,
		bool, "CLRENA73", 1,
		bool, "CLRENA74", 1,
		bool, "CLRENA75", 1,
		bool, "CLRENA76", 1,
		bool, "CLRENA77", 1,
		bool, "CLRENA78", 1,
		bool, "CLRENA79", 1,
		bool, "CLRENA80", 1,
		bool, "CLRENA_reserved_bit81", 1,
		bool, "CLRENA_reserved_bit82", 1,
		bool, "CLRENA_reserved_bit83", 1,
		bool, "CLRENA_reserved_bit84", 1,
		bool, "CLRENA_reserved_bit85", 1,
		bool, "CLRENA_reserved_bit86", 1,
		bool, "CLRENA_reserved_bit87", 1,
		bool, "CLRENA_reserved_bit88", 1,
		bool, "CLRENA_reserved_bit89", 1,
		bool, "CLRENA_reserved_bit90", 1,
		bool, "CLRENA_reserved_bit91", 1,
		bool, "CLRENA_reserved_bit92", 1,
		bool, "CLRENA_reserved_bit93", 1,
		bool, "CLRENA_reserved_bit94", 1,
		bool, "CLRENA_reserved_bit95", 1);
	private uint[24] ICER_reserved;
	/// 
	private uint ISPR0_impl;
	mixin defineVolatileAccessor!(ISPR0_impl, "ISPR0");
	mixin defineBitfields!(ISPR0_impl,
		bool, "SETPEND0",  1,
		bool, "SETPEND1",  1,
		bool, "SETPEND2",  1,
		bool, "SETPEND3",  1,
		bool, "SETPEND4",  1,
		bool, "SETPEND5",  1,
		bool, "SETPEND6",  1,
		bool, "SETPEND7",  1,
		bool, "SETPEND8",  1,
		bool, "SETPEND9",  1,
		bool, "SETPEND10", 1,
		bool, "SETPEND11", 1,
		bool, "SETPEND12", 1,
		bool, "SETPEND13", 1,
		bool, "SETPEND14", 1,
		bool, "SETPEND15", 1,
		bool, "SETPEND16", 1,
		bool, "SETPEND17", 1,
		bool, "SETPEND18", 1,
		bool, "SETPEND19", 1,
		bool, "SETPEND20", 1,
		bool, "SETPEND21", 1,
		bool, "SETPEND22", 1,
		bool, "SETPEND23", 1,
		bool, "SETPEND24", 1,
		bool, "SETPEND25", 1,
		bool, "SETPEND26", 1,
		bool, "SETPEND27", 1,
		bool, "SETPEND28", 1,
		bool, "SETPEND29", 1,
		bool, "SETPEND30", 1,
		bool, "SETPEND31", 1);
	/// 
	private uint ISPR1_impl;
	mixin defineVolatileAccessor!(ISPR1_impl, "ISPR1");
	mixin defineBitfields!(ISPR1_impl,
		bool, "SETPEND32", 1,
		bool, "SETPEND33", 1,
		bool, "SETPEND34", 1,
		bool, "SETPEND35", 1,
		bool, "SETPEND36", 1,
		bool, "SETPEND37", 1,
		bool, "SETPEND38", 1,
		bool, "SETPEND39", 1,
		bool, "SETPEND40", 1,
		bool, "SETPEND41", 1,
		bool, "SETPEND42", 1,
		bool, "SETPEND43", 1,
		bool, "SETPEND44", 1,
		bool, "SETPEND45", 1,
		bool, "SETPEND46", 1,
		bool, "SETPEND47", 1,
		bool, "SETPEND48", 1,
		bool, "SETPEND49", 1,
		bool, "SETPEND50", 1,
		bool, "SETPEND51", 1,
		bool, "SETPEND52", 1,
		bool, "SETPEND53", 1,
		bool, "SETPEND54", 1,
		bool, "SETPEND55", 1,
		bool, "SETPEND56", 1,
		bool, "SETPEND57", 1,
		bool, "SETPEND58", 1,
		bool, "SETPEND59", 1,
		bool, "SETPEND60", 1,
		bool, "SETPEND61", 1,
		bool, "SETPEND62", 1,
		bool, "SETPEND63", 1);
	/// 
	private uint ISPR2_impl;
	mixin defineVolatileAccessor!(ISPR2_impl, "ISPR2");
	mixin defineBitfields!(ISPR2_impl,
		bool, "SETPEND64", 1,
		bool, "SETPEND65", 1,
		bool, "SETPEND66", 1,
		bool, "SETPEND67", 1,
		bool, "SETPEND68", 1,
		bool, "SETPEND69", 1,
		bool, "SETPEND70", 1,
		bool, "SETPEND71", 1,
		bool, "SETPEND72", 1,
		bool, "SETPEND73", 1,
		bool, "SETPEND74", 1,
		bool, "SETPEND75", 1,
		bool, "SETPEND76", 1,
		bool, "SETPEND77", 1,
		bool, "SETPEND78", 1,
		bool, "SETPEND79", 1,
		bool, "SETPEND80", 1,
		bool, "SETPEND_reserved_bit81", 1,
		bool, "SETPEND_reserved_bit82", 1,
		bool, "SETPEND_reserved_bit83", 1,
		bool, "SETPEND_reserved_bit84", 1,
		bool, "SETPEND_reserved_bit85", 1,
		bool, "SETPEND_reserved_bit86", 1,
		bool, "SETPEND_reserved_bit87", 1,
		bool, "SETPEND_reserved_bit88", 1,
		bool, "SETPEND_reserved_bit89", 1,
		bool, "SETPEND_reserved_bit90", 1,
		bool, "SETPEND_reserved_bit91", 1,
		bool, "SETPEND_reserved_bit92", 1,
		bool, "SETPEND_reserved_bit93", 1,
		bool, "SETPEND_reserved_bit94", 1,
		bool, "SETPEND_reserved_bit95", 1);
	private uint[24] ISPR_reserved;
	/// 
	private uint ICPR0_impl;
	mixin defineVolatileAccessor!(ICPR0_impl, "ICPR0");
	mixin defineBitfields!(ICPR0_impl,
		bool, "CLRPEND0",  1,
		bool, "CLRPEND1",  1,
		bool, "CLRPEND2",  1,
		bool, "CLRPEND3",  1,
		bool, "CLRPEND4",  1,
		bool, "CLRPEND5",  1,
		bool, "CLRPEND6",  1,
		bool, "CLRPEND7",  1,
		bool, "CLRPEND8",  1,
		bool, "CLRPEND9",  1,
		bool, "CLRPEND10", 1,
		bool, "CLRPEND11", 1,
		bool, "CLRPEND12", 1,
		bool, "CLRPEND13", 1,
		bool, "CLRPEND14", 1,
		bool, "CLRPEND15", 1,
		bool, "CLRPEND16", 1,
		bool, "CLRPEND17", 1,
		bool, "CLRPEND18", 1,
		bool, "CLRPEND19", 1,
		bool, "CLRPEND20", 1,
		bool, "CLRPEND21", 1,
		bool, "CLRPEND22", 1,
		bool, "CLRPEND23", 1,
		bool, "CLRPEND24", 1,
		bool, "CLRPEND25", 1,
		bool, "CLRPEND26", 1,
		bool, "CLRPEND27", 1,
		bool, "CLRPEND28", 1,
		bool, "CLRPEND29", 1,
		bool, "CLRPEND30", 1,
		bool, "CLRPEND31", 1);
	/// 
	private uint ICPR1_impl;
	mixin defineVolatileAccessor!(ICPR1_impl, "ICPR1");
	mixin defineBitfields!(ICPR1_impl,
		bool, "CLRPEND32", 1,
		bool, "CLRPEND33", 1,
		bool, "CLRPEND34", 1,
		bool, "CLRPEND35", 1,
		bool, "CLRPEND36", 1,
		bool, "CLRPEND37", 1,
		bool, "CLRPEND38", 1,
		bool, "CLRPEND39", 1,
		bool, "CLRPEND40", 1,
		bool, "CLRPEND41", 1,
		bool, "CLRPEND42", 1,
		bool, "CLRPEND43", 1,
		bool, "CLRPEND44", 1,
		bool, "CLRPEND45", 1,
		bool, "CLRPEND46", 1,
		bool, "CLRPEND47", 1,
		bool, "CLRPEND48", 1,
		bool, "CLRPEND49", 1,
		bool, "CLRPEND50", 1,
		bool, "CLRPEND51", 1,
		bool, "CLRPEND52", 1,
		bool, "CLRPEND53", 1,
		bool, "CLRPEND54", 1,
		bool, "CLRPEND55", 1,
		bool, "CLRPEND56", 1,
		bool, "CLRPEND57", 1,
		bool, "CLRPEND58", 1,
		bool, "CLRPEND59", 1,
		bool, "CLRPEND60", 1,
		bool, "CLRPEND61", 1,
		bool, "CLRPEND62", 1,
		bool, "CLRPEND63", 1);
	/// 
	private uint ICPR2_impl;
	mixin defineVolatileAccessor!(ICPR2_impl, "ICPR2");
	mixin defineBitfields!(ICPR2_impl,
		bool, "CLRPEND64", 1,
		bool, "CLRPEND65", 1,
		bool, "CLRPEND66", 1,
		bool, "CLRPEND67", 1,
		bool, "CLRPEND68", 1,
		bool, "CLRPEND69", 1,
		bool, "CLRPEND70", 1,
		bool, "CLRPEND71", 1,
		bool, "CLRPEND72", 1,
		bool, "CLRPEND73", 1,
		bool, "CLRPEND74", 1,
		bool, "CLRPEND75", 1,
		bool, "CLRPEND76", 1,
		bool, "CLRPEND77", 1,
		bool, "CLRPEND78", 1,
		bool, "CLRPEND79", 1,
		bool, "CLRPEND80", 1,
		bool, "CLRPEND_reserved_bit81", 1,
		bool, "CLRPEND_reserved_bit82", 1,
		bool, "CLRPEND_reserved_bit83", 1,
		bool, "CLRPEND_reserved_bit84", 1,
		bool, "CLRPEND_reserved_bit85", 1,
		bool, "CLRPEND_reserved_bit86", 1,
		bool, "CLRPEND_reserved_bit87", 1,
		bool, "CLRPEND_reserved_bit88", 1,
		bool, "CLRPEND_reserved_bit89", 1,
		bool, "CLRPEND_reserved_bit90", 1,
		bool, "CLRPEND_reserved_bit91", 1,
		bool, "CLRPEND_reserved_bit92", 1,
		bool, "CLRPEND_reserved_bit93", 1,
		bool, "CLRPEND_reserved_bit94", 1,
		bool, "CLRPEND_reserved_bit95", 1);
	private uint[24] ICPR_reserved;
	/// 
	private uint IABR0_impl;
	mixin defineVolatileAccessor!(IABR0_impl, "IABR0");
	mixin defineBitfields!(IABR0_impl,
		bool, "ACTIVE0",  1,
		bool, "ACTIVE1",  1,
		bool, "ACTIVE2",  1,
		bool, "ACTIVE3",  1,
		bool, "ACTIVE4",  1,
		bool, "ACTIVE5",  1,
		bool, "ACTIVE6",  1,
		bool, "ACTIVE7",  1,
		bool, "ACTIVE8",  1,
		bool, "ACTIVE9",  1,
		bool, "ACTIVE10", 1,
		bool, "ACTIVE11", 1,
		bool, "ACTIVE12", 1,
		bool, "ACTIVE13", 1,
		bool, "ACTIVE14", 1,
		bool, "ACTIVE15", 1,
		bool, "ACTIVE16", 1,
		bool, "ACTIVE17", 1,
		bool, "ACTIVE18", 1,
		bool, "ACTIVE19", 1,
		bool, "ACTIVE20", 1,
		bool, "ACTIVE21", 1,
		bool, "ACTIVE22", 1,
		bool, "ACTIVE23", 1,
		bool, "ACTIVE24", 1,
		bool, "ACTIVE25", 1,
		bool, "ACTIVE26", 1,
		bool, "ACTIVE27", 1,
		bool, "ACTIVE28", 1,
		bool, "ACTIVE29", 1,
		bool, "ACTIVE30", 1,
		bool, "ACTIVE31", 1);
	/// 
	private uint IABR1_impl;
	mixin defineVolatileAccessor!(IABR1_impl, "IABR1");
	mixin defineBitfields!(IABR1_impl,
		bool, "ACTIVE32", 1,
		bool, "ACTIVE33", 1,
		bool, "ACTIVE34", 1,
		bool, "ACTIVE35", 1,
		bool, "ACTIVE36", 1,
		bool, "ACTIVE37", 1,
		bool, "ACTIVE38", 1,
		bool, "ACTIVE39", 1,
		bool, "ACTIVE40", 1,
		bool, "ACTIVE41", 1,
		bool, "ACTIVE42", 1,
		bool, "ACTIVE43", 1,
		bool, "ACTIVE44", 1,
		bool, "ACTIVE45", 1,
		bool, "ACTIVE46", 1,
		bool, "ACTIVE47", 1,
		bool, "ACTIVE48", 1,
		bool, "ACTIVE49", 1,
		bool, "ACTIVE50", 1,
		bool, "ACTIVE51", 1,
		bool, "ACTIVE52", 1,
		bool, "ACTIVE53", 1,
		bool, "ACTIVE54", 1,
		bool, "ACTIVE55", 1,
		bool, "ACTIVE56", 1,
		bool, "ACTIVE57", 1,
		bool, "ACTIVE58", 1,
		bool, "ACTIVE59", 1,
		bool, "ACTIVE60", 1,
		bool, "ACTIVE61", 1,
		bool, "ACTIVE62", 1,
		bool, "ACTIVE63", 1);
	/// 
	private uint IABR2_impl;
	mixin defineVolatileAccessor!(IABR2_impl, "IABR2");
	mixin defineBitfields!(IABR2_impl,
		bool, "ACTIVE64", 1,
		bool, "ACTIVE65", 1,
		bool, "ACTIVE66", 1,
		bool, "ACTIVE67", 1,
		bool, "ACTIVE68", 1,
		bool, "ACTIVE69", 1,
		bool, "ACTIVE70", 1,
		bool, "ACTIVE71", 1,
		bool, "ACTIVE72", 1,
		bool, "ACTIVE73", 1,
		bool, "ACTIVE74", 1,
		bool, "ACTIVE75", 1,
		bool, "ACTIVE76", 1,
		bool, "ACTIVE77", 1,
		bool, "ACTIVE78", 1,
		bool, "ACTIVE79", 1,
		bool, "ACTIVE80", 1,
		bool, "ACTIVE_reserved_bit81", 1,
		bool, "ACTIVE_reserved_bit82", 1,
		bool, "ACTIVE_reserved_bit83", 1,
		bool, "ACTIVE_reserved_bit84", 1,
		bool, "ACTIVE_reserved_bit85", 1,
		bool, "ACTIVE_reserved_bit86", 1,
		bool, "ACTIVE_reserved_bit87", 1,
		bool, "ACTIVE_reserved_bit88", 1,
		bool, "ACTIVE_reserved_bit89", 1,
		bool, "ACTIVE_reserved_bit90", 1,
		bool, "ACTIVE_reserved_bit91", 1,
		bool, "ACTIVE_reserved_bit92", 1,
		bool, "ACTIVE_reserved_bit93", 1,
		bool, "ACTIVE_reserved_bit94", 1,
		bool, "ACTIVE_reserved_bit95", 1);
	private uint[24] IABR_reserved;
	///
	public ubyte[240] IPR;
	private ubyte[644] IPR_reserved;
	///
	private uint STIR_impl;
	mixin defineVolatileAccessor!(STIR_impl, "STIR");
	mixin defineBitfields!(STIR_impl,
		ubyte, "INTID", 8,
		uint,  "STIR_reserved", 24);
}

/***************************************************************
 * SCB
 */
struct SCB_TYPE
{
	private uint CPUID_impl;
	static assert(CPUID_impl.offsetof == 0x000);
	mixin defineVolatileAccessor!(CPUID_impl, "CPUID");
	                  /*!< Offset:  (R/ )  CPUID Base Register */
	
	private uint ICSR_impl;
	static assert(ICSR_impl.offsetof == 0x004);
	mixin defineVolatileAccessor!(ICSR_impl, "ICSR");
	                   /*!< Offset:  (R/W)  Interrupt Control and State Register */
	
	private uint VTOR_impl;
	static assert(VTOR_impl.offsetof == 0x008);
	mixin defineVolatileAccessor!(VTOR_impl, "VTOR");
	                   /*!< Offset:  (R/W)  Vector Table Offset Register */
	
	private uint AIRCR_impl;
	static assert(AIRCR_impl.offsetof == 0x00C);
	mixin defineVolatileAccessor!(AIRCR_impl, "AIRCR");
	                  /*!< Offset:  (R/W)  Application Interrupt and Reset Control Register */
	
	private uint SCR_impl;
	static assert(SCR_impl.offsetof == 0x010);
	mixin defineVolatileAccessor!(SCR_impl, "SCR");
	                    /*!< Offset:  (R/W)  System Control Register */
	
	private uint CCR_impl;
	static assert(CCR_impl.offsetof == 0x014);
	mixin defineVolatileAccessor!(CCR_impl, "CCR");
	                    /*!< Offset:  (R/W)  Configuration Control Register */
	
	private uint SHPR1_impl;
	static assert(SHPR1_impl.offsetof == 0x018);
	mixin defineVolatileAccessor!(SHPR1_impl, "SHPR1");
	               /*!< Offset:  (R/W)  System Handlers Priority Registers (4-7, 8-11, 12-15) */
	private uint SHPR2_impl;
	static assert(SHPR2_impl.offsetof == 0x01C);
	mixin defineVolatileAccessor!(SHPR2_impl, "SHPR2");
	               /*!< Offset:  (R/W)  System Handlers Priority Registers (4-7, 8-11, 12-15) */
	private uint SHPR3_impl;
	static assert(SHPR3_impl.offsetof == 0x020);
	mixin defineVolatileAccessor!(SHPR3_impl, "SHPR3");
	               /*!< Offset:  (R/W)  System Handlers Priority Registers (4-7, 8-11, 12-15) */
	
	private uint SHCSR_impl;
	static assert(SHCSR_impl.offsetof == 0x024);
	mixin defineVolatileAccessor!(SHCSR_impl, "SHCSR");
	                  /*!< Offset:  (R/W)  System Handler Control and State Register */
	
	private uint CFSR_impl;
	static assert(CFSR_impl.offsetof == 0x028);
	mixin defineVolatileAccessor!(CFSR_impl, "CFSR");
	                   /*!< Offset:  (R/W)  Configurable Fault Status Register */
	
	private uint HFSR_impl;
	static assert(HFSR_impl.offsetof == 0x02C);
	mixin defineVolatileAccessor!(HFSR_impl, "HFSR");
	                   /*!< Offset:  (R/W)  HardFault Status Register */
	
	private uint DFSR_impl;
	static assert(DFSR_impl.offsetof == 0x030);
	mixin defineVolatileAccessor!(DFSR_impl, "DFSR");
	                   /*!< Offset:  (R/W)  Debug Fault Status Register */
	
	private uint MMFAR_impl;
	static assert(MMFAR_impl.offsetof == 0x034);
	mixin defineVolatileAccessor!(MMFAR_impl, "MMFAR");
	                  /*!< Offset:  (R/W)  MemManage Fault Address Register */
	
	private uint BFAR_impl;
	static assert(BFAR_impl.offsetof == 0x038);
	mixin defineVolatileAccessor!(BFAR_impl, "BFAR");
	                   /*!< Offset:  (R/W)  BusFault Address Register */
	
	private uint AFSR_impl;
	static assert(AFSR_impl.offsetof == 0x03C);
	mixin defineVolatileAccessor!(AFSR_impl, "AFSR");
	                   /*!< Offset:  (R/W)  Auxiliary Fault Status Register */
	
	private uint PFR1_impl;
	static assert(PFR1_impl.offsetof == 0x040);
	mixin defineVolatileAccessor!(PFR1_impl, "PFR1");
	                /*!< Offset:  (R/ )  Processor Feature Register */
	
	private uint PFR2_impl;
	static assert(PFR2_impl.offsetof == 0x044);
	mixin defineVolatileAccessor!(PFR2_impl, "PFR2");
	                /*!< Offset:  (R/ )  Processor Feature Register */
	
	private uint DFR_impl;
	static assert(DFR_impl.offsetof == 0x048);
	mixin defineVolatileAccessor!(DFR_impl, "DFR");
	                    /*!< Offset:  (R/ )  Debug Feature Register */
	
	private uint ADR_impl;
	static assert(ADR_impl.offsetof == 0x04C);
	mixin defineVolatileAccessor!(ADR_impl, "ADR");
	                    /*!< Offset:  (R/ )  Auxiliary Feature Register */
	
//	uint[4] MMFR_impl;
//	static assert(MMFR_impl.offsetof == 0x050);
//	mixin defineVolatileAccessor!(MMFR_impl, "MMFR");
	               /*!< Offset:  (R/ )  Memory Model Feature Register */
	
//	uint[5] ISAR_impl;
//	static assert(ISAR_impl.offsetof == 0x060);
//	mixin defineVolatileAccessor!(ISAR_impl, "ISAR");
	               /*!< Offset:  (R/ )  Instruction Set Attributes Register */
	
	private uint[14] reserved;
	
	/// Coprocessor Access Control Register (R/W)
	private uint CPACR_impl;
	static assert(CPACR_impl.offsetof == 0x088);
	mixin defineVolatileAccessor!(CPACR_impl, "CPACR");
	mixin defineBitfields!(CPACR_impl,
		uint, "CPACR_reserved_bit0_19", 20-0,
		ubyte, "CP10", 2,
		ubyte, "CP11", 2,
		uint, "CPACR_reserved_bit24_31", 32-24);
}

/***************************************************************
 * STK(SysTick)
 */
struct STK_TYPE
{
	private uint CTRL_impl;
	static assert(CTRL_impl.offsetof == 0x000);
	mixin defineVolatileAccessor!(CTRL_impl, "CTRL");
	mixin defineBitfields!(CTRL_impl,
		bool, "ENABLE", 1,
		bool, "TICKINT", 1,
		bool, "CLKSOURCE", 1,
		uint, "CTRL_reserved_bit3_15", 16-3,
		bool, "COUNTFLAG", 1,
		uint, "CTRL_reserved_bit3_15", 32-17);
	
	private uint LOAD_impl;
	static assert(LOAD_impl.offsetof == 0x004);
	mixin defineVolatileAccessor!(LOAD_impl, "LOAD");
	mixin defineBitfields!(LOAD_impl,
		uint, "RELOAD", 24,
		bool, "LOAD_reserved_bit3_15", 32-24);
	
	private uint VAL_impl;
	static assert(VAL_impl.offsetof == 0x008);
	mixin defineVolatileAccessor!(VAL_impl, "VAL");
	mixin defineBitfields!(VAL_impl,
		uint, "CURRENT", 24,
		bool, "VAL_reserved_bit3_15", 32-24);
	
	private uint CALIB_impl;
	static assert(CALIB_impl.offsetof == 0x00C);
	mixin defineVolatileAccessor!(CALIB_impl, "CALIB");
	mixin defineBitfields!(CALIB_impl,
		uint, "TENMS", 24,
		bool, "CALIB_reserved_bit3_15", 32-24);
	
}



//##############################################################################
//#####     周辺レジスタ
//##############################################################################



/***************************************************************
 * GPIO
 */
struct GPIO_TYPE
{
	/// 入出力モードを決定するレジスタ
	private uint MODER_impl;
	mixin defineVolatileAccessor!(MODER_impl, "MODER");
	mixin defineBitfields!(MODER_impl,
		uint, "MODER0",  2,
		uint, "MODER1",  2,
		uint, "MODER2",  2,
		uint, "MODER3",  2,
		uint, "MODER4",  2,
		uint, "MODER5",  2,
		uint, "MODER6",  2,
		uint, "MODER7",  2,
		uint, "MODER8",  2,
		uint, "MODER9",  2,
		uint, "MODER10", 2,
		uint, "MODER11", 2,
		uint, "MODER12", 2,
		uint, "MODER13", 2,
		uint, "MODER14", 2,
		uint, "MODER15", 2);
	
	/// 出力時のハードウェア設定を変更するレジスタ
	private uint OTYPER_impl;
	mixin defineVolatileAccessor!(OTYPER_impl, "OTYPER");
	mixin defineBitfields!(OTYPER_impl,
		bool, "OT0", 1,
		bool, "OT1", 1,
		bool, "OT2", 1,
		bool, "OT3", 1,
		bool, "OT4", 1,
		bool, "OT5", 1,
		bool, "OT6", 1,
		bool, "OT7", 1,
		bool, "OT8", 1,
		bool, "OT9", 1,
		bool, "OT10", 1,
		bool, "OT11", 1,
		bool, "OT12", 1,
		bool, "OT13", 1,
		bool, "OT14", 1,
		bool, "OT15", 1,
		ushort, "OTYPER_reserved", 16);

	/// 出力の立ち上がり立下りのスピードを設定するレジスタ
	private uint OSPEEDR_impl;
	mixin defineVolatileAccessor!(OSPEEDR_impl, "OSPEEDR");
	mixin defineBitfields!(OSPEEDR_impl,
		uint, "OSPEEDR0", 2,
		uint, "OSPEEDR1", 2,
		uint, "OSPEEDR2", 2,
		uint, "OSPEEDR3", 2,
		uint, "OSPEEDR4", 2,
		uint, "OSPEEDR5", 2,
		uint, "OSPEEDR6", 2,
		uint, "OSPEEDR7", 2,
		uint, "OSPEEDR8", 2,
		uint, "OSPEEDR9", 2,
		uint, "OSPEEDR10", 2,
		uint, "OSPEEDR11", 2,
		uint, "OSPEEDR12", 2,
		uint, "OSPEEDR13", 2,
		uint, "OSPEEDR14", 2,
		uint, "OSPEEDR15", 2);
	
	/// 内臓プルアップ・プルダウン抵抗の設定を行うレジスタ
	uint PUPDR_impl;
	mixin defineVolatileAccessor!(PUPDR_impl, "PUPDR");
	mixin defineBitfields!(PUPDR_impl,
		uint, "PUPDR0", 2,
		uint, "PUPDR1", 2,
		uint, "PUPDR2", 2,
		uint, "PUPDR3", 2,
		uint, "PUPDR4", 2,
		uint, "PUPDR5", 2,
		uint, "PUPDR6", 2,
		uint, "PUPDR7", 2,
		uint, "PUPDR8", 2,
		uint, "PUPDR9", 2,
		uint, "PUPDR10", 2,
		uint, "PUPDR11", 2,
		uint, "PUPDR12", 2,
		uint, "PUPDR13", 2,
		uint, "PUPDR14", 2,
		uint, "PUPDR15", 2);
	/// 入力がHなら所定のビットが1になるレジスタ
	private uint IDR_impl;
	mixin defineVolatileAccessor!(IDR_impl, "IDR");
	mixin defineBitfields!(IDR_impl,
		bool, "IDR0", 1,
		bool, "IDR1", 1,
		bool, "IDR2", 1,
		bool, "IDR3", 1,
		bool, "IDR4", 1,
		bool, "IDR5", 1,
		bool, "IDR6", 1,
		bool, "IDR7", 1,
		bool, "IDR8", 1,
		bool, "IDR9", 1,
		bool, "IDR10", 1,
		bool, "IDR11", 1,
		bool, "IDR12", 1,
		bool, "IDR13", 1,
		bool, "IDR14", 1,
		bool, "IDR15", 1,
		ushort, "IDR_reserved", 16);
	/// 所定のビットが1なら出力がHになるレジスタ
	private uint ODR_impl;
	mixin defineVolatileAccessor!(ODR_impl, "ODR");
	mixin defineBitfields!(ODR_impl,
		bool, "ODR0", 1,
		bool, "ODR1", 1,
		bool, "ODR2", 1,
		bool, "ODR3", 1,
		bool, "ODR4", 1,
		bool, "ODR5", 1,
		bool, "ODR6", 1,
		bool, "ODR7", 1,
		bool, "ODR8", 1,
		bool, "ODR9", 1,
		bool, "ODR10", 1,
		bool, "ODR11", 1,
		bool, "ODR12", 1,
		bool, "ODR13", 1,
		bool, "ODR14", 1,
		bool, "ODR15", 1,
		ushort, "ODR_reserved", 16);
	///
	private uint BSRR_impl;
	mixin defineVolatileAccessor!(BSRR_impl, "BSRR");
	mixin defineBitfields!(BSRR_impl,
		uint, "BS0", 1,
		uint, "BS1", 1,
		uint, "BS2", 1,
		uint, "BS3", 1,
		uint, "BS4", 1,
		uint, "BS5", 1,
		uint, "BS6", 1,
		uint, "BS7", 1,
		uint, "BS8", 1,
		uint, "BS9", 1,
		uint, "BS10", 1,
		uint, "BS11", 1,
		uint, "BS12", 1,
		uint, "BS13", 1,
		uint, "BS14", 1,
		uint, "BS15", 1,
		uint, "BR0", 1,
		uint, "BR1", 1,
		uint, "BR2", 1,
		uint, "BR3", 1,
		uint, "BR4", 1,
		uint, "BR5", 1,
		uint, "BR6", 1,
		uint, "BR7", 1,
		uint, "BR8", 1,
		uint, "BR9", 1,
		uint, "BR10", 1,
		uint, "BR11", 1,
		uint, "BR12", 1,
		uint, "BR13", 1,
		uint, "BR14", 1,
		uint, "BR15", 1);
	///
	uint LCKR;
	///
	uint AFRL;
	///
	uint AFRH;
}



/*******************************************************************************
 * 
 */
struct RCC_TYPE
{
	///
	private uint CR_impl;
	static assert(CR_impl.offsetof == 0x00);
	mixin defineVolatileAccessor!(CR_impl, "CR");
	mixin defineBitfields!(CR_impl,
		bool, "HSION", 1,
		bool, "HSIRDY", 1,
		bool, "CR_reserved_bit2", 1,
		uint, "HSITRIM", 5,
		uint, "HSICAL", 8,
		bool, "HSEON", 1,
		bool, "HSERDY", 1,
		bool, "HSEBYP", 1,
		bool, "CSSON", 1,
		bool, "CR_reserved_bit20", 1,
		bool, "CR_reserved_bit21", 1,
		bool, "CR_reserved_bit22", 1,
		bool, "CR_reserved_bit23", 1,
		bool, "PLLON", 1,
		bool, "PLLRDY", 1,
		bool, "PLLI2SON", 1,
		bool, "PLLI2SRDY", 1,
		bool, "CR_reserved_bit28", 1,
		bool, "CR_reserved_bit29", 1,
		bool, "CR_reserved_bit30", 1,
		bool, "CR_reserved_bit31", 1);
	///
	private uint PLLCFGR_impl;
	static assert(PLLCFGR_impl.offsetof == 0x04);
	mixin defineVolatileAccessor!(PLLCFGR_impl, "PLLCFGR");
	mixin defineBitfields!(PLLCFGR_impl,
		ubyte, "PLLM0", 1,
		ubyte, "PLLM1", 1,
		ubyte, "PLLM2", 1,
		ubyte, "PLLM3", 1,
		ubyte, "PLLM4", 1,
		ubyte, "PLLM5", 1,
		ubyte, "PLLN0", 1,
		ubyte, "PLLN1", 1,
		ubyte, "PLLN2", 1,
		ubyte, "PLLN3", 1,
		ubyte, "PLLN4", 1,
		ubyte, "PLLN5", 1,
		ubyte, "PLLN6", 1,
		ubyte, "PLLN7", 1,
		ubyte, "PLLN8", 1,
		ubyte, "PLLCFGR_reserved_bit15", 1,
		ubyte, "PLLP0", 1,
		ubyte, "PLLP1", 1,
		ubyte, "PLLCFGR_reserved_bit18", 1,
		ubyte, "PLLCFGR_reserved_bit19", 1,
		ubyte, "PLLCFGR_reserved_bit20", 1,
		ubyte, "PLLCFGR_reserved_bit21", 1,
		ubyte, "PLLSRC", 1,
		ubyte, "PLLCFGR_reserved_bit23", 1,
		ubyte, "PLLQ0", 1,
		ubyte, "PLLQ1", 1,
		ubyte, "PLLQ2", 1,
		ubyte, "PLLQ3", 1,
		ubyte, "PLLCFGR_reserved_bit28", 1,
		ubyte, "PLLCFGR_reserved_bit29", 1,
		ubyte, "PLLCFGR_reserved_bit30", 1,
		ubyte, "PLLCFGR_reserved_bit31", 1);
	mixin defineBitfields!(PLLCFGR_impl,
		uint, "PLLM", 6,
		uint, "PLLN", 9,
		uint, "PLLCFGR_reserved_bit15_15", 1,
		uint, "PLLP", 2,
		uint, "PLLCFGR_reserved_bit18_21", 4,
		uint, "PLLSRC_", 1,
		uint, "PLLCFGR_reserved_bit23_23", 1,
		uint, "PLLQ", 4,
		uint, "PLLCFGR_reserved_bit28_31", 4);
	///
	private uint CFGR_impl;
	static assert(CFGR_impl.offsetof == 0x08);
	mixin defineVolatileAccessor!(CFGR_impl, "CFGR");
	mixin defineBitfields!(CFGR_impl,
		bool, "SW0", 1,
		bool, "SW1", 1,
		bool, "SWS0", 1,
		bool, "SWS1", 1,
		bool, "HPRE0", 1,
		bool, "HPRE1", 1,
		bool, "HPRE2", 1,
		bool, "HPRE3", 1,
		bool, "CFGR_reserved_bit8", 1,
		bool, "CFGR_reserved_bit9", 1,
		bool, "PPRE10", 1,
		bool, "PPRE11", 1,
		bool, "PPRE12", 1,
		bool, "PPRE20", 1,
		bool, "PPRE21", 1,
		bool, "PPRE22", 1,
		bool, "RTCPRE0", 1,
		bool, "RTCPRE1", 1,
		bool, "RTCPRE2", 1,
		bool, "RTCPRE3", 1,
		bool, "RTCPRE4", 1,
		bool, "MCO10", 1,
		bool, "MCO11", 1,
		bool, "I2SSRC", 1,
		bool, "MCO1PRE0", 1,
		bool, "MCO1PRE1", 1,
		bool, "MCO1PRE2", 1,
		bool, "MCO2PRE0", 1,
		bool, "MCO2PRE1", 1,
		bool, "MCO2PRE2", 1,
		bool, "MCO20", 1,
		bool, "MCO21", 1);
	mixin defineBitfields!(CFGR_impl,
		uint, "SW", 2,
		uint, "SWS", 2,
		uint, "HPRE", 4,
		uint, "CFGR_reserved_bit8_9", 2,
		uint, "PPRE1", 3,
		uint, "PPRE2", 3,
		uint, "RTCPRE", 5,
		uint, "MCO1", 2,
		uint, "I2SSRC", 1,
		uint, "MCO1PRE", 3,
		uint, "MCO2PRE", 3,
		uint, "MCO2", 2);
	///
	private uint CIR_impl;
	static assert(CIR_impl.offsetof == 0x0C);
	mixin defineVolatileAccessor!(CIR_impl, "CIR");
	mixin defineBitfields!(CIR_impl,
		bool, "LSIRDYF", 1,
		bool, "LSERDYF", 1,
		bool, "HSIRDYF", 1,
		bool, "HSERDYF", 1,
		bool, "PLLRDYF", 1,
		bool, "PLLI2SRDYF", 1,
		bool, "CIR_reserved_bit6", 1,
		bool, "CSSF", 1,
		bool, "LSIRDYIE", 1,
		bool, "LSERDYIE", 1,
		bool, "HSIRDYIE", 1,
		bool, "HSERDYIE", 1,
		bool, "PLLRDYIE", 1,
		bool, "PLLI2SRDYIE", 1,
		bool, "CIR_reserved_bit14", 1,
		bool, "CIR_reserved_bit15", 1,
		bool, "LSIRDYC", 1,
		bool, "LSERDYC", 1,
		bool, "HSIRDYC", 1,
		bool, "HSERDYC", 1,
		bool, "PLLRDYC", 1,
		bool, "PLLI2SRDYC", 1,
		bool, "CIR_reserved_bit22", 1,
		bool, "CSSC", 1,
		bool, "CIR_reserved_bit24", 1,
		bool, "CIR_reserved_bit25", 1,
		bool, "CIR_reserved_bit26", 1,
		bool, "CIR_reserved_bit27", 1,
		bool, "CIR_reserved_bit28", 1,
		bool, "CIR_reserved_bit29", 1,
		bool, "CIR_reserved_bit30", 1,
		bool, "CIR_reserved_bit31", 1);
	///
	private uint AHB1RSTR_impl;
	static assert(AHB1RSTR_impl.offsetof == 0x10);
	mixin defineVolatileAccessor!(AHB1RSTR_impl, "AHB1RSTR");
	///
	private uint AHB2RSTR_impl;
	static assert(AHB2RSTR_impl.offsetof == 0x14);
	mixin defineVolatileAccessor!(AHB2RSTR_impl, "AHB2RSTR");
	///
	private uint reserved1;
	///
	private uint reserved2;
	///
	private uint APB1RSTR_impl;
	static assert(APB1RSTR_impl.offsetof == 0x20);
	mixin defineVolatileAccessor!(APB1RSTR_impl, "APB1RSTR");
	///
	private uint APB2RSTR_impl;
	static assert(APB2RSTR_impl.offsetof == 0x24);
	mixin defineVolatileAccessor!(APB2RSTR_impl, "APB2RSTR");
	///
	uint reserved3;
	///
	uint reserved4;
	///
	private uint AHB1ENR_impl;
	static assert(AHB1ENR_impl.offsetof == 0x30);
	mixin defineVolatileAccessor!(AHB1ENR_impl, "AHB1ENR");
	mixin defineBitfields!(AHB1ENR_impl,
		bool, "GPIOAEN", 1,
		bool, "GPIOBEN", 1,
		bool, "GPIOCEN", 1,
		bool, "GPIODEN", 1,
		bool, "GPIOEEN", 1,
		bool, "AHB1ENR_reserved_bit5", 1,
		bool, "AHB1ENR_reserved_bit6", 1,
		bool, "GPIOHEN", 1,
		bool, "AHB1ENR_reserved_bit8", 1,
		bool, "AHB1ENR_reserved_bit9", 1,
		bool, "AHB1ENR_reserved_bit10", 1,
		bool, "AHB1ENR_reserved_bit11", 1,
		bool, "CRCEN", 1,
		bool, "AHB1ENR_reserved_bit13", 1,
		bool, "AHB1ENR_reserved_bit14", 1,
		bool, "AHB1ENR_reserved_bit15", 1,
		bool, "AHB1ENR_reserved_bit16", 1,
		bool, "AHB1ENR_reserved_bit17", 1,
		bool, "AHB1ENR_reserved_bit18", 1,
		bool, "AHB1ENR_reserved_bit19", 1,
		bool, "AHB1ENR_reserved_bit20", 1,
		bool, "DMA1EN", 1,
		bool, "DMA2EN", 1,
		bool, "AHB1ENR_reserved_bit23", 1,
		bool, "AHB1ENR_reserved_bit24", 1,
		bool, "AHB1ENR_reserved_bit25", 1,
		bool, "AHB1ENR_reserved_bit26", 1,
		bool, "AHB1ENR_reserved_bit27", 1,
		bool, "AHB1ENR_reserved_bit28", 1,
		bool, "AHB1ENR_reserved_bit29", 1,
		bool, "AHB1ENR_reserved_bit30", 1,
		bool, "AHB1ENR_reserved_bit31", 1);
	///
	private uint AHB2ENR_impl;
	static assert(AHB2ENR_impl.offsetof == 0x34);
	mixin defineVolatileAccessor!(AHB2ENR_impl, "AHB2ENR");
	mixin defineBitfields!(AHB2ENR_impl,
		bool, "AHB2ENR_reserved_bit1", 1,
		bool, "AHB2ENR_reserved_bit2", 1,
		bool, "AHB2ENR_reserved_bit3", 1,
		bool, "AHB2ENR_reserved_bit4", 1,
		bool, "AHB2ENR_reserved_bit5", 1,
		bool, "AHB2ENR_reserved_bit5", 1,
		bool, "AHB2ENR_reserved_bit6", 1,
		bool, "OTGFSEN", 1,
		bool, "AHB2ENR_reserved_bit8", 1,
		bool, "AHB2ENR_reserved_bit9", 1,
		bool, "AHB2ENR_reserved_bit10", 1,
		bool, "AHB2ENR_reserved_bit11", 1,
		bool, "AHB2ENR_reserved_bit12", 1,
		bool, "AHB2ENR_reserved_bit13", 1,
		bool, "AHB2ENR_reserved_bit14", 1,
		bool, "AHB2ENR_reserved_bit15", 1,
		bool, "AHB2ENR_reserved_bit16", 1,
		bool, "AHB2ENR_reserved_bit17", 1,
		bool, "AHB2ENR_reserved_bit18", 1,
		bool, "AHB2ENR_reserved_bit19", 1,
		bool, "AHB2ENR_reserved_bit20", 1,
		bool, "AHB2ENR_reserved_bit21", 1,
		bool, "AHB2ENR_reserved_bit22", 1,
		bool, "AHB2ENR_reserved_bit23", 1,
		bool, "AHB2ENR_reserved_bit24", 1,
		bool, "AHB2ENR_reserved_bit25", 1,
		bool, "AHB2ENR_reserved_bit26", 1,
		bool, "AHB2ENR_reserved_bit27", 1,
		bool, "AHB2ENR_reserved_bit28", 1,
		bool, "AHB2ENR_reserved_bit29", 1,
		bool, "AHB2ENR_reserved_bit30", 1,
		bool, "AHB2ENR_reserved_bit31", 1);
	///
	private uint reserved5;
	///
	private uint reserved6;
	///
	private uint APB1ENR_impl;
	static assert(APB1ENR_impl.offsetof == 0x40);
	mixin defineVolatileAccessor!(APB1ENR_impl, "APB1ENR");
	mixin defineBitfields!(APB1ENR_impl,
		bool, "TIM2EN", 1,
		bool, "TIM3EN", 1,
		bool, "TIM4EN", 1,
		bool, "TIM5EN", 1,
		bool, "APB1ENR_reserved_bit4", 1,
		bool, "APB1ENR_reserved_bit5", 1,
		bool, "APB1ENR_reserved_bit6", 1,
		bool, "APB1ENR_reserved_bit7", 1,
		bool, "APB1ENR_reserved_bit8", 1,
		bool, "APB1ENR_reserved_bit9", 1,
		bool, "APB1ENR_reserved_bit10", 1,
		bool, "WWDGEN", 1,
		bool, "APB1ENR_reserved_bit12", 1,
		bool, "APB1ENR_reserved_bit13", 1,
		bool, "SPI2EN", 1,
		bool, "SPI3EN", 1,
		bool, "APB1ENR_reserved_bit16", 1,
		bool, "USART2EN", 1,
		bool, "APB1ENR_reserved_bit18", 1,
		bool, "APB1ENR_reserved_bit19", 1,
		bool, "APB1ENR_reserved_bit20", 1,
		bool, "I2C1EN", 1,
		bool, "I2C2EN", 1,
		bool, "I2C3EN", 1,
		bool, "APB1ENR_reserved_bit24", 1,
		bool, "APB1ENR_reserved_bit25", 1,
		bool, "APB1ENR_reserved_bit26", 1,
		bool, "APB1ENR_reserved_bit27", 1,
		bool, "PWREN", 1,
		bool, "APB1ENR_reserved_bit29", 1,
		bool, "APB1ENR_reserved_bit30", 1,
		bool, "APB1ENR_reserved_bit31", 1);
	///
	private uint APB2ENR_impl;
	static assert(APB2ENR_impl.offsetof == 0x44);
	mixin defineVolatileAccessor!(APB2ENR_impl, "APB2ENR");
	mixin defineBitfields!(APB2ENR_impl,
		bool, "TIM1EN", 1,
		bool, "APB2ENR_reserved_bit1", 1,
		bool, "APB2ENR_reserved_bit2", 1,
		bool, "APB2ENR_reserved_bit3", 1,
		bool, "USART1EN", 1,
		bool, "USART6EN", 1,
		bool, "APB2ENR_reserved_bit6", 1,
		bool, "APB2ENR_reserved_bit7", 1,
		bool, "ADC1EN", 1,
		bool, "APB2ENR_reserved_bit9", 1,
		bool, "APB2ENR_reserved_bit10", 1,
		bool, "SDIOEN", 1,
		bool, "SPI1EN", 1,
		bool, "SPI4EN", 1,
		bool, "SYSCFGEN", 1,
		bool, "APB2ENR_reserved_bit15", 1,
		bool, "TIM9EN", 1,
		bool, "TIM10EN", 1,
		bool, "TIM11EN", 1,
		bool, "APB2ENR_reserved_bit19", 1,
		bool, "APB2ENR_reserved_bit20", 1,
		bool, "APB2ENR_reserved_bit21", 1,
		bool, "APB2ENR_reserved_bit22", 1,
		bool, "APB2ENR_reserved_bit23", 1,
		bool, "APB2ENR_reserved_bit24", 1,
		bool, "APB2ENR_reserved_bit25", 1,
		bool, "APB2ENR_reserved_bit26", 1,
		bool, "APB2ENR_reserved_bit27", 1,
		bool, "APB2ENR_reserved_bit28", 1,
		bool, "APB2ENR_reserved_bit29", 1,
		bool, "APB2ENR_reserved_bit30", 1,
		bool, "APB2ENR_reserved_bit31", 1);
	///
	private uint reserved7;
	///
	private uint reserved8;
	///
	private uint AHB1LPENR_impl;
	static assert(AHB1LPENR_impl.offsetof == 0x50);
	mixin defineVolatileAccessor!(AHB1LPENR_impl, "AHB1LPENR");
	///
	private uint AHB2LPENR_impl;
	static assert(AHB2LPENR_impl.offsetof == 0x54);
	mixin defineVolatileAccessor!(AHB2LPENR_impl, "AHB2LPENR");
	///
	private uint reserved9;
	///
	private uint reserved10;
	///
	private uint APB1LPENR_impl;
	static assert(APB1LPENR_impl.offsetof == 0x60);
	mixin defineVolatileAccessor!(APB1LPENR_impl, "APB1LPENR");
	///
	private uint APB2LPENR_impl;
	static assert(APB2LPENR_impl.offsetof == 0x64);
	mixin defineVolatileAccessor!(APB2LPENR_impl, "APB2LPENR");
	///
	private uint reserved11;
	///
	private uint reserved12;
	///
	private uint BDCR_impl;
	static assert(BDCR_impl.offsetof == 0x70);
	mixin defineVolatileAccessor!(BDCR_impl, "BDCR");
	///
	private uint CSR_impl;
	static assert(CSR_impl.offsetof == 0x74);
	mixin defineVolatileAccessor!(CSR_impl, "CSR");
	///
	private uint reserved13;
	///
	private uint reserved14;
	///
	private uint SSCGR_impl;
	static assert(SSCGR_impl.offsetof == 0x80);
	mixin defineVolatileAccessor!(SSCGR_impl, "SSCGR");
	///
	private uint PLLI2SCFGR_impl;
	static assert(PLLI2SCFGR_impl.offsetof == 0x84);
	mixin defineVolatileAccessor!(PLLI2SCFGR_impl, "PLLI2SCFGR");
	///
	private uint reserved15;
	///
	private uint DCKCFGR_impl;
	static assert(DCKCFGR_impl.offsetof == 0x8C);
	mixin defineVolatileAccessor!(DCKCFGR_impl, "DCKCFGR");
}

/*******************************************************************************
 * フラッシュROM管理レジスタ
 */
struct FLASH_TYPE
{
	///
	private uint ACR_impl;
	static assert(ACR_impl.offsetof == 0x00);
	mixin defineVolatileAccessor!(ACR_impl, "ACR");
	mixin defineBitfields!(ACR_impl,
		ubyte, "LATENCY", 4,
		ubyte, "ACR_reserved_bit4_7", 8-4,
		bool,  "PRFTEN",  1,
		bool,  "ICEN",    1,
		bool,  "DCEN",    1,
		bool,  "ICRST",   1,
		bool,  "DCRST",   1,
		uint,  "ACR_reserved_bit13_31", 32-13);
	///
	private uint KEYR_impl;
	static assert(KEYR_impl.offsetof == 0x04);
	mixin defineVolatileAccessor!(KEYR_impl, "KEYR");
	mixin defineBitfields!(KEYR_impl,
		ushort, "KEYL", 16-0,
		ushort, "KEYH", 32-16);
	///
	private uint OPTKEYR_impl;
	static assert(OPTKEYR_impl.offsetof == 0x08);
	mixin defineVolatileAccessor!(OPTKEYR_impl, "OPTKEYR");
	mixin defineBitfields!(OPTKEYR_impl,
		ushort, "OPTKEYL", 16-0,
		ushort, "OPTKEYH", 32-16);
	///
	private uint SR_impl;
	static assert(SR_impl.offsetof == 0x0C);
	mixin defineVolatileAccessor!(SR_impl, "SR");
	mixin defineBitfields!(SR_impl,
		bool, "EOP",   1,
		bool, "OPERR", 1,
		uint, "SR_reserved_bit2_3", 4-2,
		bool, "WRPERR", 1,
		bool, "PGAERR", 1,
		bool, "PGPERR", 1,
		bool, "PGSERR", 1,
		bool, "RDERR", 1,
		uint, "SR_reserved_bit15_9", 16-9,
		bool, "BSY", 1,
		uint, "SR_reserved_bit17_31", 32-17);
	///
	private uint CR_impl;
	static assert(CR_impl.offsetof == 0x10);
	mixin defineVolatileAccessor!(CR_impl, "CR");
	mixin defineBitfields!(CR_impl,
		bool,  "PG",  1,
		bool,  "SER", 1,
		bool,  "MER", 1,
		ubyte, "SBN", 7-3,
		uint,  "CR_reserved_bit7", 1,
		ubyte, "PSIZE", 10-8,
		uint,  "CR_reserved_bit10_15", 16-10,
		bool,  "STRT", 1,
		uint,  "CR_reserved_bit17_23", 24-17,
		bool,  "EOPIE", 1,
		bool,  "ERRIE", 1,
		uint,  "CR_reserved_bit26_30", 31-26,
		bool,  "LOCK", 1);
	///
	private uint OPTCR_impl;
	static assert(OPTCR_impl.offsetof == 0x14);
	mixin defineVolatileAccessor!(OPTCR_impl, "OPTCR");
	mixin defineBitfields!(OPTCR_impl,
		bool,  "OPTLOCK", 1,
		bool,  "OPTSTRT", 1,
		ubyte, "BOR_LEV", 2,
		uint,  "OPTCR_reserved_bit4", 1,
		bool,  "WDG_SW", 1,
		bool,  "nRST_STOP", 1,
		bool,  "nRST_STDBY", 1,
		ubyte, "RDP", 8,
		ubyte, "nWRP", 8,
		uint,  "OPTCR_reserved_bit24_30", 31-24,
		bool,  "SPRMOD", 1);
}

/*******************************************************************************
 * 割り込み管理レジスタ
 */
struct PWR_TYPE
{
	///
	private uint CR_impl;
	static assert(CR_impl.offsetof == 0x00);
	mixin defineVolatileAccessor!(CR_impl, "CR");
	mixin defineBitfields!(CR_impl,
		bool,  "LPDS",  1,
		bool,  "PDDS",  1,
		bool,  "CWUF",  1,
		bool,  "CSBF",  1,
		bool,  "PVDE",  1,
		ubyte, "PLS",  3,
		bool,  "DBP",  1,
		bool,  "FPDS",  1,
		bool,  "LPLVDS",  1,
		bool,  "MRLVDS",  1,
		bool,  "CR_reserved_bit12", 1,
		bool,  "ADCDC1", 1,
		ubyte, "VOS", 2,
		uint,  "CR_reserved_bit16_31", 32-16);
	///
	private uint CSR_impl;
	static assert(CSR_impl.offsetof == 0x04);
	mixin defineVolatileAccessor!(CSR_impl, "CSR");
	mixin defineBitfields!(CSR_impl,
		bool,  "WUF",  1,
		bool,  "SBF",  1,
		bool,  "PVDO", 1,
		bool,  "BRR",  1,
		ubyte, "CSR_reserved_bit4_7",  4,
		bool,  "EWUP", 1,
		bool,  "BRE",  1,
		bool,  "VOSRDY", 1,
		bool,  "CSR_reserved_bit15_31", 32-15);
}


/*******************************************************************************
 * Timer
 */
struct TIMER_B_TYPE(string name)
{
	///
	private ushort CR1_impl;
	private ushort CR1_hiword_reserved;
	mixin defineVolatileAccessor!(CR1_impl, "CR1");
	mixin defineBitfields!(CR1_impl,
		bool,  "CEN",  1,
		bool,  "UDIS", 1,
		bool,  "URS",  1,
		bool,  "OPM",  1,
		bool,  "DIR",  1,
		ubyte, "CMS",  2,
		bool,  "ARPE", 1,
		ubyte, "CKD",  2,
		ushort, "CR1_reserved_bit10_16", 16-10);
	///
	private ushort CR2_impl;
	private ushort CR2_hiword_reserved;
	mixin defineVolatileAccessor!(CR2_impl, "CR2");
	mixin defineBitfields!(CR2_impl,
		ubyte, "CR2_reserved_bit0_2", 3-0,
		ubyte, "CCDS", 3,
		bool,  "TI1S", 1,
		ushort, "CR2_reserved_bit8_15", 16-8);
	///
	private ushort SMCR_impl;
	private ushort SMCR_hiword_reserved;
	mixin defineVolatileAccessor!(SMCR_impl, "SMCR");
	mixin defineBitfields!(SMCR_impl,
		ubyte, "SMS",  3-0,
		bool,  "SMCR_reserved_bit3", 1,
		ubyte, "TS",   3,
		bool,  "MSM",  1,
		ubyte, "ETF",  3,
		ubyte, "ETPS", 2,
		bool,  "ECE",  1);
	///
	private ushort DIER_impl;
	private ushort DIER_hiword_reserved;
	mixin defineVolatileAccessor!(DIER_impl, "DIER");
	mixin defineBitfields!(DIER_impl,
		bool, "UIE",   1,
		bool, "CC1IE", 1,
		bool, "CC2IE", 1,
		bool, "CC3IE", 1,
		bool, "CC4IE", 1,
		bool, "DIER_reserved_bit5", 1,
		bool, "TIE", 1,
		bool, "DIER_reserved_bit7", 1,
		bool, "UDE", 1,
		bool, "CC1DE", 1,
		bool, "CC2DE", 1,
		bool, "CC3DE", 1,
		bool, "CC4DE", 1,
		bool, "COMDE", 1,
		bool, "TDE", 1,
		bool, "DIER_reserved_bit15", 1);
	///
	private ushort SR_impl;
	private ushort SR_hiword_reserved;
	mixin defineVolatileAccessor!(SR_impl, "SR");
	mixin defineBitfields!(SR_impl,
		bool, "UIF",   1,
		bool, "CC1IF", 1,
		bool, "CC2IF", 1,
		bool, "CC3IF", 1,
		bool, "CC4IF", 1,
		bool, "SR_reserved_bit5", 1,
		bool, "TIF", 1,
		bool, "SR_reserved_bit7", 1,
		bool, "SR_reserved_bit8", 1,
		bool, "CC1OF", 1,
		bool, "CC2OF", 1,
		bool, "CC3OF", 1,
		bool, "CC4OF", 1,
		ushort, "SR_reserved_bit13_15", 16-13);
	///
	private ushort EGR_impl;
	private ushort EGR_hiword_reserved;
	mixin defineVolatileAccessor!(EGR_impl, "EGR");
	mixin defineBitfields!(EGR_impl,
		bool, "UG",   1,
		bool, "CC1G", 1,
		bool, "CC2G", 1,
		bool, "CC3G", 1,
		bool, "CC4G", 1,
		bool, "EGR_reserved_bit5", 1,
		bool, "TG", 1,
		uint, "EGR_reserved_bit7_15", 16-7);
	///
	private ushort CCMR1_impl;
	private ushort CCMR1_hiword_reserved;
	mixin defineVolatileAccessor!(CCMR1_impl, "CCMR1");
	mixin defineBitfields!(CCMR1_impl,
		ubyte, "CC1S",  2,
		bool,  "OC1FE", 1,
		bool,  "OC1PE", 1,
		ubyte, "OC1M",  3,
		bool,  "OC1CE", 1,
		ubyte, "CC2S",  2,
		bool,  "OC2FE", 1,
		bool,  "OC2PE", 1,
		ubyte, "OC2M",  3,
		bool,  "OC2CE", 1);
	mixin defineBitfields!(CCMR1_impl,
		ubyte, "CC1Si",  2,
		ubyte, "IC1PSC", 2,
		ubyte, "IC1F",   4,
		ubyte, "CC2Si",  2,
		ubyte, "IC2PSC", 2,
		ubyte, "IC2F",   3);
	///
	private ushort CCMR2_impl;
	private ushort CCMR2_hiword_reserved;
	mixin defineVolatileAccessor!(CCMR2_impl, "CCMR2");
	mixin defineBitfields!(CCMR2_impl,
		ubyte, "CC3S",  2,
		bool,  "OC3FE", 1,
		bool,  "OC3PE", 1,
		ubyte, "OC3M",  3,
		bool,  "OC3CE", 1,
		ubyte, "CC4S",  2,
		bool,  "OC4FE", 1,
		bool,  "OC4PE", 1,
		ubyte, "OC4M",  3,
		bool,  "OC4CE", 1);
	mixin defineBitfields!(CCMR2_impl,
		ubyte, "CC3Si",  2,
		ubyte, "IC3PSC", 2,
		ubyte, "IC3F",   4,
		ubyte, "CC4Si",  2,
		ubyte, "IC4PSC", 2,
		ubyte, "IC4F",   3);
	///
	private ushort CCER_impl;
	private ushort CCER_hiword_reserved;
	mixin defineVolatileAccessor!(CCER_impl, "CCER");
	mixin defineBitfields!(CCER_impl,
		bool, "CC1E",  1,
		bool, "CC1P", 1,
		bool, "CCER_reserved_bit2", 1,
		bool, "CC1NP", 1,
		bool, "CC2E",  1,
		bool, "CC2P",  1,
		bool, "CCER_reserved_bit6", 1,
		bool, "CC2NP", 1,
		bool, "CC3E",  1,
		bool, "CC3P",  1,
		bool, "CCER_reserved_bit10", 1,
		bool, "CC3NP", 1,
		bool, "CC4E",  1,
		bool, "CC4P",  1,
		bool, "CCER_reserved_bit14", 1,
		bool, "CC4NP", 1,
		uint, "CCER_reserved_bit16_31", 32-16);
	static if (name == "TIM2" || name == "TIM5")
	{
		///
		private uint CNT_impl;
		mixin defineVolatileAccessor!(CNT_impl, "CNT");
	}
	else
	{
		///
		private ushort CNT_impl;
		private ushort CNT_hiword_reserved;
		mixin defineVolatileAccessor!(CNT_impl, "CNT");
	}
	///
	private ushort PSC_impl;
	private ushort PSC_hiword_reserved;
	mixin defineVolatileAccessor!(PSC_impl, "PSC");
	///
	static if (name == "TIM2" || name == "TIM5")
	{
		///
		private uint ARR_impl;
		mixin defineVolatileAccessor!(ARR_impl, "ARR");
	}
	else
	{
		///
		private ushort ARR_impl;
		private ushort ARR_hiword_reserved;
		mixin defineVolatileAccessor!(ARR_impl, "ARR");
	}
	///
	static if (name == "TIM2" || name == "TIM5")
	{
		///
		private uint CCR1_impl;
		mixin defineVolatileAccessor!(CCR1_impl, "CCR1");
		///
		private uint CCR2_impl;
		mixin defineVolatileAccessor!(CCR2_impl, "CCR2");
		///
		private uint CCR3_impl;
		mixin defineVolatileAccessor!(CCR3_impl, "CCR3");
		///
		private uint CCR4_impl;
		mixin defineVolatileAccessor!(CCR4_impl, "CCR4");
	}
	else
	{
		///
		private ushort CCR1_impl;
		private ushort CCR1_hiword_reserved;
		mixin defineVolatileAccessor!(CCR1_impl, "CCR1");
		///
		private ushort CCR2_impl;
		private ushort CCR2_hiword_reserved;
		mixin defineVolatileAccessor!(CCR2_impl, "CCR2");
		///
		private ushort CCR3_impl;
		private ushort CCR3_hiword_reserved;
		mixin defineVolatileAccessor!(CCR3_impl, "CCR3");
		///
		private ushort CCR4_impl;
		private ushort CCR4_hiword_reserved;
		mixin defineVolatileAccessor!(CCR4_impl, "CCR4");
	}
	///
	private uint reserved1;
	///
	private uint DCR_impl;
	mixin defineVolatileAccessor!(DCR_impl, "DCR");
	mixin defineBitfields!(DCR_impl,
		ubyte, "DBA", 5,
		ubyte, "DCR_reserved_bit5_7", 8-5,
		ubyte, "DBL", 5,
		uint,  "DCR_reserved_bit13_31", 32-13);
	///
	private uint DMAR_impl;
	mixin defineVolatileAccessor!(DMAR_impl, "DMAR");
	mixin defineBitfields!(DMAR_impl,
		ushort, "DMAB", 16,
		uint,   "DMAR_reserved_bit16_31", 32-16);
	static if (name == "TIM2")
	{
		///
		private uint OR_impl;
		mixin defineVolatileAccessor!(OR_impl, "OR");
		mixin defineBitfields!(OR_impl,
			ushort, "OR_reserved_bit0_9", 10-0,
			ubyte,  "ITR1_RMP", 2,
			uint,   "OR_reserved_bit16_31", 32-12);
	}
	else static if (name == "TIM5")
	{
		///
		private uint OR_impl;
		mixin defineVolatileAccessor!(OR_impl, "OR");
		mixin defineBitfields!(OR_impl,
			ushort, "OR_reserved_bit0_5", 6-0,
			ubyte,  "ITR1_RMP", 2,
			uint,   "OR_reserved_bit8_31", 32-8);
	}
}


/*******************************************************************************
 * 割り込み管理レジスタ
 */
struct EXTI_TYPE
{
	///
	private uint IMR_impl;
	mixin defineVolatileAccessor!(IMR_impl, "IMR");
	mixin defineBitfields!(IMR_impl,
		bool,  "IMR0",  1,
		bool,  "IMR1",  1,
		bool,  "IMR2",  1,
		bool,  "IMR3",  1,
		bool,  "IMR4",  1,
		bool,  "IMR5",  1,
		bool,  "IMR6",  1,
		bool,  "IMR7",  1,
		bool,  "IMR8",  1,
		bool,  "IMR9",  1,
		bool,  "IMR10", 1,
		bool,  "IMR11", 1,
		bool,  "IMR12", 1,
		bool,  "IMR13", 1,
		bool,  "IMR14", 1,
		bool,  "IMR15", 1,
		bool,  "IMR16", 1,
		bool,  "IMR17", 1,
		bool,  "IMR18", 1,
		bool,  "IMR_reserved_bit19", 1,
		bool,  "IMR_reserved_bit20", 1,
		bool,  "IMR21", 1,
		bool,  "IMR22", 1,
		bool,  "IMR_reserved_bit23_31", 32-23);
	///
	private uint EMR_impl;
	mixin defineVolatileAccessor!(EMR_impl, "EMR");
	mixin defineBitfields!(EMR_impl,
		bool,  "EMR0",  1,
		bool,  "EMR1",  1,
		bool,  "EMR2",  1,
		bool,  "EMR3",  1,
		bool,  "EMR4",  1,
		bool,  "EMR5",  1,
		bool,  "EMR6",  1,
		bool,  "EMR7",  1,
		bool,  "EMR8",  1,
		bool,  "EMR9",  1,
		bool,  "EMR10", 1,
		bool,  "EMR11", 1,
		bool,  "EMR12", 1,
		bool,  "EMR13", 1,
		bool,  "EMR14", 1,
		bool,  "EMR15", 1,
		bool,  "EMR16", 1,
		bool,  "EMR17", 1,
		bool,  "EMR18", 1,
		bool,  "EMR_reserved_bit19", 1,
		bool,  "EMR_reserved_bit20", 1,
		bool,  "EMR21", 1,
		bool,  "EMR22", 1,
		bool,  "EMR_reserved_bit23_31", 32-23);
	///
	private uint RTSR_impl;
	mixin defineVolatileAccessor!(RTSR_impl, "RTSR");
	mixin defineBitfields!(RTSR_impl,
		bool,  "RTSR0",  1,
		bool,  "RTSR1",  1,
		bool,  "RTSR2",  1,
		bool,  "RTSR3",  1,
		bool,  "RTSR4",  1,
		bool,  "RTSR5",  1,
		bool,  "RTSR6",  1,
		bool,  "RTSR7",  1,
		bool,  "RTSR8",  1,
		bool,  "RTSR9",  1,
		bool,  "RTSR10", 1,
		bool,  "RTSR11", 1,
		bool,  "RTSR12", 1,
		bool,  "RTSR13", 1,
		bool,  "RTSR14", 1,
		bool,  "RTSR15", 1,
		bool,  "RTSR16", 1,
		bool,  "RTSR17", 1,
		bool,  "RTSR18", 1,
		bool,  "RTSR_reserved_bit19", 1,
		bool,  "RTSR_reserved_bit20", 1,
		bool,  "RTSR21", 1,
		bool,  "RTSR22", 1,
		bool,  "RTSR_reserved_bit23_31", 32-23);
	///
	private uint FTSR_impl;
	mixin defineVolatileAccessor!(FTSR_impl, "FTSR");
	mixin defineBitfields!(RTSR_impl,
		bool,  "FTSR0",  1,
		bool,  "FTSR1",  1,
		bool,  "FTSR2",  1,
		bool,  "FTSR3",  1,
		bool,  "FTSR4",  1,
		bool,  "FTSR5",  1,
		bool,  "FTSR6",  1,
		bool,  "FTSR7",  1,
		bool,  "FTSR8",  1,
		bool,  "FTSR9",  1,
		bool,  "FTSR10", 1,
		bool,  "FTSR11", 1,
		bool,  "FTSR12", 1,
		bool,  "FTSR13", 1,
		bool,  "FTSR14", 1,
		bool,  "FTSR15", 1,
		bool,  "FTSR16", 1,
		bool,  "FTSR17", 1,
		bool,  "FTSR18", 1,
		bool,  "FTSR_reserved_bit19", 1,
		bool,  "FTSR_reserved_bit20", 1,
		bool,  "FTSR21", 1,
		bool,  "FTSR22", 1,
		bool,  "FTSR_reserved_bit23_31", 32-23);
	///
	private uint SWIER_impl;
	mixin defineVolatileAccessor!(SWIER_impl, "SWIER");
	mixin defineBitfields!(SWIER_impl,
		bool,  "SWIER0",  1,
		bool,  "SWIER1",  1,
		bool,  "SWIER2",  1,
		bool,  "SWIER3",  1,
		bool,  "SWIER4",  1,
		bool,  "SWIER5",  1,
		bool,  "SWIER6",  1,
		bool,  "SWIER7",  1,
		bool,  "SWIER8",  1,
		bool,  "SWIER9",  1,
		bool,  "SWIER10", 1,
		bool,  "SWIER11", 1,
		bool,  "SWIER12", 1,
		bool,  "SWIER13", 1,
		bool,  "SWIER14", 1,
		bool,  "SWIER15", 1,
		bool,  "SWIER16", 1,
		bool,  "SWIER17", 1,
		bool,  "SWIER18", 1,
		bool,  "SWIER_reserved_bit19", 1,
		bool,  "SWIER_reserved_bit20", 1,
		bool,  "SWIER21", 1,
		bool,  "SWIER22", 1,
		bool,  "SWIER_reserved_bit23_31", 32-23);
	///
	private uint PR_impl;
	mixin defineVolatileAccessor!(PR_impl, "PR");
	mixin defineBitfields!(PR_impl,
		bool,  "PR0",  1,
		bool,  "PR1",  1,
		bool,  "PR2",  1,
		bool,  "PR3",  1,
		bool,  "PR4",  1,
		bool,  "PR5",  1,
		bool,  "PR6",  1,
		bool,  "PR7",  1,
		bool,  "PR8",  1,
		bool,  "PR9",  1,
		bool,  "PR10", 1,
		bool,  "PR11", 1,
		bool,  "PR12", 1,
		bool,  "PR13", 1,
		bool,  "PR14", 1,
		bool,  "PR15", 1,
		bool,  "PR16", 1,
		bool,  "PR17", 1,
		bool,  "PR18", 1,
		bool,  "PR_reserved_bit19", 1,
		bool,  "PR_reserved_bit20", 1,
		bool,  "PR21", 1,
		bool,  "PR22", 1,
		bool,  "PR_reserved_bit23_31", 32-23);
}
///
enum TIM2  = cast(TIMER_B_TYPE!"TIM2"*)  0x40000000;
///
enum TIM3  = cast(TIMER_B_TYPE!"TIM3"*)  0x40000400;
///
enum TIM4  = cast(TIMER_B_TYPE!"TIM4"*)  0x40000800;
///
enum TIM5  = cast(TIMER_B_TYPE!"TIM5"*)  0x40000C00;
///
enum PWR  = cast(PWR_TYPE*)   0x40007000;
///
enum GPIOA = cast(GPIO_TYPE*) 0x40020000;
///
enum RCC   = cast(RCC_TYPE*)  0x40023800;
///
enum FLASH = cast(FLASH_TYPE*) 0x40023C00;
///
enum EXTI  = cast(EXTI_TYPE*) 0x40013C00;

///
enum STK   = cast(STK_TYPE*)  0xE000E010;
///
enum NVIC  = cast(NVIC_TYPE*) 0xE000E100;
///
enum SCB   = cast(SCB_TYPE*)  0xE000ED00;