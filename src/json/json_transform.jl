# TODO:
# (1) Is the mixed attribute handled correctly? Should it propogate 'into' groups, sequence etc.?

function transform_json_ast(ast::ASTNode, startelement)
     elementglobaldefs = Dict{AbstractString,ASTNode}()
     substitutiongroups = Dict{AbstractString,Array{AbstractString}}()
     attributeglobaldefs = Dict{AbstractString,ASTNode}()
     process_json_element_nodes(ast, elementglobaldefs, substitutiongroups)
     #process_json_attribute_nodes(ast, attributeglobaldefs)

end



function process_json_element_nodes(parentnode::ASTNode, elementglobaldefs, substitutiongroups)

  for node in parentnode.children

    # if haskey(node.args,:name)
    #   elementname = node.args[:name]
    #   println("node name:" * elementname)
    # end
    if node.func in [:object]

      if parentnode.func == :json
        elementname = node.args[:name]
        println("node name:" * elementname)
        elementglobaldefs[elementname] = node
      end
    end
   process_json_element_nodes(node, elementglobaldefs, substitutiongroups)
  end
end
