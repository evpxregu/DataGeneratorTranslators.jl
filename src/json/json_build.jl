function build_json_rules(ast::ASTNode, rulenameprefix="")


    assign_rulenames(ast, rulenameprefix)

    rules = Vector{RuleSource}()
    build_json_jsonjl_specific(rules)
    build_json_rule(ast, rules)
    rules
end

function build_json_rule(node::ASTNode, rules::Vector{RuleSource})
	if node.func in [:JSON]
		println(string(node.func)* " refs size" * string(length(node.refs)))
		println(string(node.func)* " children size" * string(length(node.children)))
		#println("refs size" * string(length(node.refs)))
    	build_json_json(node, rules)
	elseif node.func in [:object]
		build_json_object(node, rules)
	elseif node.func in [:string]
		build_json_string(node, rules)
	elseif node.func in [:integer]
    	build_json_integer(node, rules)
	elseif node.func in [:array]
		build_json_array(node, rules)
	elseif node.func in [:boolean]
		build_json_boolean(node, rules)
	elseif node.func in [:number]
		build_json_number(node, rules)
	else
    	error("Unexpected JSON node function $(node.func)")
  	end
	for child in node.children
		build_json_rule(child, rules)
	end
end

function build_json_jsonjl_specific(rules::Vector{RuleSource})
  rule = RuleSource(:construct_json, [:content])
	# push!(rule.source, "construct_element(name::AbstractString, content::Array{Any}) = begin")
	# TODO for the moment, remove typing on arguments to rule since this breaks under Julia 4.0
	push!(rule.source, "begin")
	push!(rule.source, "  json = JSON.json(content)")
	push!(rule.source, "  json")
	push!(rule.source, "end")
  push!(rules, rule)
end



function build_json_json(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  methodname = build_called_rulename(node)
  push!(rule.source, "   content = $(methodname)()")
  push!(rule.source, "  construct_json(content)")
  build_rule_end(rule, node)
  push!(rules, rule)
end



function build_json_array(node::ASTNode, rules::Vector{RuleSource})
	  rule = build_rule_start(node)
	  methodname = build_called_rulename(node.children[1])

	  if (haskey(node.args,Symbol("minItems")) && haskey(node.args,Symbol("maxItems")))
	  	min = node.args[Symbol("minItems")]
	  	max = node.args[Symbol("maxItems")]
		push!(rule.source, "  content = reps($(node.children[1].rulename)(),$(min),$(max))")

	    elseif haskey(node.args,Symbol("minItems"))
	  	  min = node.args[Symbol("minItems")]
		  push!(rule.source, "  content = reps($(node.children[1].rulename)(),$(min))")

	    else
			push!(rule.source, "  content = mult($(node.children[1].rulename)())")
	    end


	  push!(rule.source, "  return content")
	  push!(rule.source, "  end")
	  #build_rule_end(rule,node)
	  push!(rules, rule)

end
function build_json_object_body(parentnode::ASTNode, rule::RuleSource)
  push!(rule.source, "  content = Dict{String,Any}()")
  for node in parentnode.children
    methodname = build_called_rulename(node)
    push!(rule.source, "  childcontent = $(node.rulename)()")
    push!(rule.source, "  content[\"$(node.args[:name])\"] = childcontent")  # note: this flattens arrays in childcontent in a way that push! would not do
  end
  push!(rule.source, "return content")
end

function build_json_object(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  build_json_object_body(node, rule)
  println(node.func)
  if haskey(node.args,:name)
	push!(rule.source, "  (\"$(escape_string(node.args[:name]))\", content)")
end
	# push!(rule.source, "  construct_element(\"$(escape_string(node.args[:name]))\", content)")
	# ... appear to need Main to be explicit when construct_element is defined outside of generator
  build_rule_end(rule, node)
  push!(rules, rule)
end
function build_json_string(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  min = 0
  max = 1000
  default_pattern = "[A-Z]"
  pattern = default_pattern
  if haskey(node.args,Symbol("minLength"))
	  min = node.args[Symbol("minLength")]
	  max = min +1000 #make sure we alwasy have a range even if maxlength is not set
  end
  if haskey(node.args,Symbol("maxLength"))
	  max = node.args[Symbol("maxLength")]
  end

  if !haskey(node.args,Symbol("pattern"))
	  push!(rule.source, "  choose(String, \"$(default_pattern){$(min),$(max)}\")")
  else
	  pattern = node.args[Symbol("pattern")]
	  push!(rule.source, "  choose(String, \"$(escape_string(pattern))\")")

  end


  build_rule_end(rule, node)
  push!(rules, rule)
end

function build_json_boolean(node::ASTNode, rules::Vector{RuleSource})
	rule = build_rule_start(node)
	push!(rule.source, "  choose(Bool)")
	build_rule_end(rule, node)
	push!(rules, rule)
end

function build_json_number(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)


  if (haskey(node.args,Symbol("minimum")) && haskey(node.args,Symbol("maximum")))
	  min = node.args[Symbol("minimum")]
	  max = node.args[Symbol("maximum")]
	  push!(rule.source, "  choose(Float64,$(min),$(max))")

	elseif haskey(node.args,Symbol("minimum"))
		min = node.args[Symbol("minimum")]
		push!(rule.source, "  choose(Float64,$(min))")
  	else
   		push!(rule.source, "  choose(Float64)")
	end
	# push!(rule.source, "  construct_element(\"$(escape_string(node.args[:name]))\", content)")
	# ... appear to need Main to be explicit when construct_element is defined outside of generator
  build_rule_end(rule, node)
  push!(rules, rule)
end



function build_json_integer(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)


  if (haskey(node.args,Symbol("minimum")) && haskey(node.args,Symbol("maximum")))
	  min = node.args[Symbol("minimum")]
	  max = node.args[Symbol("maximum")]
	  push!(rule.source, "  choose(Int32,$(min),$(max))")

	elseif haskey(node.args,Symbol("minimum"))
		min = node.args[Symbol("minimum")]
		push!(rule.source, "  choose(Int32,$(min))")
  	else
   		push!(rule.source, "  choose(Int32)")
	end
	# push!(rule.source, "  construct_element(\"$(escape_string(node.args[:name]))\", content)")
	# ... appear to need Main to be explicit when construct_element is defined outside of generator
  build_rule_end(rule, node)
  push!(rules, rule)
end

function build_json_attribute(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  @assert length(node.children)==1
  methodname = build_called_rulename(node.children[1])
  push!(rule.source, "  content = $(methodname)()")
  push!(rule.source, "  @assert typeof(content)<:AbstractString")
  push!(rule.source, "  (\"$(escape_string(node.args[:name]))\", content)")
  build_rule_end(rule, node)
  push!(rules, rule)
end


	function build_json_sequence(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  build_json_object_body(node, rule)
  push!(rule.source, "  content")
  build_rule_end(rule, node)
  push!(rules, rule)
end

function build_json_call(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)
  @assert length(node.children)==1
  methodname = build_called_rulename(node.children[1])
  push!(rule.source, "  $(methodname)()")
  build_rule_end(rule, node)
  push!(rules, rule)
end

function build_json_pattern(node::ASTNode, rules::Vector{RuleSource})
  rule = build_rule_start(node)

  push!(rule.source, "  choose(String, \"$(escape_string(node.args[:value]))\")")
  build_rule_end(rule, node)
  push!(rules, rule)
end

function build_json_choice(node::ASTNode, rules::Vector{RuleSource})
  if isempty(node.children)
	  rule = build_rule_start(node)
    push!(rule.source, "  (Any)[]")
	  build_rule_end(rule, node)
    push!(rules, rule)
  else
    for child in node.children
		  rule = build_rule_start(node)
	    methodname = build_called_rulename(child)
	    push!(rule.source, "  $(methodname)()")
		  build_rule_end(rule, node)
      push!(rules, rule)
		end
  end
end
