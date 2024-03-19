%{
    
    #include <iostream>
    #include <stdio.h>
    using std::cout;

    int yylex(void);
    int yyparse(void);
    void yyerror(const char *);

    double variables[26];
 
%}

%union {
	double num;
	int ind;
}

%token SOME ALL VALUE MIN MAX EXACTLY THAT NOT OR AND ONLY CLASS PROPRIETY INSTANCY SSYMBOL DTYPE CARDINALIDADE 
%token RCLASS RSUBCLASS REQUIVALENT RINDIVIDUALS RDISJOINT '[' ']' '(' ')' ',' '{' '}'

%%

classe: classeDefinida classe
    | classePrimitiva classe
    | classeComum classe
    | 
    ;

classeComum: RCLASS CLASS disjoint individuals { std::cout << "Achei uma classe comum\n"; }
    ;

classePrimitiva: RCLASS CLASS subclass disjoint individuals { std::cout << "Achei uma classe primitiva\n"; }
    ;

classeDefinida: RCLASS CLASS equivalent disjoint individuals { std::cout << "Achei uma classe definida\n"; } 
    ;

equivalent: REQUIVALENT CLASS equivProbs
    | REQUIVALENT CLASS '(' equivProbs ')'
    | REQUIVALENT instancies  { std::cout << "Classe enumerada! "; }
    ;

equivProbs: ',' seqProp
    | connect seqProp
    | connect multClasses { std::cout << "Classe coberta! "; }
    ;

individuals: RINDIVIDUALS instancies
    |
    ;

disjoint: RDISJOINT seqClasses
    |
    ;

subclass: RSUBCLASS CLASS
    | RSUBCLASS seqProp
    | RSUBCLASS CLASS connect seqProp
    | RSUBCLASS CLASS ',' seqProp
    ;                                             

seqClasses: CLASS
    | CLASS ',' seqClasses
    | '(' seqClasses ')' 
    ;

instancies: INSTANCY
    | INSTANCY ',' instancies
    | '{' instancies '}'
    ;    

connect: OR
    | AND
    ;

seqProp: prop
    | '(' prop ')' connect seqProp
    | prop ',' seqProp
    ;

prop: PROPRIETY some
    | PROPRIETY only        { std::cout << "Axioma de fechamento! "; }
    | PROPRIETY value
    | PROPRIETY qntd
    | PROPRIETY EXACTLY
    | PROPRIETY ALL
    | '(' prop ')'
    ;

only: ONLY multClasses
    | ONLY '(' multClasses ')'
    ;

multClasses: CLASS
    | CLASS connect multClasses  
    ;

some: SOME CLASS
    | SOME DTYPE especificardtype
    | SOME prop             { std::cout << "Descrição aninhada! "; }
    ;

especificardtype: '[' SSYMBOL CARDINALIDADE ']'
    |
    ;

qntd: MIN CARDINALIDADE DTYPE
    | MAX CARDINALIDADE DTYPE
    | MIN CARDINALIDADE CLASS
    | MAX CARDINALIDADE CLASS
    ;

value: VALUE CLASS
    | VALUE INSTANCY
    ;

%%

/* definido pelo analisador léxico */
extern FILE * yyin;  

int main(int argc, char ** argv)
{

    /* se foi passado um nome de arquivo */
	if (argc > 1)
	{
		FILE * file;
		file = fopen(argv[1], "r");
		if (!file)
		{
			cout << "Arquivo " << argv[1] << " não encontrado!\n";
			exit(1);
		}

		/* entrada ajustada para ler do arquivo */
		yyin = file;
	}

	yyparse();
}

void yyerror(const char * s)
{
	/* variáveis definidas no analisador léxico */
	extern int yylineno;    
	extern char * yytext;   

	/* mensagem de erro exibe o símbolo que causou erro e o número da linha */
    cout << "Erro sintático: símbolo \"" << yytext << "\" (linha " << yylineno << ")\n";
}