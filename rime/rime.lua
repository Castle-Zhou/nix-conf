single_char_only_keyword = "single_char_only"
single_char_first_keyword = "single_char_first"

function single_char(input, env)
	local single_char_only = env.engine.context:get_option(single_char_only_keyword)
	local single_char_first = env.engine.context:get_option(single_char_first_keyword)
	if (single_char_only) then
		for cand in input:iter() do
			if (utf8.len(cand.text) == 1 or cand.type == "date_translator" or cand.text == "——" or cand.text == "……") then
				yield(cand)
			end
		end
	else
		if (single_char_first) then
			local l = {}
			for cand in input:iter() do
				if (utf8.len(cand.text) == 1) then
					yield(cand)
				else
					table.insert(l, cand)
				end
			end
			for i, cand in ipairs(l) do
				yield(cand)
			end
		else
			for cand in input:iter() do
				yield(cand)
			end
		end
	end
end