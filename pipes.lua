-- title:  Pipes!
-- author: Cobrasoft
-- desc:   Just a clone of a pipes type game
-- script: lua

local GAME_SPACE={w=240-16,h=136,x=16,y=0}
local PREVIEW={x=0,y=0}

local PIPES={}
local PIPE_NORMAL=1
local PIPE_START=2
local PIPE_JUNCTION=3
local EMPTY=4
function addPipe(sprite,dirs,type)
 if type==PIPE_START then
  dirs={dirs}
 end
 for i,dir in ipairs(dirs) do
  if dir.x==nil then dir.x=0 end
  if dir.y==nil then dir.y=0 end
 end
 table.insert(PIPES,{s=sprite,d=dirs,t=type,i=#PIPES+1})
end


function contains(array,item)
 for i=1,#array do
  if array[i]==item then
  	return true
  end
 end
 return false
end
function getPipes(types)
 local pipes={}
 for i,pipe in ipairs(PIPES) do
  if contains(types,pipe.t) then
  	table.insert(pipes,pipe)
  end
 end
 return pipes
end

addPipe(34,{},EMPTY)
addPipe(36,{},EMPTY)
addPipe(100,{x=-1},PIPE_START)
addPipe(102,{y=-1},PIPE_START)
addPipe(104,{y=1},PIPE_START)
addPipe(106,{x=1},PIPE_START)
addPipe(38,{{x=1},{x=-1}},PIPE_NORMAL)
addPipe(40,{{y=1},{y=-1}},PIPE_NORMAL)
addPipe(42,{{x=1},{x=-1},{y=1},{y=-1}},PIPE_JUNCTION)
addPipe(44,{{x=-1},{y=-1},{x=1},{y=1}},PIPE_JUNCTION)
addPipe(46,{{x=-1},{y=1},{x=1},{y=-1}},PIPE_JUNCTION)
addPipe(68,{{x=-1},{y=-1}},PIPE_NORMAL)
addPipe(70,{{x=-1},{y=1}},PIPE_NORMAL)
addPipe(72,{{x=1},{y=-1}},PIPE_NORMAL)
addPipe(74,{{x=1},{y=1}},PIPE_NORMAL)

local PIPE_STARTS=getPipes({PIPE_START})
local PIPE_NORMALS=getPipes({PIPE_NORMAL,PIPE_JUNCTION})

local state={
	t=0,
	cell=nil
}

local grid={}

local pipes={}
local pipes_next={}

local select={x=1,y=1}

function makeGrid(w,h)
 grid={w=w,h=h}
	for ih=1,h do
	 local row={}
	 for iw=1,w do
   table.insert(row,{
				type=1,x=iw,y=ih,
				filled=0,next=nil,
   fillA=0,fillB=0})
		end
		table.insert(grid,row)
	end
	return grid
end

function getGrid(x,y)
 return grid[y][x]
end

function takePipe()
 local pipe=table.remove(pipes_next)
 updatePipeQueue()
 return pipe
end

function updatePipeQueue()
 if #pipes_next<4 then
 	for i=1,4-#pipes_next do
   table.insert(pipes_next,1,PIPE_NORMALS[math.random(1,#PIPE_NORMALS)].i)
  end
 end
end

function pipeIter(func)
 for y,row in ipairs(grid) do
  for x,cell in ipairs(row) do
			func(x-1,y-1,cell)
		end
	end
end

function partialFill(x,y,cell)
 local p=PIPES[cell.type]
 if cell.filled>=1 then
  if p.t==PIPE_JUNCTION then
   if p.s==42 then
    local fillA,fillB=15,15
    if cell.fillA==1 then fillA=5 end
    if cell.fillB==1 then fillB=5 end
    rect(x,y+4,16,8,fillA)
    rect(x,y,16,4,fillB)
    rect(x,y+12,16,4,fillB)
   elseif p.s==44 then
    local fillA,fillB=15,15
    if cell.fillA==1 then fillA=5 end
    if cell.fillB==1 then fillB=5 end
    tri(x+16,y+16,x+16,y,x,y+16,fillA)
    tri(x,y,x+15,y,x,y+15,fillB)
   elseif p.s==46 then
    local fillA,fillB=15,15
    if cell.fillA==1 then fillA=5 end
    if cell.fillB==1 then fillB=5 end
    tri(x,y,x+15,y,x+15,y+15,fillA)
    tri(x,y,x,y+16,x+16,y+16,fillB)
   end
  else
   rect(x,y,16,16,5)
  end
  return
 end
 local fill,dir,type=16*cell.filled,state.dir,cell.type
 if type==13 or (type==3 and dir.x==1) then
  rect(x,y,fill,16,5)
 elseif type==10 or (type==3 and dir.x==-1) then
  rect(x+16-fill,y,fill,16,5)
 elseif type==11 or
  (type==4 and dir.y==1) or
  (type==5 and dir.y==1) then
  rect(x,y,16,fill,5)
 elseif type==12 or (type==4 and dir.y==-1) then
 	rect(x,y+16-fill,16,fill,5)
 elseif type==6 and dir.x==1 then
  tri(x,y,x,y+16,x+math.min(fill*2,16),y+16,5)
  if cell.filled>=0.5 then
	  tri(x,y,x+16,y+16,x+16,y+16-(cell.filled-0.5)*32,5)
  end
 elseif type==6 and dir.y==1 then
  tri(x,y,x+16,y,x+16,y+math.min(fill*2,16),5)
  if cell.filled>=0.5 then
  	tri(x,y,x+16,y+16,x+16-(cell.filled-0.5)*32,y+16,5)
  end
 elseif type==7 and dir.x==1 then
  tri(x,y,x,y+16,x+math.min(fill*2,16),y,5)
  if cell.filled>=0.5 then
	  tri(x,y+16,x+16,y,x+16,y+(cell.filled-0.5)*32,5)
  end
 elseif type==7 and dir.y==-1 then
		tri(x,y+16,x+16,y+16,x+16,y+16-math.min(fill*2,16),5)
		if cell.filled>=0.5 then
		 tri(x,y+16,x+16-(cell.filled-0.5)*32,y,x+16,y,5)
		end
 elseif type==8 and dir.x==-1 then
 	tri(x+16,y,x+16,y+16,x+16-math.min(fill*2,16),y+16,5)
  if cell.filled>=0.5 then
   tri(x+16,y,x,y+16,x,y+16-(cell.filled-0.5)*32,5)
  end
 elseif type==8 and dir.y==1 then
  tri(x,y,x+16,y,x,y+math.min(fill*2,16),5)
  if cell.filled>=0.5 then
   tri(x,y+16,x+16,y,x+(cell.filled-0.5)*32,y+16,5)
  end
 elseif type==9 and dir.x==-1 then
  tri(x+16,y,x+16,y+16,x+16-math.min(fill*2,16),y,5)
  if cell.filled>=0.5 then
  	tri(x,y,x+16,y+16,x,y+(cell.filled-0.5)*32,5)
		end
 elseif type==9 and dir.y==-1 then
  tri(x,y+16,x+16,y+16,x,y+16-math.min(fill*2,16),5)
  if cell.filled>=0.5 then
   tri(x,y,x+16,y+16,x+(cell.filled-0.5)*32,y,5)
		end
 end
end

function matchDir(d1,d2)
  return (d1.x~=0 and d1.x==d2.x*-1) or (d1.y~=0 and d1.y==d2.y*-1)
end
function canReceive(pipe,dir)
 local p=PIPES[pipe.type]
 if p.t==PIPE_NORMAL then
  if matchDir(dir,p.d[1]) or matchDir(dir,p.d[2]) then
   return true
  end
 elseif p.t==PIPE_JUNCTION then
  if matchDir(dir,p.d[1]) or matchDir(dir,p.d[2]) or matchDir(dir,p.d[3]) or matchDir(dir,p.d[4]) then
   return true
  end
 end
 return false
end
function nextPipe()
 local c,dir,p=state.cell,state.dir,PIPES[state.cell.type]
 --Starts
 if p.t==PIPE_START then
  dir=p.d[1]
 elseif p.t==PIPE_NORMAL then
  local d1,d2=p.d[1],p.d[2]
  if matchDir(dir, d1) then dir=d2 else dir=d1 end
 elseif p.t==PIPE_JUNCTION then
  if matchDir(dir,p.d[1]) then
   dir=p.d[2]
  elseif matchDir(dir,p.d[2]) then
   dir=p.d[1]
  elseif matchDir(dir,p.d[3]) then
   dir=p.d[4]
  else
   dir=p.d[3]
  end
 end
 local nextCell=getGrid(c.x+dir.x,c.y+dir.y)
 if not canReceive(nextCell,dir) then
  state.cell=nil
  return
 end
 if nextCell.type~=1 then
  p=PIPES[state.cell.type]
  if p.t==PIPE_JUNCTION then
   if matchDir(dir,p.d[1]) or matchDir(dir,p.d[2]) then
    state.cell.fillA=1
   else
    state.cell.fillB=1
   end
  end
 end
 state.cell=nextCell
 state.dir=dir
end

makeGrid(7,5)
updatePipeQueue()


--grid[3][2].type=PIPE_STARTS[math.random(1,#PIPE_STARTS)].i
grid[3][2].type=6
state.cell=grid[3][2]
state.dir={x=1,y=0}

function init()
	state.t=0
end

function TIC()
 cls()

 if state.t > -1 then
  state.t=state.t+1
 end

 if btnp(0) then select.y=math.max(1,select.y-1) end
 if btnp(1) then select.y=math.min(grid.h,select.y+1) end
 if btnp(2) then select.x=math.max(1,select.x-1) end
 if btnp(3) then select.x=math.min(grid.w,select.x+1) end

 if btnp(4) then
 	local selected=grid[select.y][select.x]
  if selected.type==1 then
			selected.type=takePipe()
  end
 end

 if btnp(5) then
  if state.cell==nil or state.cell.type==1 then
   reset() 
   return
  end
  if state.cell.type==1 then reset() end
  if state.cell.filled==nil then
   state.cell.filled=0
  end
  --state.cell.filled=state.cell.filled+0.2
  state.cell.filled=1
  if state.cell.filled>=1 then
   state.cell.filled=1
   nextPipe()
  end
 end

 --Discard pipes for debug
 if btnp(6) then
  takePipe()
 end

 --Preview
 for y,pipe in ipairs(pipes_next) do
  spr(PIPES[pipe].s,
  	PREVIEW.x,PREVIEW.y+(y-1)*16,-1,1,0,0,2,2)
 end
 local startX=GAME_SPACE.x+GAME_SPACE.w/2-(grid.w*8)
 local startY=GAME_SPACE.y+GAME_SPACE.h/2-(grid.h*8)
 --Draw grid
 pipeIter(function(x,y,cell)
 	local tran=-1
  local dx=startX+x*16
  local dy=startY+y*16
  if cell.filled>0 then
   partialFill(dx,dy,cell)
   tran=15
  end
  spr(PIPES[cell.type].s,dx,dy,tran,1,0,0,2,2)
 end)

 --Draw selector box
 local selX,selY=startX+select.x*16,startY+select.y*16
 rectb(selX-16,selY-16,16,16,9)
	line(selX-1,selY-16,selX-1,selY-1,10)
	line(selX-16,selY-1,selX-1,selY-1,10)
end


-- <TILES>
-- 034:777777777ddddddd7ddddddd7ddddddd7ddddddd7ddddddd7ddddddd7ddddddd
-- 035:77777777dddddddcdddddddcdddddddcdddddddcdddddddcdddddddcdddddddc
-- 036:cccccccccdddddddcdddddddcdddddddcdddddddcdddddddcdddddddcddddddd
-- 037:ccccccccddddddd7ddddddd7ddddddd7ddddddd7ddddddd7ddddddd7ddddddd7
-- 038:cccccccccdddddddcdddddddcddddddd00000000ffffffffffffffffffffffff
-- 039:ccccccccddddddd7ddddddd7ddddddd700000000ffffffffffffffffffffffff
-- 040:cccc0fffcddd0fffcddd0fffcddd0fffcddd0fffcddd0fffcddd0fffcddd0fff
-- 041:fffeccccfffeddd7fffeddd7fffeddd7fffeddd7fffeddd7fffeddd7fffeddd7
-- 042:cccc0fffcddd0fffcddd0fffcddd0fff00000000ffffffffffffffffffffffff
-- 043:fffeccccfffeddd7fffeddd7fffeddd700000000ffffffffffffffffffffffff
-- 044:cccc0fffcddd0fffcdd0ffffcd0fffff00fffffffffffffffffffffffffffffe
-- 045:fffeccccfffeddd7fffeddd7ffedddd7ffed0000fe00ffffe0ffffff0fffffff
-- 046:cccc0fffcddd0fffcddd0fffcdddd0ff0000deffffff00efffffff0efffffff0
-- 047:fffeccccfffeddd7ffffedd7fffffed7ffffff00ffffffffffffffffefffffff
-- 050:7ddddddd7ddddddd7ddddddd7ddddddd7ddddddd7ddddddd7ddddddd7ccccccc
-- 051:dddddddcdddddddcdddddddcdddddddcdddddddcdddddddcdddddddccccccccc
-- 052:cdddddddcdddddddcdddddddcdddddddcdddddddcdddddddcdddddddc7777777
-- 053:ddddddd7ddddddd7ddddddd7ddddddd7ddddddd7ddddddd7ddddddd777777777
-- 054:ffffffffffffffffffffffffeeeeeeeecdddddddcdddddddcdddddddc7777777
-- 055:ffffffffffffffffffffffffeeeeeeeeddddddd7ddddddd7ddddddd777777777
-- 056:cddd0fffcddd0fffcddd0fffcddd0fffcddd0fffcddd0fffcddd0fffc7770fff
-- 057:fffeddd7fffeddd7fffeddd7fffeddd7fffeddd7fffeddd7fffeddd7fffe7777
-- 058:ffffffffffffffffffffffffeeeeeeeecddd0fffcddd0fffcddd0fffc7770fff
-- 059:ffffffffffffffffffffffffeeeeeeeefffeddd7fffeddd7fffeddd7fffe7777
-- 060:ffffffe0fffffe0ffffee0ffeeedd0ffcddd0fffcddd0fffcddd0fffc7770fff
-- 061:fffffffffffffffffffffffffffffeeeffffedd7fffeddd7fffeddd7fffe7777
-- 062:ffffffffffffffffffffffffeeefffffcddeffffcddd0fffcddd0fffc7770fff
-- 063:0efffffff0efffffff0eefffffeddeeefffeddd7fffeddd7fffeddd7fffe7777
-- 068:cccc0fffcddd0fffcddd0fffcddd0fff0000ffffffffffffffffffffffffffff
-- 069:fffeccccfffeddd7fffeddd7fffeddd7fffeddd7fffeddd7fffeddd7fffeddd7
-- 070:cccccccccdddddddcdddddddcddddddd00000000ffffffffffffffffffffffff
-- 071:ccccccccddddddd7ddddddd7ddddddd700ddddd7ff0dddd7fffeddd7fffeddd7
-- 072:cccc0fffcddd0fffcddd0fffcddd0fffcddd0fffcddd0fffcddd0fffcddd0fff
-- 073:fffeccccfffeddd7fffeddd7fffeddd7ffff0000ffffffffffffffffffffffff
-- 074:cccccccccdddddddcdddddddcdddddddcddddd00cdddd0ffcddd0fffcddd0fff
-- 075:ccccccccddddddd7ddddddd7ddddddd700000000ffffffffffffffffffffffff
-- 084:ffffffffffffffffffffffffeeeeeeeecdddddddcdddddddcdddddddc7777777
-- 085:fffeddd7fffeddd7ffedddd7eeddddd7ddddddd7ddddddd7ddddddd777777777
-- 086:ffffffffffffffffffffffffeeeeffffcddd0fffcddd0fffcddd0fffc7770fff
-- 087:fffeddd7fffeddd7fffeddd7fffeddd7fffeddd7fffeddd7fffeddd7fffe7777
-- 088:cddd0fffcddd0fffcddddeffcdddddeecdddddddcdddddddcdddddddc7777777
-- 089:ffffffffffffffffffffffffeeeeeeeeddddddd7ddddddd7ddddddd777777777
-- 090:cddd0fffcddd0fffcddd0fffcddd0fffcddd0fffcddd0fffcddd0fffc7770fff
-- 091:ffffffffffffffffffffffffffffeeeefffeddd7fffeddd7fffeddd7fffe7777
-- 100:cccccccccdddddddcdddd000cddd0fff0000ffffffffff77ffffff7fffffff77
-- 101:ccccccccddddddd70000ddd7ffffedd7fffffed777fffed7fffffed777fffed7
-- 102:cccccccccdddddddcddd0000cdd0ffffcd0fffffcd0fff77cd0fff7fcd0fff77
-- 103:ccccccccddddddd70000ddd7ffffedd7fffffed777fffed7fffffed777fffed7
-- 104:cccc0fffcddd0fffcddd0fffcddd0fffcddd0fffcdd0ffffcd0fff77cd0fff7f
-- 105:fffeccccfffeddd7fffeddd7fffeddd7fffeddd7ffffedd777fffed7fffffed7
-- 106:cccccccccdddddddcddd0000cdd0ffffcd0fffffcd0ff777cd0ff7ffcd0ff777
-- 107:ccccccccddddddd7000dddd7fff0ddd7ffff00007fffffffffffffff7fffffff
-- 116:ffffffffffffff77ffffffffeeeeffffcdddefffcddddeeecdddddddc7777777
-- 117:f7fffed777fffed7fffffed7fffffed7ffffedd7eeeeddd7ddddddd777777777
-- 118:cd0fffffcd0fff77cdd0ffffcddd0fffcddd0fffcddd0fffcddd0fffc7770fff
-- 119:f7fffed777fffed7ffffedd7fffeddd7fffeddd7fffeddd7fffeddd7fffe7777
-- 120:cd0fff77cd0fffffcd0fff77cd0fffffcdd0ffffcdddeeeecdddddddc7777777
-- 121:77fffed7f7fffed777fffed7fffffed7ffffedd7eeeeddd7ddddddd777777777
-- 122:cd0fffffcd0ff777cd0fffffcd0fffffcddeffffcdddeeeecdddddddc7777777
-- 123:7fffffff7fffffffffffffffffffeeeefffeddd7eeedddd7ddddddd777777777
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

