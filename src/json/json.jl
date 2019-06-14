include("json_parse.jl")
include("json_transform.jl")
include("json_build.jl")


function printAst(node::ASTNode,depth::Int64)
	for i in 1:depth
		print("   ")
	end

	println("print ast " * 	string(node.func) * " name: " )

	for k in node.children
		printAst(k, depth + 1)
	end

end

function json_rules(jsonuri::AbstractString, startelement::AbstractString, rulenameprefix="")
	ast = parse_json(jsonuri)
	printAst(ast,0)
	transform_json_ast(ast, startelement)
	println("children: " * string(length(ast.children)))

	push!(ast.refs,ast.children[1])
	transform_ast(ast)
	println("children: " * string(length(ast.children)))
	build_json_rules(ast, rulenameprefix)
end

function json_generator(io::IO, genname::Symbol, jsonuri::AbstractString, startelement::AbstractString)
	rules = json_rules(jsonuri, startelement)
	description = "JSON generator"
	output_generator(io, genname, description, rules)
end

json_generator(genname::Symbol, jsonuri::AbstractString, startelement::AbstractString) = include_generator(genname, json_generator, jsonuri, startelement)
