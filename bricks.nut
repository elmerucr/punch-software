/*
 * bricks.nut
 *
 * An isometric example of a minecraft like dungeon system
 * (C)2024 elmerucr
 */

dofile("iso_brick.nut")

offset_x <- 152
offset_y <- 100

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
	poke(0x41f, 0x03)

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

	if ((peek(0x980 + 0x41) & 1) != 0) {
		// cursor left
		offset_x++
	}
	if ((peek(0x980 + 0x44) & 1)!= 0) {
		// cursor right
		offset_x--
	}
	if ((peek(0x980 + 0x42) & 1) != 0) {
		// cursor up
		offset_y += 0.5
	}
	if ((peek(0x980 + 0x43) & 1) != 0) {
		// cursor down
		offset_y -= 0.5
	}

	local offset_z = 0

	for (local z=-1; z<2; z++) {
		for (local y=-20; y<20; y++) {
			for (local x=-20; x<20; x++) {
				local dist = (x*x)+(y*y)
				if (z == -1) {
					poke(0x41f, 2)	// dirt
					if (dist < 160) {
						poke16(0x410, offset_x + (8 * x) - (8 * y))
						poke16(0x412, offset_y + (4 * x) + (4 * y) - (8 * z))
						poke(0xe01, 1)
					}
				} else {
					poke(0x41f, 3)	// stones
					if ((dist < 70) && (dist > 50)) {
						poke16(0x410, offset_x + (8 * x) - (8 * y))
						poke16(0x412, offset_y + (4 * x) + (4 * y) - (8 * z))
						poke(0xe01, 1)
					}
				}
			}
		}
	}
}
