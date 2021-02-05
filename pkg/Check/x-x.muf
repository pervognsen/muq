
"Propdir tests\n" log,
"\nPropdir tests:" ,

( For awhile propdirs were badly broken, perhaps particularly ones	)
( with mixtures of btree and fixed keyval pairs.  This regression	)
( file is intended to prevent a repeat of that problem:			)


19 -->constant TIMES



( ------ INDEX OBJECTS ------- )


( All of the above keys: )
makeIndex --> _i
for i from 0 below TIMES do{ i                            -> key  i --> _i[key] }
for i from 0 below TIMES do{ i 0.5 +                      -> key  i --> _i[key] }
for i from 0 below TIMES do{ [ "a%03d"  i | ]print        -> key  i --> _i[key] }
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  i --> _i[key] }
0 --> _whoopsies
for i from 0 below TIMES do{ i                            -> key  _i[key] i != if ++ _whoopsies fi }
for i from 0 below TIMES do{ i 0.5 +                      -> key  _i[key] i != if ++ _whoopsies fi }
for i from 0 below TIMES do{ [ "a%03d"  i | ]print        -> key  _i[key] i != if ++ _whoopsies fi }
for i from 0 below TIMES do{ [ ":a%03d" i | ]print intern -> key  _i[key] i != if ++ _whoopsies fi }
:: _whoopsies 0 = ; shouldBeTrue

