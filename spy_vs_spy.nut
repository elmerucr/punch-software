/*
 * spy_vs_spy.nut
 *
 * Version 20240725
 */

local color = 16
local count = 10

function frame()
{
	poke(0xe05, color)	// target color
	poke(0xe03, 0xf)	// target surface = 0xf
	poke(0xe01, 4)		// clear surface command
	if (count == 0) {
		color++
		count = 10
	}
	count--
	if (color == 20) {
		color = 16
	}
}

function init()
{
	/*
	 * cause frame interrupt and call to frame() function
	 */
	poke(0x801, 1)

	/*
	 * timer stuff
	 */
	//poke16(0xa10, 3008)
	//poke(0xa01, 1)		// calling timer0()
}
