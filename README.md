# DataGeneratorTranslators

<> [![Build Status](https://travis-ci.org/simonpoulding/DataGeneratorTranslators.jl.svg?branch=master)](https://travis-ci.org/simonpoulding/DataGeneratorTranslators.jl)

<> [![Coverage Status](https://coveralls.io/repos/simonpoulding/DataGeneratorTranslators.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/simonpoulding/DataGeneratorTranslators.jl?branch=master)

<> [![codecov.io](http://codecov.io/github/simonpoulding/DataGeneratorTranslators.jl/coverage.svg?branch=master)](http://codecov.io/github/simonpoulding/DataGeneratorTranslators.jl?branch=master)

DataGeneratorTranslators is a package for automatically creating data generators from specifications such as Backus-Naur Form (BNF), XML Schema Definition (XSD), regular expressions, and Julia Type definitions.  The generators can be run using the [DataGenerators](https://github.com/robertfeldt/DataGenerators.jl)

Note! Going forward this will be the main DataGeneratorTranslators.jl package repo since my colleague and close collaborator Simon Poulding unfortunately passed away during 2017. We worked on these packages together but I will have to carry the torch forward.

## Installation

Install by cloning the package directly from GitHub from a Julia REPL:

    julia> Pkg.clone("https://github.com/robertfeldt/DataGeneratorTranslators.jl")
	
To run the generators created requires the DataGenerators package:

    julia> Pkg.clone("https://github.com/robertfeldt/DataGenerators.jl")


## Usage 

### Translator from XML Schema Definition (XSD)

Translate an XML Schema Definition into a data generator using the function:

	xsd_generator(io::IO, genname::Symbol, xsduri::AbstractString, startelement::AbstractString)

where `io` is the file handle (or other output stream) for the generator, `genname` the name of the generater created (as a symbol), `xsduri` the file or URL of the XML Schema Definition, and `startelement` the top-level element in the generated XML (as this is not specified in XSD).

Note that the created generators require the `LightXML` package (install using `Pkg.add("LightXML")`) in order to output XML.

For example:

	using DataGeneratorTranslators
	using DataGenerators
	using LightXML
	
	# XML Schema Definition is in file example.xsd
	# Creates a generator (saved in the file generator.jl) for XML satisfying the XSD and with top level element <library>
	open("generator.jl", "w") do fh
		xsd_generator(fh, :ExampleXMLGen, "example.xsd", "library")
	end
	
	# include the generator
	include("generator.jl")
	
	# create an instance of the generator
	g = ExampleXMLGen()
	
	# generate XML satisfying the XSD
	choose(g)

For convenience, the function (as above but without the first parameter):

	xsd_generator(genname::Symbol, xsduri::AbstractString, startelement::AbstractString)

creates the generator and includes it in the current context.


### Translator from Backus-Naur Form (BNF or EBNF)

Translate BNF or EBNF into a data generator using the function:

	bnf_generator(io::IO, genname::Symbol, bnf::IO, startvariable::AbstractString, syntax::Symbol=:ebnf, addwhitespace::Bool=true)

where `io` is the file handle (or other output stream) for the generator, `genname` the name of the generater created (as a symbol), `bnf` the file or stream containing the BNF, `syntax` should be left as the default of ``:ebnf` for *both* BNF and EBNF (this parameter is intended for support of specific BNF variants in future releases), `addwhitespace` determines whether or not the spaces are added between terminals in the generated string.

For convenience, the function (as above but without the first parameter):

	bnf_generator(genname::Symbol, bnf::IO, startvariable::AbstractString, syntax::Symbol=:ebnf, addwhitespace::Bool=true)

creates the generator and includes it in the current context.


### Translator from Regular Expression

The `DataGenerators` package supports Regular Expressions directly using `choose(String, <regex>)`.  For example:

	@generator ShortStringGen begin
		start() = choose(String, "[A-Z]{5,15}")
	end

This use is preferred over creating standalone generators.  (It uses this `DataGeneratorTranslators` package to create the additional rules for the regular expression.) 

But for completeness, a regular expression can be translated into a data generator using the function:

	regex_generator(io::IO, genname::Symbol, regex::AbstractString, datatype::DataType=String)


### Translator from Julia Type Definition

Note! This translator is not yet updated for Julia 0.6 so is currently inactivated.

Create a data generator for instance of Julia types using this translator.  Both concrete and abstract types are supported as well as parameterised and user-defined types.  The translator identifies potential constructor methods for the types, but calling such methods can give rise to exceptions - these are trapped and returned as `TypeGenerationException`s.

The generator can be output to a stream (see example code above for the XSD):

	type_generator(io::IO, genname::Symbol, t::Type, supporteddts::Vector{DataType}=Vector{DataType}())

or, for convenience, included in the current context using:

	type_generator(genname::Symbol, t::Type, supporteddts::Vector{DataType}=Vector{DataType}()) = include_generator(genname, type_generator, t, supporteddts)

where `t` is the type.  The parameter `dt` identifies which subtrees of the type hierarchy should be considered when creating the generator as a list of root types of those subtrees - this avoids including the entire type hierarchy in the generator when types such as `Any` arise in the translation process.  It defaults to all the primary types used in the type `t`.


#### Example 1 - Abstract  Type

	julia> using DataGeneratorTranslators
	julia> using DataGenerators
	
	julia> type_generator(:IntegerGen, Integer)
	julia> g = IntegerGen()
	julia> choose(g)
	 -14033
	julia> typeof(ans)
	 Int16


#### Example 2 - Parameterised Type

	julia> type_generator(:RationalGen, Rational, [Number,])
	julia> g = RationalGen()
	julia> choose(g)
	 10x44ba//0x0001
	julia> typeof(ans)
	 Rational{UInt16}



## References

DataGeneratorTranslators is based in a number of research articles describing our general approach to test data generation (called GodelTest):

[1] R. Feldt and S. Poulding, "[Finding Test Data with Specific Properties via Metaheuristic Search](http://www.robertfeldt.net/publications/feldt_2013_godeltest.html)", ISSRE 2013 (best paper award!)

[2] S. Poulding and R. Feldt, "[Generating Structured Test Data with Specific Properties using Nested Monte-Carlo Search](http://www.robertfeldt.net/publications/poulding_2014_godeltest_with_nmcs.html)", GECCO 2014

[3] S. Poulding and R. Feldt, "[The Automated Generation of Human-Comprehensible XML Test Sets](http://www.simonpoulding.net/papers/nasbase_2015_preprint.pdf), NasBASE, 2015

[4] S. Poulding and R. Feldt, "[Re-using Generators of Complex Test Data](http://www.robertfeldt.net/publications/poulding_2015_reusing_generators_complex_test_data.html)", ICST 2015 

[5] R. Feldt and S. Poulding, "[Broadening the Search in Search-Based Software Testing: It Need Not Be Evolutionary](http://www.robertfeldt.net/publications/feldt_2015_broadening_the_sbst_search.html)", SBST 2015

[6] R. Feldt, S. Poulding, D. Clark and S. Yoo, "[Test Set Diameter: Quantifying the Diversity of Sets of Test Cases](http://www.robertfeldt.net/publications/feldt_2015_test_set_diameter.html)", ICST 2016

[7] S. Poulding and R. Feldt, "[Automated Random Testing in Multiple Dispatch Languages](http://www.simonpoulding.net/papers/icst_2017_preprint.pdf)", ICST 2017