using DataGenerators

# grammar fasta;
@generator FastaGen begin
    # Since sequence is first non-terminal:
    start() = sequence()

    # sequence
    #    : section +
    #    ;
    sequence() = join(plus(section))

    # section
    #    : descriptionline
    #    | sequencelines
    #    | commentline
    #    ;
    section() = descriptionline()
    section() = sequencelines()
    section() = commentline() 

    # sequencelines
    #    : SEQUENCELINE +
    #    ;
    sequencelines() = join(plus(SEQUENCELINE))

    # descriptionline
    #    : DESCRIPTIONLINE
    #    ;
    descriptionline() = DESCRIPTIONLINE__2()

    # commentline
    #    : COMMENTLINE
    #    ;
    commentline() = COMMENTLINE__2()
 
    # COMMENTLINE
    #    : ';' .*? EOL
    #    ;
    COMMENTLINE__2() = ";" * choose(String, ".*") * EOL() 
 
    # DESCRIPTIONLINE
    #    : '>' TEXT ('|' TEXT)* EOL
    #    ;
    DESCRIPTIONLINE__2() = ">" * TEXT() * join(mult(intermediary_rule_1)) * EOL()
    intermediary_rule_1() = "|" * TEXT()

    # TEXT
    #    : (DIGIT | LETTER | SYMBOL) +
    #    ;
    TEXT() = join(plus(intermediary_rule_2))
    intermediary_rule_2() = DIGIT()
    intermediary_rule_2() = LETTER()
    intermediary_rule_2() = SYMBOL()

    # EOL
    #    : '\r'? '\n'
    #    ;
    EOL() = join(reps("\r", 0, 1)) * "\n"

    # fragment DIGIT
    # : [0-9]
    # ;
    DIGIT() = choose(String, "[0-9]")

    # fragment LETTER
    #    : [A-Za-z]
    #    ;
    LETTER() = choose(String, "[A-Za-z]")

    # fragment SYMBOL
    #    : '.' | '-' | '+' | '_' | ' ' | '[' | ']' | '(' | ')' | ',' | '/' | ':' | '&' | '\''
    #    ;
    SYMBOL() = "."
    SYMBOL() = "-"
    SYMBOL() = "+"
    SYMBOL() = "_"
    SYMBOL() = "["
    SYMBOL() = "]"
    SYMBOL() = "("
    SYMBOL() = ")"
    SYMBOL() = ","
    SYMBOL() = "/"
    SYMBOL() = ":"
    SYMBOL() = "&"
    SYMBOL() = "'"

    # SEQUENCELINE
    #    : LETTER + EOL
    #    ;
    SEQUENCELINE() = join(plus(LETTER)) * EOL()
end

gen = FastaGen()
# Not sure the fasta.g4 grammar really is correct since it does not seem to match what is
# on the FASTA page in Wikipedia: https://en.wikipedia.org/wiki/FASTA_format
choose(gen) 