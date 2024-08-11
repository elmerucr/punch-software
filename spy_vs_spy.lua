-- Version 20240722
-- Using coroutines, pushing them into a table and iterating through
-- them. Both 'startthread' and 'breakhere' inspired by Ron Gilbert and
-- Thimbleweed Park Blogs on scripting.

local color = 16
local count = 0

local tasks = {}

function startthread(f, t)
	table.insert(tasks, {coroutine.create(f), t})
end

function init()
	-- Make blitter cause interrupts at the start of each frame, just
	-- after screen refresh. The kernel will attempt to call the Lua
	-- function frame(). The system will drop to debug if it has not
	-- been defined.
	poke(0x801, 1)

	-- timer stuff, 3008bpm
	-- this will call the lua function timer0()
	poke16(0xa10, 3008)
	poke(0xa01, 1)

	startthread(do_track, 1)
	startthread(do_track, 2)
	startthread(do_track, 3)

	co_lines = coroutine.create(draw_lines)
end

function timer0()
	for key, value in pairs(tasks) do
		coroutine.resume(value[1], value[2])
	end
end

function draw_lines()
	local x0 = 0
	local y0 = 0
	local dx = 1
	local dy = 1

	while true do
		solid_rectangle(150, 90, 155, 110, 0xc3, 15)
		line(x0, y0, 319 - x0, 179, 51, 15)
		line(x0, 179, 319 - x0, 0, 51, 15)
		x0 = x0 + dx
		if x0 == 319 then dx = -dx end
		if x0 == 0 then dx = -dx end
		rectangle(10, 10, 40, 40, 0xc3, 15)
		breakhere(1)
	end
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

	coroutine.resume(co_lines)
end

local instrument = {
	{ 0x0f0f, 0x04, 0x15, 0x41 },	-- bass
	{ 0x0000, 0x26, 0x14, 0x11 },	-- flute
	{ 0x0000, 0x01, 0x12, 0x81 }	-- snare
}

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
