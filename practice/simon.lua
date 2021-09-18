-- title:  game title
-- author: game developer
-- desc:   short description
-- script: lua

local BUTTON_TIME=20
local BUTTON_CLICK_SFX=0
local BUTTON_BASE_NOTE=36
local BUTTON_NOTES={
	BUTTON_BASE_NOTE,
	BUTTON_BASE_NOTE+2,
	BUTTON_BASE_NOTE+4,
	BUTTON_BASE_NOTE+7
}

local LETTER_RECTS={
 {0,0,4,6},
 {4,0,2,4},
 {6,0,3,3},
 {9,0,2,2},
 {11,0,3,3}
}

function lerp(a,b,t)
	return a+(b-a)*t
end

function lerpVector(a,b,t)
	return {
		x=lerp(a.x,b.x,t),
		y=lerp(a.y,b.y,t)
	}
end

function intro_init()
 t=0
 ldes={
 	{x=60,y=68-24},
  {x=92,y=68-16},
  {x=108,y=68-12},
  {x=132,y=68-8},
  {x=148,y=68-12}
 }
 lpos={}
 for i,pos in ipairs(ldes) do
  table.insert(lpos,{x=pos.x,y=-30})
 end
end

function intro_update()
 t=t+0.1
 if t>5 then
  if btnp(4) then
   switchMode('game')
  end
 end
end

function intro_draw()
 local my=68
 local off=10
 cls()
 for i,lrect in ipairs(LETTER_RECTS) do
 	map(lrect[1],lrect[2],lrect[3],lrect[4],
  	lpos[i].x,lpos[i].y,0)
  local tempDes={
  	x=ldes[i].x+math.cos(t*0.5+i/2)*off,
   y=ldes[i].y+math.sin(t+i/2)*off
  }
 	lpos[i]=lerpVector(lpos[i],tempDes,0.05)
	end
 if t>5 then
 	print('X to start',98,120)
 end
end

local sequence={}
local sequenceStep=0
local t=0
local mode="input"
local down={0,0,0,0}
function game_init()
	sequence={}
	sequenceStep=-1
	t=0
end

function addStep()
	local step=math.random(1,4)
	table.insert(sequence, step)
	t=BUTTON_TIME*2
	sequenceStep=1
	mode="show"
	pressed(sequence[sequenceStep])
end

function game_update()
 if #sequence==0 then
 	addStep()
 end
 if mode=="show" then
  t=t-1
  if t<0 then
   if sequenceStep >= #sequence then
    mode="input"
    sequenceStep=1
   else
	   sequenceStep=sequenceStep+1
				pressed(sequence[sequenceStep])
				t=BUTTON_TIME*2
   end
  end
 elseif mode=="input" then
  if btnp(0) then pressed(1) end
  if btnp(1) then pressed(2) end
  if btnp(2) then pressed(3) end
  if btnp(3) then pressed(4) end
 elseif mode=="success" then
  if t==40 then
		 sfx(BUTTON_CLICK_SFX,BUTTON_NOTES[1]+12)
		elseif t==30 then
		 sfx(BUTTON_CLICK_SFX,BUTTON_NOTES[4]+12)
		end
  if t==40 or t==25 then
  	down[1]=BUTTON_TIME/2
  	down[2]=BUTTON_TIME/2
  	down[3]=BUTTON_TIME/2
  	down[4]=BUTTON_TIME/2
  end
  t=t-1
  if t<=0 then
  	addStep()
  end
 elseif mode=="fail" then
  if t==80 then
		 sfx(BUTTON_CLICK_SFX,BUTTON_NOTES[4]-5)
		elseif t==70 then
		 sfx(BUTTON_CLICK_SFX,BUTTON_NOTES[3]-5)
		elseif t==60 then
		 sfx(BUTTON_CLICK_SFX,BUTTON_NOTES[2]-5)
		elseif t==50 then
		 sfx(BUTTON_CLICK_SFX,BUTTON_NOTES[1]-5)
		end
  if t==80 then
  	down[1]=BUTTON_TIME
  elseif t==60 then
  	down[3]=BUTTON_TIME
  	down[4]=BUTTON_TIME
  elseif t==40 then
  	down[2]=BUTTON_TIME
  end
  t=t-1
  if t<=0 then
  	switchMode('intro')
  end
 end
end

function pressed(i)
 if down[i]>0 then return end
 down[i]=BUTTON_TIME
 sfx(BUTTON_CLICK_SFX,BUTTON_NOTES[i])
 if mode=="input" then
	 if sequence[sequenceStep]==i then
	  -- Success
	  if sequenceStep>=#sequence then
			 mode="success"
				t=BUTTON_TIME*3
	  else
		  sequenceStep=sequenceStep+1
			end
	 else
	  -- fail
	  mode="fail"
			t=BUTTON_TIME*5
	 end
	end
end

function ninePatch(index,x,y,w,h)
 if w<=1 or h<=1 then return end
 local r=x+w*8-8
 local b=y+h*8-8
 --Corners
 spr(index,x,y)
 spr(index+2,r,y)
 spr(index+32,x,b)
 spr(index+34,r,b)
 --Top & bottom
 if w>2 then
  for ix=1,w-2 do
   local xd=x+(ix*8)
   spr(index+1,xd,y)
   spr(index+33,xd,b)
  end
 end
 --Sides
 if h>2 then
  for iy=1,h-2 do
   local yd=y+(iy*8)
   spr(index+16,x,yd)
   spr(index+18,r,yd)
  end
 end
 --Center
 if w>2 and h>2 then
  local center=index+17
  for iy=1,h-2 do
   for ix=1,w-2 do
    spr(center,x+ix*8,y+iy*8)
   end
  end
 end
end

function game_draw()
	cls()
	
	rectb(88,2,64,64,9) -- TOP
	if down[1]>0 then
		rect(89,3,62,62,9)
		ninePatch(3,88,2,8,8)
		down[1]=down[1]-1
	else
		ninePatch(0,88,2,8,8)
	end
	rectb(88,68,64,64,2) -- BOTTOM
	if down[2]>0 then
		rect(89,69,62,62,2)
		ninePatch(51,88,68,8,8)
		down[2]=down[2]-1
	else
		ninePatch(48,88,68,8,8)
	end
	rectb(22,36,64,64,4) -- LEFT
	if down[3]>0 then
		rect(23,37,62,62,4)
		ninePatch(99,22,36,8,8)
		down[3]=down[3]-1
	else
		ninePatch(96,22,36,8,8)
	end
	rectb(154,36,64,64,6) -- RIGHT
	if down[4]>0 then
		rect(155,37,62,62,6)
		ninePatch(147,154,36,8,8)
		down[4]=down[4]-1
 else
		ninePatch(144,154,36,8,8)
	end
	
	--[[ debug
	local d="Len: "..(#sequence)..
		" Step: "..sequenceStep.."  "
	for i,step in ipairs(sequence) do
	 d=d..step.." "
	end
	print(d,2,122)
	--]]
end

local init=nil
local update=nil
local draw=nil

function switchMode(mode)
	if mode=="intro" then
	 intro_init()
		init=intro_init
		update=intro_update
		draw=intro_draw
	elseif mode=="game" then
		game_init()
		init=game_init
		update=game_update
		draw=game_draw
	end
end

switchMode("intro")

function TIC()
	update()
	draw()
end

-- <TILES>
-- 000:0000000000033333003333330333333303333222033322220333222203332222
-- 001:0000000033333333333333333333333322222222222222222222222222222222
-- 002:0000000033333000333313003331113022221130222211302222113022221130
-- 003:0000000000033333003000000300000003000111030011110300111103001111
-- 004:0000000033333333000000000000000011111111111111111111111111111111
-- 005:0000000033333000000003000000003011110230111122301111223011112230
-- 007:eeeeeeeeffffffffddddddddeeddddeedddeedddddddddddeeeeeeeeffffffff
-- 008:feddedfefedddddffededdddfededddefeddeeddfedddddd0feeeeee00ffffff
-- 016:0333222203332222033322220333222203332222033322220333222203332222
-- 017:2222222222222222222222222222222222222222222222222222222222222222
-- 018:2222113022221130222211302222113022221130222211302222113022221130
-- 019:0300111103001111030011110300111103001111030011110300111103001111
-- 020:1111111111111111111111111111111111111111111111111111111111111111
-- 021:1111223011112230111122301111223011112230111122301111223011112230
-- 032:0333222203332222033322220331222203111111003111110003333300000000
-- 033:2222222222222222222222222222222211111111111111113333333300000000
-- 034:2222113022221130222211302221113011111130111113003333300000000000
-- 035:0300111103001111030011110300111103000222003022220003333300000000
-- 036:1111111111111111111111111111111122222222222222223333333300000000
-- 037:1111223011112230111122301112223022222230222223003333300000000000
-- 038:0000000000000000000000000000000000000000000000010000001200000012
-- 039:0000001100001122001122220122222212222222222222222222222222222221
-- 040:1111111022222221222222222222222222222222222222221111122200000111
-- 041:0000000010000000211000002221000022210000222100002210000011000000
-- 042:0000007700000766000076660000766600000766000000770000000000000000
-- 043:0000000070000000670000006700000067000000700000000000000000000000
-- 044:0008888800899999089999990899999908999999089999998999999989999999
-- 045:0000008888008899998899999999999999999999999999999999999999999999
-- 046:8880000099988000999998009999998099999980999999809999998099999980
-- 048:00000000000aaaaa00aaaaaa0aaaaaaa0aaaa9990aaa99990aaa99990aaa9999
-- 049:00000000aaaaaaaaaaaaaaaaaaaaaaaa99999999999999999999999999999999
-- 050:00000000aaaaa000aaaa8a00aaa888a0999988a0999988a0999988a0999988a0
-- 051:00000000000aaaaa00a000000a0000000a0008880a0088880a0088880a008888
-- 052:00000000aaaaaaaa000000000000000088888888888888888888888888888888
-- 053:00000000aaaaa00000000a00000000a0888809a0888899a0888899a0888899a0
-- 054:0000001200000122000001220000012200000122000001220000001200000012
-- 055:2222221022222100222210002222100022221000222210002222210022222210
-- 058:0000000000000077000077660007666600076666000766660007666600076666
-- 059:0000000070000000670000006670000066700000667000006670000066700000
-- 060:8999999989999999899999998999999989999999899999988999999889999998
-- 061:9999999999999999999999999999998889999800089980000088000000000008
-- 062:9999998099999980999999809999998089999980899999808999998099999980
-- 064:0aaa99990aaa99990aaa99990aaa99990aaa99990aaa99990aaa99990aaa9999
-- 065:9999999999999999999999999999999999999999999999999999999999999999
-- 066:999988a0999988a0999988a0999988a0999988a0999988a0999988a0999988a0
-- 067:0a0088880a0088880a0088880a0088880a0088880a0088880a0088880a008888
-- 068:8888888888888888888888888888888888888888888888888888888888888888
-- 069:888899a0888899a0888899a0888899a0888899a0888899a0888899a0888899a0
-- 070:0000001200000012000000010000000000000000000000000000000000000000
-- 071:2222222122222222222222221222222201222222001222220001122200000122
-- 072:0000000010000000210000002210000022210000222210002222210022222210
-- 074:0007666600766666007666660076666600766666007666660766666607666666
-- 075:6670000066700000667000006700000067000000670000006700000067000000
-- 076:8999999889999998899999988999999808999998008888800000000000000000
-- 077:0000000800000008000000080000000800000000000000000000000000000000
-- 078:9999998099999980999999809999998089999800088880000000000000000000
-- 080:0aaa99990aaa99990aaa99990aa899990a88888800a88888000aaaaa00000000
-- 081:999999999999999999999999999999998888888888888888aaaaaaaa00000000
-- 082:999988a0999988a0999988a0999888a0888888a088888a00aaaaa00000000000
-- 083:0a0088880a0088880a0088880a0088880a00099900a09999000aaaaa00000000
-- 084:888888888888888888888888888888889999999999999999aaaaaaaa00000000
-- 085:888899a0888899a0888899a0888999a0999999a099999a00aaaaa00000000000
-- 086:0000000000000000000000000000000000000000000111100012222101222222
-- 087:0000001200000001000000000000000000000000000000000000000010000000
-- 088:2222222122222221122222220122222201222222001222220012222200122222
-- 089:0000000000000000100000001000000021000000210000002100000021000000
-- 090:0766666676666666766666667666666776666670076677000077000000000000
-- 091:7000000070000000700000000000000000000000000000000000000000000000
-- 096:0000000000055555005555550555555505555666055566660555666605556666
-- 097:0000000055555555555555555555555566666666666666666666666666666666
-- 098:0000000055555000555575005557775066667750666677506666775066667750
-- 099:0000000000055555005fffff05ffffff05fff77705ff777705ff777705ff7777
-- 100:0000000055555555ffffffffffffffff77777777777777777777777777777777
-- 101:0000000055555000fffff500ffffff507777f650777766507777665077776650
-- 102:1222222212222222122222221222222212222222012222220122222200122222
-- 103:1000000021000000221000012221111222222222222222222222222222222222
-- 104:0012222211222222222222222222222222222221222221102211100011000000
-- 105:2100000021000000100000001000000000000000000000000000000000000000
-- 106:00000eee00eee4440e444444e4444444e4444444e444444ee44444e0e44444e0
-- 107:ee00000044e00000444e00004444e0004444e000e444e0000e44e0000e444e00
-- 108:0000000800000087000008770000877700087777008777770877777708777777
-- 109:8880000077788800777777807777777877777777777777777777777777777777
-- 110:0000000000000000000000000000000080000000780000007800000078000000
-- 112:0555666605556666055566660555666605556666055566660555666605556666
-- 113:6666666666666666666666666666666666666666666666666666666666666666
-- 114:6666775066667750666677506666775066667750666677506666775066667750
-- 115:05ff777705ff777705ff777705ff777705ff777705ff777705ff777705ff7777
-- 116:7777777777777777777777777777777777777777777777777777777777777777
-- 117:7777665077776650777766507777665077776650777766507777665077776650
-- 118:0001222200001112000000010000000000000000000000000000000000000000
-- 119:2222221122211100111000000000000000000000000000000000000000000000
-- 122:e4444e00e4444e000e4444ee00e44444000e4444000e44440000e44400000ee4
-- 123:0e444e00e4444e0044444e0044444e004444e0004444e000444e000044e00000
-- 124:8777777787777777877777778777777787777778877777808777778087777780
-- 125:7777777777777777788777778008777700008777000087770000877700000877
-- 126:7780000077800000778000007780000077800000778000007778000077780000
-- 128:0555666605556666055566660557666605777777005777770005555500000000
-- 129:6666666666666666666666666666666677777777777777775555555500000000
-- 130:6666775066667750666677506667775077777750777775005555500000000000
-- 131:05ff777705ff777705ff777705ff777705fff666005f66660005555500000000
-- 132:7777777777777777777777777777777766666666666666665555555500000000
-- 133:7777665077776650777766507776665066666650666665005555500000000000
-- 138:0000000e00000000000000000000000000000000000000000000000000000000
-- 139:ee00000000000000000000000000000000000000000000000000000000000000
-- 140:8777778087777780877777800877780000888000000000000000000000000000
-- 141:0000087700000877000008770000087700000087000000870000000800000000
-- 142:7778000077780000777780007777800077778000777800008880000000000000
-- 144:00000000000ccccc00cccccc0ccccccc0cccc4440ccc44440ccc44440ccc4444
-- 145:00000000cccccccccccccccccccccccc44444444444444444444444444444444
-- 146:00000000ccccc000cccc3c00ccc333c0444433c0444433c0444433c0444433c0
-- 147:00000000000ccccc00c222220c2222220c2223330c2233330c2233330c223333
-- 148:00000000cccccccc222222222222222233333333333333333333333333333333
-- 149:00000000ccccc00022222c00222222c0333324c0333344c0333344c0333344c0
-- 160:0ccc44440ccc44440ccc44440ccc44440ccc44440ccc44440ccc44440ccc4444
-- 161:4444444444444444444444444444444444444444444444444444444444444444
-- 162:444433c0444433c0444433c0444433c0444433c0444433c0444433c0444433c0
-- 163:0c2233330c2233330c2233330c2233330c2233330c2233330c2233330c223333
-- 164:3333333333333333333333333333333333333333333333333333333333333333
-- 165:333344c0333344c0333344c0333344c0333344c0333344c0333344c0333344c0
-- 176:0ccc44440ccc44440ccc44440cc344440c33333300c33333000ccccc00000000
-- 177:444444444444444444444444444444443333333333333333cccccccc00000000
-- 178:444433c0444433c0444433c0444333c0333333c033333c00ccccc00000000000
-- 179:0c2233330c2233330c2233330c2233330c22244400c24444000ccccc00000000
-- 180:333333333333333333333333333333334444444444444444cccccccc00000000
-- 181:333344c0333344c0333344c0333444c0444444c044444c00ccccc00000000000
-- </TILES>

-- <MAP>
-- 000:62728292a2b2c2d2e2a6b6c6d6e600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:63738394a3b3c3d3e3a7b7c7d7e700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:64748494a4b4c4d4e40000c8d8e800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:65758595a5b5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:667686960000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:677787970000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 004:6789aaaaabcdeffffedcccccccc11111
-- </WAVES>

-- <SFX>
-- 000:14001400240024003410442064307440a450d470f490f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400300000000000
-- </SFX>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

