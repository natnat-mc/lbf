return function(ast)
	local acc={}
	local function dump(ast, ind)
		if ind then
			table.insert(acc, string.rep('\t', ind))
		end
		table.insert(acc, ast.type)
		if ast.type=='arith' or ast.type=='mem' or ast.type=='value' then
			table.insert(acc, ':')
			table.insert(acc, ast.value)
			table.insert(acc, '\n')
		elseif ast.type=='loop' or ast.type=='root' then
			table.insert(acc, '\n')
			for i, child in ipairs(ast.value) do
				dump(child, ind+1)
			end
		else
			table.insert(acc, '\n')
		end
	end
	dump(ast, 0)
	return table.concat(acc)
end
