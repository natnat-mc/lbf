local constants=require 'constants'
local MAXINT, MAXMEM=constants.MAXINT, constants.MAXMEM

return function(ast)
	local acc={}
	local function p(s)
		table.insert(acc, s)
	end

	p "local mem, ptr, val={}, 0, 0\n"
	p "for i=0, "
	p(MAXMEM)
	p " do\n"
	p "\tmem[i]=0\n"
	p "end\n"
	p "\n"

	local function cc(ast, ind)
		for i, node in ipairs(ast.value) do
			if ind~=0 then
				p(string.rep('\t', ind))
			end
			local t, v=node.type, node.value
			if t=='arith' then
				p "val=(val"
				if v>=0 then
					p "+"
				end
				p(v)
				p ")%"
				p(MAXINT)
				p "\n"
			elseif t=='value' then
				p "val="
				p(v%MAXINT)
				p "\n"
			elseif t=='mem' then
				p "mem[ptr], ptr=val, (ptr"
				if v>=0 then
					p "+"
				end
				p(v)
				p ")%"
				p(MAXMEM)
				p "; val=mem[ptr]\n"
			elseif t=='write' then
				p "io.write(string.char(val))\n"
			elseif t=='read' then
				p "val=string.byte(io.read(1))\n"
			elseif t=='loop' then
				p "while val~=0 do\n"
				cc(node, ind+1)
				if ind~=0 then
					p(string.rep('\t', ind))
				end
				p "end\n"
			else
				error("Unknown node type: "..t)
			end
		end
	end
	cc(ast, 0)
	return table.concat(acc)
end
