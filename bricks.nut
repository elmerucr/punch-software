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
		poke(0x1110+i, sprite.palette[i])
	}

	poke16(0x1014, 16)
	poke16(0x1016, 16)
	poke(0x1019, 0x01)
	poke(0x101a, 0x00)
	poke(0x101b, 0x00)
	poke(0x101c, 0x20)
	poke(0x101d, 0x00)
	poke(0x101e, 0x00)
	poke(0x101f, 0x03)

	/*
	 * Activate frame done interrupt which happens directly after each
	 * screen refresh and calls the squirrel frame() function.
	 */
	poke(0x401, 1)
}

function frame()
{
	poke(0xe05, 0x00)	// target color
	poke(0xe03, 0x0)	// destination surface = 0x0 = screen
	poke(0xe01, 4)		// clear surface command

	poke(0xe02,0x1)		// src surface = 0x1
	poke(0xe03,0x0)		// dest surface = 0x0

	if ((peek(0x580 + 0x41) & 1) != 0) {
		// cursor left
		offset_x++
	}
	if ((peek(0x580 + 0x44) & 1)!= 0) {
		// cursor right
		offset_x--
	}
	if ((peek(0x580 + 0x42) & 1) != 0) {
		// cursor up
		offset_y += 0.5
	}
	if ((peek(0x580 + 0x43) & 1) != 0) {
		// cursor down
		offset_y -= 0.5
	}

	local offset_z = 0

	for (local z=-1; z<2; z++) {
		for (local y=-20; y<20; y++) {
			for (local x=-20; x<20; x++) {
				local dist = (x*x)+(y*y)
				if (z == -1) {
					poke(0x101f, 2)	// dirt
					if (dist < 160) {
						poke16(0x1010, offset_x + (8 * x) - (8 * y))
						poke16(0x1012, offset_y + (4 * x) + (4 * y) - (8 * z))
						poke(0xe01, 0x01)
					}
				} else {
					poke(0x101f, 3)	// stones
					if ((dist < 70) && (dist > 50)) {
						poke16(0x1010, offset_x + (8 * x) - (8 * y))
						poke16(0x1012, offset_y + (4 * x) + (4 * y) - (8 * z))
						poke(0xe01, 0x01)
					}
				}
			}
		}
	}

	poke16(0x1010, 160)
	poke16(0x1012, 100)
	poke(0x101f, 1) // "shadow"
	poke(0xe01, 0x01) // blit it
}
