local MAXINT=require 'constants'.MAXINT

return function(ast)
	local acc={}
	local function p(a)
		table.insert(acc, a)
	end
	local function imp(ast)
		for i, n in ipairs(ast.value) do
			local t, v=n.type, n.value
			if t=='arith' then
				p(string.rep(v>=0 and '+' or '-', math.abs(v)))
			elseif t=='mem' then
				p(string.rep(v>=0 and '>' or '<', math.abs(v)))
			elseif t=='value' then
				if not (ast.type=='root' and i==1) then
					p "[-]"
				end
				if v>MAXINT/2 then
					p(string.rep('-', MAXINT-v))
				else
					p(string.rep('+', v))
				end
			elseif t=='read' then
				p ","
			elseif t=='write' then
				p "."
			elseif t=='loop' then
				p "["
				imp(n)
				p "]"
			else
				error("Unknown node type: "..t)
			end
		end
	end
	imp(ast)
	p "\n"
	return table.concat(acc)
end
