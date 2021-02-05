@example  @c
"mystuff" inPackage
: ]shell { [] -> @ }
    do{
        t @.standardInput readStreamPacket[ ]pop
        "Huh?\n" ,
    }
;
@end example
