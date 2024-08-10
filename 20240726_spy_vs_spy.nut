/*
 * spy_vs_spy.nut
 *
 * Version 20240726
 */

local color = 16
local count = 10

function breakhere(number)
{
	for (local i = 0; i < number; i++) {
		::suspend()
	}
}

function draw_lines()
{
	local x0 = 0
	local y0 = 0
	local dx = 1
	local dy = 1

	while (true) {
		breakhere(1)

		solid_rectangle(150, 90, 155, 110, 0xc3, 15)
		line(x0, y0, 319 - x0, 179, 51, 15)
		line(x0, 179, 319 - x0, 0, 51, 15)
		x0 = x0 + dx
		if (x0 == 319) {
			dx = -dx
		}
		if (x0 == 0){
			dx = -dx
		}
		rectangle(10, 10, 40, 40, 0xc3, 15)
	}
}

function line(x0, y0, x1, y1, color, surface)
{
	poke16(0xe08, x0)
	poke16(0xe0a, y0)
	poke16(0xe0c, x1)
	poke16(0xe0e, y1)
	poke(0xe05, color)
	poke(0xe03, surface)
	poke(0xe01, 0x08)
}

function rectangle(x0, y0, x1, y1, color, surface)
{
	poke16(0xe08, x0)
	poke16(0xe0a, y0)
	poke16(0xe0c, x1)
	poke16(0xe0e, y1)
	poke(0xe05, color)
	poke(0xe03, surface)
	poke(0xe01, 0x10)
}

function solid_rectangle(x0, y0, x1, y1, color, surface)
{
	poke16(0xe08, x0)
	poke16(0xe0a, y0)
	poke16(0xe0c, x1)
	poke16(0xe0e, y1)
	poke(0xe05, color)
	poke(0xe03, surface)
	poke(0xe01, 0x20)
}

// coroutines always start idle, so must use call()
local co_lines = ::newthread(draw_lines)
co_lines.call()

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

	co_lines.wakeup()
}

function init()
{
	/*
	 * Cause frame done interrupt just after screen refresh and a call
	 * to the frame() function.
	 */
	poke(0x801, 1)

	/*
	 * Timer stuff. Timer0 at 3008bpm, and activate.
	 */
	//poke16(0xa10, 3008)
	//poke(0xa01, 1)
}
