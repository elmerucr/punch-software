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
		poke(0x1100+i, sprite.palette[i])
	}

	poke16(0x0a14, 16)
	poke16(0x0a16, 16)
	poke(0x0a19, 0x01)
	poke(0x0a1a, 0x00)
	poke(0x0a1b, 0x00)
	poke(0x0a1c, 0x20)
	poke(0x0a1d, 0x00)
	poke(0x0a1e, 0x00)
	poke(0x0a1f, 0x03)

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
		offset_x +=2
	}
	if ((peek(0x580 + 0x44) & 1)!= 0) {
		// cursor right
		offset_x -=2
	}
	if ((peek(0x580 + 0x42) & 1) != 0) {
		// cursor up
		offset_y += 1
	}
	if ((peek(0x580 + 0x43) & 1) != 0) {
		// cursor down
		offset_y -= 1
	}

	local offset_z = 0

	for (local z=-1; z<2; z++) {
		for (local y=-40; y<40; y++) {
			for (local x=-40; x<40; x++) {
				local dist = (x*x)+(y*y)

				local ry = (-(offset_y-100)/8) + ((offset_x-152)/16)
				local rx = (-(offset_y-100)/8) + (-(offset_x-152)/16)
				local od = (rx-x)*(rx-x)+(ry-y)*(ry-y)
				if (od <= 85) {
					poke(0x819, 255-(3*od))
					poke(0x81a, 255-(3*od))
					poke(0x81b, 255-(3*od))
				} else {
					poke(0x819, 0)
					poke(0x81a, 0)
					poke(0x81b, 0)
				}

				if (z == -1) {
					poke(0x0a1f, 2)	// dirt
					if (dist < 400) {
						poke16(0x0a10, offset_x + (8 * x) - (8 * y))
						poke16(0x0a12, offset_y + (4 * x) + (4 * y) - (8 * z))
						poke(0x801, 0x01)
					}
				} else {
					poke(0x0a1f, 3)	// stones
					if ((dist < 200) && (dist > 50)) {
						poke16(0x0a10, offset_x + (8 * x) - (8 * y))
						poke16(0x0a12, offset_y + (4 * x) + (4 * y) - (8 * z))
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
	poke16(0x0808, 160)
	poke16(0x080a, 100)
	poke(0x801, 0x08)
}
