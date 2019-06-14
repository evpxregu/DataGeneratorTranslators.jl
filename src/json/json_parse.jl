#
# jsonuri may URL as well as local file
#
function parse_json(jsonuri)
	jsonroot =JSON.parsefile(jsonuri)

	if !haskey(jsonroot,"\$schema")
		error("JSON is not a valid JSON schema") #note rh, check for version later maybe?
	end

	node = ASTNode(:JSON)

	 parse_json_root(jsonroot,node, jsonuri)

	return node
end

function parse_json_attribute(element::Dict{String,Any}, node::ASTNode, attributename)
	if haskey(element, attributename)
		node.args[Symbol(attributename)] = element[attributename]
	end
end

function parse_json_root(parentelement::Dict{String,Any},parentnode::ASTNode, jsonuri)
	if !haskey(parentelement,"type")
		print(parentelement )
		print("no type")
	end

	if parentelement["type"]  in ["object","array","integer","string", "boolean"]
		node = ASTNode(Symbol(parentelement["type"]))
		push!(parentnode.children, node)
		if parentelement["type"] == "array"
			parse_json_attribute(parentelement,node,"minItems")
			parse_json_attribute(parentelement,node,"maxItems")
		elseif parentelement["type"] in ["integer","number"]
			parse_json_attribute(parentelement,node,"minimum")
			parse_json_attribute(parentelement,node,"maximum")
		elseif parentelement["type"] == "string"
			parse_json_attribute(parentelement,node,"minLength")
			parse_json_attribute(parentelement,node,"maxLength")
			parse_json_attribute(parentelement,node,"pattern")
		elseif parentelement["type"] == "object"
			parse_json_attribute(parentelement,node,"title")
			name = parentelement["title"]
			parse_json_elements(parentelement["properties"], node, jsonuri)
		end


	end
end


function parse_json_array_type(element::Dict{String,Any}, parentnode::ASTNode, jsonuri)
	println("json type:")
	println(element)
	if element["type"]  in ["object","array","integer","string","boolean"]
		node = ASTNode(Symbol(element["type"]))
		node.args[:name] = "arrayitem"
		push!(node.refs,parentnode)
		println("added node with name:" * node.args[:name] )
		push!(parentnode.children, node)
		if element["type"] == "array"
			parse_json_attribute(element,node,"minItems")
			parse_json_attribute(element,node,"maxItems")
		elseif element["type"] in ["integer","number"]
			parse_json_attribute(element,node,"minimum")
			parse_json_attribute(element,node,"maximum")
		elseif element["type"] == "string"
			parse_json_attribute(element,node,"minLength")
			parse_json_attribute(element,node,"maxLength")
			parse_json_attribute(parentelement,node,"pattern")

		elseif element["type"] == "object"
			parse_json_elements(element["properties"], node, jsonuri)
		elseif element["type"] == "array"
			parse_json_elements(element["items"], node, jsonuri)

		end

	end
end


function parse_json_elements(parentelement::Dict{String,Any}, parentnode::ASTNode, jsonuri)

	for k in keys(parentelement)
		element = parentelement[k]

		if element["type"]  in ["object","array","integer","string","boolean","number"]


			node = ASTNode(Symbol(element["type"]))
			node.args[:name] = k
			push!(node.refs,parentnode)
			println("added node with name:" * k * element["type"])
			push!(parentnode.children, node)
			if element["type"] == "array"
				parse_json_array_type(element["items"], node, jsonuri)
				parse_json_attribute(element,node,"minItems")
				parse_json_attribute(element,node,"maxItems")
			elseif element["type"] in ["integer","number"]
				parse_json_attribute(element,node,"minimum")
				parse_json_attribute(element,node,"maximum")
			elseif element["type"] == "string"
				parse_json_attribute(element,node,"minLength")
				parse_json_attribute(element,node,"maxLength")
				parse_json_attribute(element,node,"pattern")
			elseif element["type"] == "object"
				parse_json_elements(element["properties"], node, jsonuri)

			end
		end
	end
end
