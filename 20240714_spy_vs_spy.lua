-- Newer version 20240714
-- Uses coroutines

local color = 10

function breakhere(no)
	for i=1, no do
		coroutine.yield()
	end
end

function init()
	-- make blitter cause interrupts at start of frame
	-- this will call the lua function frame()
	poke(0x801, 1)

	-- timer stuff
	poke16(0xa10, 3008)
	poke(0xa01, 1)

	-- set pulse width
	poke16(0xc82, 0x0f0f)
	poke16(0xc8a, 0x0f0f)
	poke16(0xc92, 0x0f0f)

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
	color = color + 1
	if color == 20 then color = 10 end
end

local pattern = {
	{
		{ 0,  0,  0,  0,  0,  0,  0,  0},
		{10, 10, 10, 10, 10, 10, 10, 10}
	},
	{
		{38, 50, 57, 62, 38, 50,  0,  0},
		{10, 10, 10, 10, 10, 10, 10, 10}
	},
	{
		{34, 46, 53, 58, 34, 46,  0,  0},
		{10, 10, 10, 10, 10, 10, 10, 10}
	},
	{
		{31, 43, 50, 55, 31, 43,  0,  0},
		{10, 10, 10, 10, 10, 10, 10, 10}
	},
	{
		{36, 48, 55, 60, 33, 45, 52, 57},
		{10, 10, 10, 10, 10, 10, 10, 10}
	},
	-- (6) melody
	{
		{77, 74, 77, 70, 72, 70, 69, 65, 67, 70, 67, 69},
		{80, 60, 20, 60, 10, 10, 80,160, 20, 40, 20, 80}
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
				local note = pattern[song[track_no][i]][1][j]
				-- start note if not 0
				if note ~= 0 then
					poke16(0xc78 + (track_no * 8), midi[note])
					poke(0xc7d + (track_no * 8), 0x04)
					poke(0xc7e + (track_no * 8), 0x15)
					poke(0xc7c + (track_no * 8), 0x41)
				end
				breakhere(pattern[song[track_no][i]][2][j] - 2)
				--breakhere(10 - 2)

				-- end note
				poke(0xc7d + (track_no * 8), 0x00)
				poke(0xc7e + (track_no * 8), 0x00)
				poke(0xc7c + (track_no * 8), 0x40)
				breakhere(2)
			end
		end
	end
end
