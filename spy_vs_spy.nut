/*
 * spy_vs_spy.nut
 * Version 20240815
 * elmerucr
 */

function startthread(f, t) {
	tasks.append([::newthread(f), t])
}

function init() {
	/*
	 * Cause frame done interrupt just after screen refresh and a call
	 * to the frame() function.
	 */
	poke(0x801, 1)

	/*
	 * Timer stuff. Timer0 at 3008bpm, and activate it. This will call
	 * squirrel timer0() function.
	 */
	poke16(0xa10, 3008)
	poke(0xa01, 1)

	// hack for screen background color
	color <- 16
	count <- 10

	// coroutines always start idle, so must use call() once
	co_lines <- ::newthread(draw_lines)
	co_lines.call()

	/*
	 * Empty array for tasks
	 */
	tasks <- []
	startthread(do_track, 0)
	startthread(do_track, 1)
	startthread(do_track, 2)
	foreach (task in tasks) {
		task[0].call(task[1])
	}
}

function timer0() {
	foreach (t in tasks) {
		t[0].wakeup(t[1])
	}
}

function draw_lines() {
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
		if (x0 == 319) dx = -dx
		if (x0 == 0) dx = -dx
		rectangle(10, 10, 40, 40, 0xc3, 15)
	}
}

function frame() {
	poke(0xe05, color)	// target color
	poke(0xe03, 0xf)	// target surface = 0xf
	poke(0xe01, 4)		// clear surface command
	if (count == 0) {
		color++
		count = 10
	}
	count--
	if (color == 20) color = 16

	co_lines.wakeup()
}

song <- {
	instruments = [
		[ 0x0f0f, 0x04, 0x15, 0x41 ],	// bass
		[ 0x0000, 0x26, 0x14, 0x11 ],	// flute
		[ 0x0000, 0x01, 0x12, 0x81 ]	// snare
	]
	patterns = [
		[
			[  0, 60, 0 ], [ 95, 20, 2 ]
		],
		[
			[ 38, 10,  0 ], [ 50, 10,  0 ], [ 57, 10,  0 ], [ 62, 10,  0 ],
			[ 38, 10,  0 ], [ 50, 10,  0 ], [ 95, 20,  2 ]
		],
		[
			[ 34, 10,  0 ], [ 46, 10,  0 ], [ 53, 10,  0 ], [ 58, 10,  0 ],
			[ 34, 10,  0 ], [ 46, 10,  0 ], [ 95, 20,  2 ]
		],
		[
			[ 31, 10,  0 ], [ 43, 10,  0 ], [ 50, 10,  0 ], [ 55, 10,  0 ],
			[ 31, 10,  0 ], [ 43, 10,  0 ], [ 95, 20,  2 ]
		],
		[
			[ 36, 10,  0 ], [ 48, 10,  0 ], [ 55, 10,  0 ], [ 60, 10,  0 ],
			[ 33, 10,  0 ], [ 45, 10,  0 ], [ 52, 10,  0 ], [ 57, 10,  0 ]
		],
		[
			[ 77, 80,  1 ], [ 74, 60,  1 ], [ 77, 20,  1 ], [ 70, 60,  1 ],
			[ 72, 10,  1 ], [ 70, 10,  1 ], [ 69, 80,  1 ], [ 65,160,  1 ],
			[ 67, 20,  1 ], [ 70, 40,  1 ], [ 67, 20,  1 ], [ 69, 80,  1 ]
		]
	]
	tracks = [
		[1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4],
		[0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1],
		[5, 0, 0, 0, 0]
	]
}

function do_track(track_no) {
	while (true) {
		foreach (pattern_no in song.tracks[track_no]) {
			foreach (note in song.patterns[pattern_no]) {
				local instr = song.instruments[note[2]]
				if (note[0] != 0) {
					poke16(0xc80 + (track_no * 8), midi[note[0]])
					poke16(0xc82 + (track_no * 8), instr[0])
					poke  (0xc85 + (track_no * 8), instr[1])
					poke  (0xc86 + (track_no * 8), instr[2])
					poke  (0xc84 + (track_no * 8), instr[3])
				}
				breakhere(note[1] - 2)
				// end note
				poke(0xc85 + (track_no * 8), 0x00)
				poke(0xc86 + (track_no * 8), 0x00)
				poke(0xc84 + (track_no * 8), instr[3] - 1)
				breakhere(2)
			}
		}
	}
}
