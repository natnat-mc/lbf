local constants=require 'constants'
local MAXMEM, MAXINT=constants.MAXMEM, constants.MAXINT

return function(ast)
	local mem={}
	for i=1, MAXMEM do
		mem[i]=0
	end
	local ptr, val=1, 0
	local out={}
	local function exec(ast)
		for i, node in ipairs(ast.value) do
			if node.type=='arith' then
				val=(val+node.value)%MAXINT
			elseif node.type=='value' then
				val=node.value%MAXINT
			elseif node.type=='mem' then
				mem[ptr], ptr=val, (ptr+node.value-1)%MAXMEM+1
				val=mem[ptr]
			elseif node.type=='write' then
				table.insert(out, string.char(val))
			elseif node.type=='read' then
				val=string.byte(io.read(1))
			elseif node.type=='loop' then
				while val~=0 do
					exec(node)
				end
			else
				error("Unrecognized node type: "..node.type)
			end
		end
	end
	exec(ast)
	return table.concat(out)
end
