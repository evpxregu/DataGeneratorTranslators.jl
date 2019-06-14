include("DataGeneratorTranslators.jl")
using DataGeneratorTranslators
using DataGenerators
using LightXML

open("jsongenerator.jl", "w") do fh
    json_generator(fh, :ExampleJSONGen, "jsonschema.json", "library")
end
# include the generator
include("jsongenerator.jl")

# create an instance of the generator
g = ExampleJSONGen()

print(choose(g))
