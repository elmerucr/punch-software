

dofile("iso_brick.nut")

function init()
{
	for (local i=0; i<sprite.size; i++) {
		vpoke(0x10000+i, sprite.data[i])
	}
	for (local i=0; i<sprite.palette.len(); i++) {
		poke(0x500+i, sprite.palette[i])
	}

	poke16(0x404, 16)
	poke16(0x406, 16)
	poke(0x409, 0x01)
	poke(0x40a, 0x00)
	poke(0x40b, 0x00)
	poke(0x40c, 0x20)
	poke(0x40d, 0x00)
	poke(0x40e, 0x00)
	poke(0x40f, 0x00)

	//poke16(0x400, 152)
	//poke16(0x402, 90)

	/*
	 * Activate frame done interrupt which happens directly after each
	 * screen refresh and calls the squirrel frame() function.
	 */
	poke(0x801, 1)
}

function frame()
{
	poke(0xe05, 0x00)	// target color
	poke(0xe03, 0xf)	// target surface = 0xf
	poke(0xe01, 4)		// clear surface command

	poke(0xe02,0x0)
	poke(0xe03,0xf)

	local offset_x = 152;
	local offset_y = 100

	for (local x=-4; x<4; x++) {
		poke16(0x400, offset_x + (8 * x))
		poke16(0x402, offset_y + (4 * x))
		poke(0xe01,1)
	}
}
