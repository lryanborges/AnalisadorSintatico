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

%token SOME ALL VALUE MIN MAX EXACTLY THAT NOT AND OR ONLY CLASS PROPRIETY INSTANCY SSYMBOL DTYPE CARDINALIDADE 
%token RCLASS RSUBCLASS REQUIVALENT RINDIVIDUALS RDISJOINT '[' ']' '(' ')' ',' '{' '}'

%left '[' ']'

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

classeDefinida: RCLASS CLASS equivalent individuals { std::cout << "Achei uma classe definida\n"; } 
    ;

equivalent: REQUIVALENT classConnect // :
    | REQUIVALENT instancies  { std::cout << "Achei uma classe enumerada "; }
    | REQUIVALENT multClasses
    ;

individuals: RINDIVIDUALS instancies // :
    |
    ;

disjoint: RDISJOINT seqClasses
    |
    ;

subclass: RSUBCLASS seqProp // :
    | RSUBCLASS classConnect
    ;

classConnect: CLASS
    | CLASS connect seqProp
    | CLASS ',' seqProp
    | '{' classConnect '}'      { std::cout << "Achei uma classe enumerada "; } // nesse caso tá meio que errado 
    ;                                                   // pq enum é só com instancias, mas deixei pra caber no exemplo

seqClasses: CLASS
    | CLASS ',' seqClasses
    | '(' seqClasses ')'        { std::cout << "Achei uma classe enumerada "; }
    ;

instancies: INSTANCY
    | INSTANCY ',' instancies
    | '{' instancies '}'
    ;    

seqProp: prop
    | prop connect seqProp
    | prop ',' seqProp
    ;
    
connect: AND
    | OR
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
    ;

multClasses: CLASS
    | CLASS connect multClasses     
    | '(' multClasses ')'
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