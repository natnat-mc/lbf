local constants=require 'constants'
local MAXINT, MAXMEM=constants.MAXINT, constants.MAXMEM

return function(ast)
	local acc={"#include <stdio.h>\n", "#define MAXMEM ", MAXMEM, "\n", "#define T "}
	local function w(a)
		table.insert(acc, a)
	end

	if MAXINT==256 then
		w "char\n"
	elseif MAXINT==65536 then
		w "short\n"
	elseif MAXINT==math.pow(2, 32) then
		w "uint32_t\n"
	else
		error "Unsupported MAXINT value"
	end
	w "int main(void) {\n"
	w "\tT array[MAXMEM]={0};\n"
	w "\tT* ptr=array;\n"

	local function f(p, s)
		for i, n in ipairs(p.value) do
			local t, v=n.type, n.value
			w(string.rep('\t', s))
			if t=='arith' then
				w "(*ptr)+="
				w(v)
				w ";\n"
			elseif t=='value' then
				w "*ptr=(T) "
				w(v)
				w ";\n"
			elseif t=='mem' then
				w "ptr+="
				w(v)
				w ";\n"
			elseif t=='read' then
				w "*ptr=getchar();\n"
			elseif t=='write' then
				w "putchar((char) *ptr);\n"
			elseif t=='loop' then
				w "while(*ptr) {\n"
				f(n, s+1)
				w(string.rep('\t', s))
				w "}\n"
			else
				error("Unknown node type: "..t)
			end
		end
	end
	f(ast, 1)
	w "}\n"
	return table.concat(acc)
end

