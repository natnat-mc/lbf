local constants=require 'constants'
local MAXINT, MAXMEM=constants.MAXINT, constants.MAXMEM

return function(ast)
	local acc={}
	local function p(s)
		table.insert(acc, s)
	end

	p "const mem=[];\n"
	p "let ptr=0, val=0;\n"
	p "for(i=0; i<"
	p(MAXMEM)
	p "; i++) mem[i]=0;\n"
	p "\n"

	p "let input=prompt('Script input')||'', inidx=0;\n"
	p "let output='';\n"
	p "const read=function() {\n\treturn input.charCodeAt(inidx++)||0;\n}\n"
	p "const write=function(v) {\n\toutput+=String.fromCharCode(v);\n}\n"
	p "\n"

	local function cc(ast, ind)
		for i, node in ipairs(ast.value) do
			if ind~=0 then
				p(string.rep('\t', ind))
			end
			local t, v=node.type, node.value
			if t=='arith' then
				if v==1 then
					p "val++"
				elseif v==-1 then
					p "val--"
				elseif v>=0 then
					p "val+="
					p(v%MAXINT)
				else
					p "val-="
					p(-v%MAXINT)
				end
				p "; val&="
				p(MAXINT-1)
				p ";\n"
			elseif t=='value' then
				p "val="
				p(v%MAXINT)
				p ";\n"
			elseif t=='mem' then
				p "mem[ptr]=val; ptr"
				if v==1 then
					p "++"
				elseif v==-1 then
					p "--"
				elseif v>=0 then
					p "+="
					p(v%MAXMEM)
				else
					p "-="
					p((-v)%MAXMEM)
				end
				p "; ptr&="
				p(MAXMEM-1)
				p "; val=mem[ptr];\n"
			elseif t=='write' then
				p "write(val);\n"
			elseif t=='read' then
				p "val=read();\n"
			elseif t=='loop' then
				p "while(val) {\n"
				cc(node, ind+1)
				if ind~=0 then
					p(string.rep('\t', ind))
				end
				p "}\n"
			else
				error("Unknown node type: "..t)
			end
		end
	end
	cc(ast, 0)
	p "\n"
	p "alert(output);\n"
	return table.concat(acc)
end
