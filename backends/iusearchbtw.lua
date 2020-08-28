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
				local s=v>=0 and 'arch' or 'linux'
				for i=1, math.abs(v) do
					p(s)
				end
			elseif t=='mem' then
				local s=v>=0 and 'i' or 'use'
				for i=1, math.abs(v) do
					p(s)
				end
			elseif t=='value' then
				if not (ast.type=='root' and i==1) then
					p "the linux way"
				end
				if v>MAXINT/2 then
					p(string.rep('linux', MAXINT-v))
				else
					p(string.rep('arch', v))
				end
			elseif t=='read' then
				p "by"
			elseif t=='write' then
				p "btw"
			elseif t=='loop' then
				p "the"
				imp(n)
				p "way"
			else
				error("Unknown node type: "..t)
			end
		end
	end
	imp(ast)
	p "\n"
	return table.concat(acc, ' ')
end
