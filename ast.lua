--[[ typedef node
	type: string
]]
--[[ typedef rootnode
	type: 'root'
	value: list<node>
]]
--[[ typedef arithnode extends node
	type: 'arith'
	value: int
]]
--[[ typedef memnode extends node
	type: 'mem'
	value: int
]]
--[[ typedef loopnode extends node
	type: 'loop'
	value: list<node>
]]
--[[ typedef ionode extends node
	type: 'read'|'write'
]]
--[[ typedef valuenode extends node
	type: 'value'
	value: int
]]

local chars={}
chars['['], chars[']'], chars['>'], chars['<'], chars['+'], chars['-'], chars['.'], chars[',']=1, 1, 2, 2, 2, 2, 1, 1

local function tokenize(code)
	code=code:gsub("[^%[%]%+%-<>.,]", '')
	return coroutine.wrap(function()
		local pos, len=1, #code
		while pos<=len do
			local chr=code:sub(pos, pos)
			if chars[chr]==2 then
				local nextpos=pos+1
				while nextpos<=len and code:sub(nextpos, nextpos)==chr do
					nextpos=nextpos+1
				end
				local len=nextpos-pos
				pos=nextpos
				coroutine.yield(chr, len)
			else
				pos=pos+1
				coroutine.yield(chr, 1)
			end
		end
	end)
end

local function parse(code)
	local function createnode(type, value)
		return {type=type, value=value}
	end
	local stack={createnode('root', {})}

	local function addnode(type, value)
		table.insert(stack[#stack].value, createnode(type, value))
	end
	local function pushnode(type, value)
		addnode(type, value)
		table.insert(stack, stack[#stack].value[#(stack[#stack].value)])
	end
	local function popnode(type)
		local node=table.remove(stack)
		if type~=node.type then
			error "Type mismatch for pop"
		end
		return node
	end

	for char, len in tokenize(code) do
		if char=='+' then
			addnode('arith', len)
		elseif char=='-' then
			addnode('arith', -len)
		elseif char=='>' then
			addnode('mem', len)
		elseif char=='<' then
			addnode('mem', -len)
		elseif char=='.' then
			addnode('write')
		elseif char==',' then
			addnode('read')
		elseif char=='[' then
			pushnode('loop', {})
		elseif char==']' then
			local ok=pcall(popnode, 'loop')
			if not ok then
				error "Unexpected ']'"
			end
		end
	end
	local ok, root=pcall(popnode, 'root')
	if not ok then
		error "Unbalanced '['"
	end
	return root
end

local function optimize(ast)
	local working, didsomething=true, false
	while working do
		working=false
		local child, prev
		for i=1, #(ast.value) do
			child, prev=ast.value[i], child
			if child.type=='loop' then
				if #(child.value)==1 and child.value[1].type=='arith' and child.value[1].value%2==1 then -- reset loops
					child.type='value'
					child.value=0
					working=true
				elseif prev and prev.type=='value' and prev.value==0 then -- loops that never get executed
					table.remove(ast.value, i)
					i=i-1
					working=true
				end
				if optimize(child) then -- optimize children
					working=true
				end
			elseif child.type=='arith' and prev then
				if prev.type=='arith' then -- combine arith nodes
					table.remove(ast.value, i)
					i=i-1
					prev.value=prev.value+child.value
					working=true
				elseif prev.type=='value' then -- combine value and arith
					table.remove(ast.value, i)
					i=i-1
					prev.value=prev.value+child.value
					working=true
				end
			elseif child.type=='value' and prev then
				if prev.type=='arith' or prev.type=='value' then -- remove overwritten values and arith
					table.remove(ast.value, i-1)
					i=i-1
					working=true
				end
			elseif child.type=='mem' and prev then
				if prev.type=='mem' then -- combine mem nodes
					table.remove(ast.value, i)
					i=i-1
					prev.value=prev.value+child.value
					working=true
				end
			end
			if (child.type=='arith' or child.type=='mem') and child.value==0 then -- cleanup useless nodes
				table.remove(ast.value, i)
				i=i-1
				working=true
			end
		end
		if working then
			didsomething=true
		end
	end
	return didsomething
end

return {
	parse=parse,
	optimize=optimize
}
