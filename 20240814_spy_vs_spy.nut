/*
 * spy_vs_spy.nut
 * Version 20240814
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

instrument <- [
	[ 0x0f0f, 0x04, 0x15, 0x41 ],	// bass
	[ 0x0000, 0x26, 0x14, 0x11 ],	// flute
	[ 0x0000, 0x01, 0x12, 0x81 ]	// snare
]

pattern <- [
	[
		[ 0, 95],
		[60, 20],
		[ 0,  2]
	],
	[
		[38, 50, 57, 62, 38, 50, 95],
		[10, 10, 10, 10, 10, 10, 20],
		[ 0,  0,  0,  0,  0,  0,  2]
	],
	[
		[34, 46, 53, 58, 34, 46, 95],
		[10, 10, 10, 10, 10, 10, 20],
		[ 0,  0,  0,  0,  0,  0,  2]
	],
	[
		[31, 43, 50, 55, 31, 43, 95],
		[10, 10, 10, 10, 10, 10, 20],
		[ 0,  0,  0,  0,  0,  0,  2]
	],
	[
		[36, 48, 55, 60, 33, 45, 52, 57],
		[10, 10, 10, 10, 10, 10, 10, 10],
		[ 0,  0,  0,  0,  0,  0,  0,  0]
	],
	// melody
	[
		[77, 74, 77, 70, 72, 70, 69, 65, 67, 70, 67, 69],
		[80, 60, 20, 60, 10, 10, 80,160, 20, 40, 20, 80],
		[ 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1]
	]
]

song <- [
	[1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4],
	[0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1],
	[5, 0, 0, 0, 0]
]

function do_track(track_no) {
	while (true) {
		for (local i=0; i < song[track_no].len(); i++) {
			// iterate through number of patterns in track
			for (local j=0; j < pattern[ song[track_no][i] ][0].len(); j++) {
				// iterate through number of notes in pattern
				local note = pattern[song[track_no][i]][0][j]
				local instr = instrument[pattern[ song[track_no] [i]][2][j]]
				// start note if not equal to 0
				if (note != 0) {
					poke16(0xc80 + (track_no * 8), midi[note])
					poke16(0xc82 + (track_no * 8), instr[0])
					poke(0xc85 + (track_no * 8), instr[1])
					poke(0xc86 + (track_no * 8), instr[2])
					poke(0xc84 + (track_no * 8), instr[3])
				}
				breakhere(pattern[song[track_no][i]][1][j] - 2)
				// end note
				poke(0xc85 + (track_no * 8), 0x00)
				poke(0xc86 + (track_no * 8), 0x00)
				poke(0xc84 + (track_no * 8), instr[3] - 1)
				breakhere(2)
			}
		}
	}
}
