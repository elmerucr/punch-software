/*
 * bricks.nut
 *
 * An isometric example of a minecraft like dungeon system
 * (C)2024 elmerucr
 */

dofile("16-11-11_data.nut")

offset_x <- 136
offset_y <- 81

function init()
{
	for (local i=0; i<sprite.size; i++) {
		vpoke(0x10000+i, sprite.data[i])
	}

	poke16(0x0a14, 16)
	poke16(0x0a16, 22)
	poke(0x0a19, 0x01)
	poke(0x0a1a, 0x00)
	poke(0x0a1b, 0x00)
	poke(0x0a1c, 0x40)
	poke(0x0a1d, 0x00)
	poke(0x0a1e, 0x00)

	/*
	 * Activate frame done interrupt which happens directly after each
	 * screen refresh and calls the squirrel frame() function.
	 */
	poke(0x401, 1)
}

function frame()
{
	poke(0x805, 0x01)	// target color
	poke(0x819, 0xff)	// max gamma r
	poke(0x81a, 0xff)	// max gamma g
	poke(0x81b, 0xff)	// max gamma b
	// vpoke(0xf3e800, 0x05);
	// vpoke(0xf3e801, 0x00);
	// vpoke(0xf3e802, 0xf0);
	// vpoke(0xf3e803, 0x00);
	poke(0x803, 0x0)	// destination surface = 0x0 = screen
	poke(0x801, 4)		// clear surface command

	poke(0x802,0x1)		// src surface = 0x1
	poke(0x803,0x0)		// dest surface = 0x0

	if ((peek(0x580 + 0x41) & 1) != 0) {
		// cursor left
		offset_x += 1
	}
	if ((peek(0x580 + 0x44) & 1)!= 0) {
		// cursor right
		offset_x -= 1
	}
	if ((peek(0x580 + 0x42) & 1) != 0) {
		// cursor up
		offset_y += 1
	}
	if ((peek(0x580 + 0x43) & 1) != 0) {
		// cursor down
		offset_y -= 1
	}

	for (local z=0; z<2; z++) {
		for (local y=-40; y<40; y++) {
			for (local x=-40; x<40; x++) {
				local dist = (x*x)+(y*y)

				local ry = (81-offset_y)/11
				local rx = (136-offset_x)/16
				local od = (rx-x)*(rx-x)+(ry-y)*(ry-y)
				if (od <= 45) {
					poke(0x819, 255)
					poke(0x81a, 255)
					poke(0x81b, 255)
					// poke(0x819, 255-(3*od))
					// poke(0x81a, 255-(3*od))
					// poke(0x81b, 255-(3*od))
				} else if (od <= 65) {
					poke(0x819, 255-(3*od))
					poke(0x81a, 255-(3*od))
					poke(0x81b, 255-(3*od))
				} else {
					poke(0x819, 0)
					poke(0x81a, 0)
					poke(0x81b, 0)
				}

				if (z == 0) {
					poke(0x0a1f, 1)	// dirt
					if (dist < 400) {
						poke16(0x0a10, offset_x + (16 * x))
						poke16(0x0a12, offset_y + (11 * y) - (11 * z))
						poke(0x801, 0x01)
					}
				} else {
					poke(0x0a1f, 0)	// stones
					if ((dist < 100) && (dist > 30)) {
						poke16(0x0a10, offset_x + (16 * x))
						poke16(0x0a12, offset_y + (11 * y) - (11 * z))
						poke(0x801, 0x01)
					}
				}
			}
		}
	}

	poke(0x805,0x33)
	poke(0x819, 0xff)
	poke(0x81a, 0xff)
	poke(0x81b, 0xff)
	poke16(0x0808, 144)
	poke16(0x080a, 81)
	poke(0x801, 0x08)
}
