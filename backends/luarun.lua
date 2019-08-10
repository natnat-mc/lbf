local compile=require 'backends.lua'

return function(ast)
	local code=compile(ast)
	local realio=io
	io={}
	io.read=realio.read
	local out={}
	io.write=function(o)
		table.insert(out, o)
	end
	(loadstring or load)(code)()
	io=realio
	return table.concat(out)
end
