-- title:  game title
-- author: game developer
-- desc:   short description
-- script: lua

pos={x=0,y=0,z=0}
dir={x=0,y=0,z=0}
w=100
h=136
xoff,yoff=120-(w-h)/2,136/2-(w+h)/4

function translate(x,y)
 return xoff+x-y,yoff+(x+y)/2
end

function tile(x,y,w,h,color)
 local x0,y0=translate(x,y)
	local x1,y1=translate(x+w,y)
	local x2,y2=translate(x,y+h)
	local x3,y3=translate(x+w,y+h)
	tri(x0,y0,x1,y1,x2,y2,color)
	tri(x1,y1,x2,y2,x3,y3,color)
end

function block(x,y,z,w,h,d,c1,c2,c3)
 local x0,y0=translate(x,y)
 local x1,y1=translate(x+w,y)
 local x2,y2=translate(x,y+h)
 local x3,y3=translate(x+w,y+h)
 if z>0 then
 	y0=y0-z
  y1=y1-z
  y2=y2-z
  y3=y3-z
 end
 tri(x0,y0-d,x1,y1-d,x2,y2-d,c1)
 tri(x1,y1-d,x2,y2-d,x3-d,y3-d,c1)
 if d>0 then
  --Front
  tri(x2,y2-d,x3,y3-d,x2,y2,c2)
  tri(x3,y3-d,x2,y2,x3,y3,c2)
  --Side
  tri(x3,y3,x3,y3-d,x1,y1-d,c3)
  tri(x3,y3,x1,y1-d,x1,y1,c3)
 end
end

function ispr(i,x,y,z,w,h)
 local dx,dy=translate(x,y)
 spr(i,dx-w*4,dy-z-h*6,0,1,0,0,w,h)
end

function TIC()

 if btn(0) then dir.y=-1
 elseif btn(1) then dir.y=1
 else dir.y=0 end
 if btn(2) then dir.x=-1
 elseif btn(3) then dir.x=1
 else dir.x=0 end
 
 if btnp(4) then dir.z=4 end
 
 if pos.x>w then pos.x=pos.x-w end
 if pos.x<0 then pos.x=w end
 if pos.y>h then pos.y=pos.y-h end
 if pos.y<0 then pos.y=h end
 
 pos.x=pos.x+dir.x
 pos.y=pos.y+dir.y
 pos.z=pos.z+dir.z
 if pos.z>0 then dir.z=dir.z-0.1 end
 if pos.z<=0 then pos.z=0;dir.z=0 end

	cls()
	rectb(0,0,240,136,15)
	--Field
	tile(0,0,w,h,7)
	tile(0,10,w,30,6)
	
	block(10,50,0, 10,10,8, 5,6,15)

	block(30,50,0, 10,10,8, 10,9,8)

	block(50,50,0, 10,10,8, 3,2,1)
		
	block(70,50,0, 10,10,8, 11,10,9)


	block(10,70,0, 10,10,8, 4,3,2)

	block(30,70,0, 10,10,8, 12,13,14)

	local px,py=translate(pos.x,pos.y)
 ispr(258,pos.x,pos.y,pos.z,2,2)
	rect(px-1,py-2,3,3,3)

end

-- <SPRITES>
-- 000:00000000000000000000000000000000000000000000000c000000cc00000ccb
-- 001:00000000000000000000000000ccccc00ccbbbddcbbbbaddbbbbaaddbbbaacdd
-- 002:000000000000000000000055000055550055555555555555665555cc6666cc55
-- 003:0000000000000000000000005500000055cc0000cc5555005555555555555577
-- 016:000cccbb00eecccbeee32eec0e322ee300322e32000000320000000000000000
-- 017:bbaacdd0baacddd0cccddd002eddd0002edd00002ee00000eee0000000000000
-- 018:66666655666666666666666666666666006666dd0000dd660000006600000000
-- 019:555577775577777767777777777777776dd77777677dd7006777000067000000
-- </SPRITES>

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

