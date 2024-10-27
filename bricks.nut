

dofile("iso_brick.nut")

function init()
{
	for (local i=0; i<sprite.size; i++) {
		vpoke(0x10000+i, sprite.data[i])
	}
	for (local i=0; i<sprite.palette.len(); i++) {
		poke(0x510+i, sprite.palette[i])
	}

	poke16(0x414, 16)
	poke16(0x416, 16)
	poke(0x419, 0x01)
	poke(0x41a, 0x00)
	poke(0x41b, 0x00)
	poke(0x41c, 0x20)
	poke(0x41d, 0x00)
	poke(0x41e, 0x00)
	poke(0x41f, 0x02)

	/*
	 * Activate frame done interrupt which happens directly after each
	 * screen refresh and calls the squirrel frame() function.
	 */
	poke(0x801, 1)
}

function frame()
{
	poke(0xe05, 0x00)	// target color
	poke(0xe03, 0x0)	// destination surface = 0x0
	poke(0xe01, 4)		// clear surface command

	poke(0xe02,0x1)
	poke(0xe03,0x0)

	local offset_x = 152;
	local offset_y = 100

	for (local y=-10; y<10; y++) {
		for (local x=-10; x<10; x++) {
			local dist = (x*x)+(y*y)
			if ((dist < 70) && (dist > 20)) {
				poke16(0x410, offset_x + (8 * x) - (8 * y))
				poke16(0x412, offset_y + (4 * x) + (4 * y))
				poke(0xe01,1)
			}
		}
	}
}
