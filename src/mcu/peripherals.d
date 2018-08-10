module src.mcu.peripherals;

import src.mcu.regs;
import src.mcu.op;
import src.mcu.interrupts;


//##############################################################################
//######     パブリック関数
//##############################################################################
/*******************************************************************************
 * 
 */
void initHardware() nothrow @nogc
{
	initGpio();
	initTimer();
}


void setLedOn()() nothrow @nogc
{
	GPIOA.BS5  = 1;
}

void setLedOff()() nothrow @nogc
{
	GPIOA.BR5  = 1;
}

//##############################################################################
//######     プライベート関数
//##############################################################################
private:


/*******************************************************************************
 * 
 */
void initGpio() nothrow @nogc
{
	// GPIOAを有効にします
	RCC.GPIOAEN = true;
	// PA5を出力に
	GPIOA.MODER5 = 0b01;
	// プッシュプルに設定
	// (デフォルトから変更しない)
	GPIOA.OT5 = 0b00;
}

__gshared uint timerCount = 0;
__gshared bool stsLedToggle;
/// 500us毎割り込み
void onInterval() nothrow @nogc
{
	timerCount++;
	if (timerCount > 1000)
	{
		timerCount = 0;
		// 0.5s毎
		if (stsLedToggle)
			setLedOn();
		else
			setLedOff();
		stsLedToggle = !stsLedToggle;
	}
}


/*******************************************************************************
 * 
 */
void initTimer() nothrow @nogc
{
	//------------------------------------------
	// タイマ2の設定
	//------------------------------------------
	RCC.TIM2EN = true;
	// APB1 timer clocksは84MHzで動作(APBxPRESC != 1 -> x2)
	// プリスケーラ 1/8 * 84MHz = 10.5MHz
	TIM2.PSC = 8-1;
	// アウトプット(コンペアマッチ)モード
	TIM2.CC1S = 0;
	// カウント方向はアップカウント
	TIM2.DIR = 0;
	// オーバーフローで割り込み
	TIM2.UIE = 1;
	// カウント初期値0
	TIM2.CNT = 0;
	// 0.0005s * 10.5MHz ARRのマッチでゼロクリア
	TIM2.ARR = 5250-1;
	// コールバックの設定
	onTim2.set(&onInterval);
	// カウンタ開始
	TIM2.CEN = true;
	
	// 割り込み優先度設定
	NVIC.IPR[35]  = 7;
	NVIC.SETPEND28 = true;
	NVIC.SETENA28 = true;
}
