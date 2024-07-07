-- Newer version 20240628
-- Uses coroutines

local color = 10

function init()
	-- make blitter cause interrupts at start of frame
	-- this will call the lua function frame()
	pokeb(0x801, 1)

	-- timer stuff
	pokew(0xa10, 3008)
	pokeb(0xa01, 1)

	-- set pulse width
	pokew(0xc02, 0x0f0f)
	pokew(0xc0a, 0x0f0f)

	co = coroutine.create(do_sound)
end

function timer0()
	coroutine.resume(co)
end

function frame()
	pokeb(0xe05, color)	-- target color
	pokeb(0xe03, 0xf)	-- target surface = 0xf
	pokeb(0xe01, 4)	-- clear surface command
	color = color + 1
	if color == 20 then color = 10 end
end

-- Spy vs Spy I track 1
-- 0x000 means note not played
local track1 = {
	midi[38], midi[50], midi[57], midi[62], midi[38], midi[50], 0, 0,
	midi[34], midi[46], midi[53], midi[58], midi[34], midi[46], 0, 0,
	midi[31], midi[43], midi[50], midi[55], midi[31], midi[43], 0, 0,
	midi[36], midi[48], midi[55], midi[60], midi[33], midi[45], midi[52], midi[57],

	midi[38], midi[50], midi[57], midi[62], midi[38], midi[50], 0, 0,
	midi[34], midi[46], midi[53], midi[58], midi[34], midi[46], 0, 0,
	midi[31], midi[43], midi[50], midi[55], midi[31], midi[43], 0, 0,
	midi[36], midi[48], midi[55], midi[60], midi[33], midi[45], midi[52], midi[57],

	midi[38], midi[50], midi[57], midi[62], midi[38], midi[50], 0, 0,
	midi[34], midi[46], midi[53], midi[58], midi[34], midi[46], 0, 0,
	midi[31], midi[43], midi[50], midi[55], midi[31], midi[43], 0, 0,
	midi[36], midi[48], midi[55], midi[60], midi[33], midi[45], midi[52], midi[57]
}

-- Spy vs Spy I track 2
-- 0x000 means note not played
local track2 = {
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,

	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,

	midi[38], midi[50], midi[57], midi[62], midi[38], midi[50], 0, 0,
	midi[38], midi[50], midi[57], midi[62], midi[38], midi[50], 0, 0,
	midi[38], midi[50], midi[57], midi[62], midi[38], midi[50], 0, 0,
	midi[38], midi[50], midi[57], midi[62], midi[38], midi[50], 0, 0
}

function do_sound()
	while true do
		for i=1, #track1 do
			-- channel 1
			if track1[i] ~= 0 then
				pokew(0xc80, track1[i])
				pokeb(0xc85, 0x04)
				pokeb(0xc86, 0x15)
				pokeb(0xc84, 0x41)
			end
			-- channel 2
			if track2[i] ~= 0 then
				pokew(0xc88, track2[i])
				pokeb(0xc8d, 0x04)
				pokeb(0xc8e, 0x15)
				pokeb(0xc8c, 0x41)
			end

			for j=1, 10 do
				if j==9 then
					pokeb(0xc85, 0x00)
					pokeb(0xc86, 0x00)
					pokeb(0xc84, 0x00)

					pokeb(0xc8d, 0x00)
					pokeb(0xc8e, 0x00)
					pokeb(0xc8c, 0x00)
				end
				coroutine.yield()
			end
		end
	end
end
