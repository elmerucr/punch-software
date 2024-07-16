-- Newer version 20240716
-- Uses coroutines

local color = 16
local count = 0

function breakhere(no)
	for i=1, no do
		coroutine.yield()
	end
end

function init()
	-- make blitter cause interrupts at start of frame
	-- this will call the lua function frame()
	poke(0x801, 1)

	-- timer stuff, 3008bpm
	-- this will call the lua function timer0()
	poke16(0xa10, 3008)
	poke(0xa01, 1)

	co_t1 = coroutine.create(do_track)
	co_t2 = coroutine.create(do_track)
	co_t3 = coroutine.create(do_track)
end

function timer0()
	coroutine.resume(co_t1, 1)
	coroutine.resume(co_t2, 2)
	coroutine.resume(co_t3, 3)
end

function frame()
	poke(0xe05, color)	-- target color
	poke(0xe03, 0xf)	-- target surface = 0xf
	poke(0xe01, 4)	-- clear surface command
	if count == 0 then
		color = color + 1
		count = 10
	end
	count = count - 1
	if color == 20 then color = 16 end
end

local pattern = {
	{
		{ 0, 95},
		{60, 20},
		{ 1,  3}
	},
	{
		{38, 50, 57, 62, 38, 50, 95},
		{10, 10, 10, 10, 10, 10, 20},
		{ 1,  1,  1,  1,  1,  1,  3}
	},
	{
		{34, 46, 53, 58, 34, 46, 95},
		{10, 10, 10, 10, 10, 10, 20},
		{ 1,  1,  1,  1,  1,  1,  3}
	},
	{
		{31, 43, 50, 55, 31, 43, 95},
		{10, 10, 10, 10, 10, 10, 20},
		{ 1,  1,  1,  1,  1,  1,  3}
	},
	{
		{36, 48, 55, 60, 33, 45, 52, 57},
		{10, 10, 10, 10, 10, 10, 10, 10},
		{ 1,  1,  1,  1,  1,  1,  1,  1}
	},
	-- melody
	{
		{77, 74, 77, 70, 72, 70, 69, 65, 67, 70, 67, 69},
		{80, 60, 20, 60, 10, 10, 80,160, 20, 40, 20, 80},
		{ 2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2}
	}
}

local instrument = {
	{ 0x0f0f, 0x04, 0x15, 0x41 },
	{ 0x0000, 0x26, 0x14, 0x11 },
	{ 0x0000, 0x01, 0x12, 0x81 }
}

local song = {
	{2, 3, 4, 5, 2, 3, 4, 5, 2, 3, 4, 5},
	{1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2},
	{6, 1, 1, 1, 1}
}

function do_track(track_no)
	while true do
		for i=1, #song[track_no] do
			-- iterate through number of patterns in track
			for j=1, #pattern[song[track_no][i]][1] do
				-- iterate through number of notes in pattern
				local note = pattern[song[track_no][i]][1][j]
				local instr = instrument[pattern[song[track_no][i]][3][j]]
				-- start note if not equal to 0
				if note ~= 0 then
					poke16(0xc78 + (track_no * 8), midi[note])
					poke16(0xc7a + (track_no * 8), instr[1])
					poke(0xc7d + (track_no * 8), instr[2])
					poke(0xc7e + (track_no * 8), instr[3])
					poke(0xc7c + (track_no * 8), instr[4])
				end
				breakhere(pattern[song[track_no][i]][2][j] - 2)

				-- end note
				poke(0xc7d + (track_no * 8), 0x00)
				poke(0xc7e + (track_no * 8), 0x00)
				poke(0xc7c + (track_no * 8), instr[4] - 1)
				breakhere(2)
			end
		end
	end
end
