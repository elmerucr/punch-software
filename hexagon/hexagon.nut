// ---------------------------------------------------------------------
// hexagon.nut
//
// (C)2024 elmerucr
// ---------------------------------------------------------------------

 dofile("hexagon_data.nut")

 offset_x <- 136
 offset_y <- 78

 function init()
 {
	 for (local i=0; i<sprite.size; i++) {
		 vpoke(0x10000+i, sprite.data[i])
	 }

	 poke16(0x0a14, 15)	// width
	 poke16(0x0a16, 10)	// height
	 poke(0x0a19, 0x01)
	 poke(0x0a1a, 0x00)
	 poke(0x0a1b, 0x00)
	 poke(0x0a1c, 0x40)	// flags_0 color mode 32 bit
	 poke(0x0a1d, 0x00)	// flags_1
	 poke(0x0a1e, 0x00)	// flags_2
	 poke(0x0a1f, 0)

	// -----------------------------------------------------------------
	// Activate frame done interrupt which happens directly after each
	// screen refresh and calls the squirrel frame() function.
	// -----------------------------------------------------------------
	poke(0x401, 1)
}

function frame()
{
	poke(0x805, 0x01)	// target color (black)
	//poke(0x818, 255)	// alpha value
	poke(0x81c, 255)	// max gamma

	poke(0x803, 0)		// destination surface = 0x0 = screen
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
		 offset_y += 0.5
	 }
	 if ((peek(0x580 + 0x43) & 1) != 0) {
		 // cursor down
		 offset_y -= 0.5
	 }

	for (local y=-8; y<9; y++) {
		for (local x=-8; x<9; x++) {
			if (x & 1) {
				local dist = (x*x)+(y*y)
				local ry = (81-offset_y)/7
				local rx = (136-offset_x)/9
				local od = (rx-x)*(rx-x)+(ry-y)*(ry-y)

				// do gamma values
				if (od <= 25) {
					poke(0x81c, 255)
				} else if (od <= 85) {
					poke(0x81c, 255-(3*od))
				} else {
					poke(0x81c, 0)
				}

				poke16(0x0a10, offset_x + (12 * x))
				//poke16(0x0a12, offset_y + (8 * y) + ((x & 1) ? -4 : 0)    )
				poke16(0x0a12, offset_y + (8 * y) - 4)
				poke(0x801, 1)
			}
		}
		for (local x=-8; x<9; x++) {
			if (!(x & 1)) {
				local dist = (x*x)+(y*y)
				local ry = (81-offset_y)/7
				local rx = (136-offset_x)/9
				local od = (rx-x)*(rx-x)+(ry-y)*(ry-y)

				// do gamma values
				if (od <= 25) {
					poke(0x81c, 255)
				} else if (od <= 85) {
					poke(0x81c, 255-(3*od))
				} else {
					poke(0x81c, 0)
				}

				poke16(0x0a10, offset_x + (12 * x))
				//poke16(0x0a12, offset_y + (8 * y) + ((x & 1) ? -4 : 0)    )
				poke16(0x0a12, offset_y + (8 * y))
				poke(0x801, 1)
			}
		}
	}

	// green cursor
	poke(0x805,0x33)	// draw color = green
	poke(0x81c, 0xff)	// gamma
	poke16(0x0808, 143)	// x0
	poke16(0x080a, 81)	// y0
	poke(0x801, 8)		// pset
}
