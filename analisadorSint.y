%{
    
    #include <iostream>
    #include <stdio.h>
    #include <cstring>
    using std::cout;

    int yylex(void);
    int yyparse(void);
    void yyerror(const char *);

    double variables[26];

    int numbClasses = 0;
    int comumClass = 0;
    int primitiveClass = 0;
    int definedClass = 0;
    int numErrors = 0;

    char currentClass[100];
    char currentProp[100];

    extern char *yytext;

%}

%union {
	double num;
	int ind;
}

%token SOME ALL VALUE MIN MAX EXACTLY THAT NOT OR AND ONLY INVERSE CLASS PROPRIETY INSTANCY SSYMBOL DTYPE CARDINALIDADE 
%token RCLASS RSUBCLASS REQUIVALENT RINDIVIDUALS RDISJOINT '[' ']' '(' ')' ',' '{' '}'

%%

classe: classeDefinida classe   { definedClass++; numbClasses++; }
    | classePrimitiva classe    { primitiveClass++; numbClasses++; }
    | classeComum classe        { comumClass++; numbClasses++; }
    | classeDesconhecida classe { numbClasses++; }
    | error classe             
    | 
    ;

rclass: RCLASS CLASS { strcpy(currentClass, yytext); }
    ;

classeComum: rclass disjoint individuals { std::cout << "Achei uma classe comum\n"; }
    ;

classePrimitiva: rclass subclass disjoint individuals { std::cout << "Achei uma classe primitiva\n"; }
    ;

classeDefinida: rclass equivalent disjoint individuals { std::cout << "Achei uma classe definida\n"; } 
    ;

classeDesconhecida: rclass equivalent subclass disjoint individuals { std::cout << "Achei uma classe diferente\n"; }
    ;

equivalent: requivalent CLASS equivProbs
    | requivalent instancies  { std::cout << "Classe enumerada! "; }
    ;

subclass: rsubclass CLASS
    | rsubclass seqProp
    | rsubclass CLASS connect seqProp
    | rsubclass CLASS ',' seqProp
    ;         

individuals: rindividuals instancies
    |
    ;

disjoint: rdisjoint seqClasses
    |
    ;    

requivalent: REQUIVALENT    { strcpy(currentProp, yytext); }
    ;

rsubclass: RSUBCLASS        { strcpy(currentProp, yytext); }
    ;        

rindividuals: RINDIVIDUALS  { strcpy(currentProp, yytext); }
    ;    

rdisjoint: RDISJOINT        { strcpy(currentProp, yytext); }
    ;                            

equivProbs: ',' seqProp
    | connect seqProp
    | connect multClasses { std::cout << "Classe coberta! "; }
    | '(' equivProbs ')'
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
    | prop connect seqProp          // removi '(' ')' do prop
    | prop ',' seqProp
    | INVERSE prop
    | INVERSE prop connect seqProp
    | INVERSE prop ',' seqProp
    ;

prop: PROPRIETY some
    | PROPRIETY only        { std::cout << "Axioma de fechamento! "; }
    | PROPRIETY value
    | PROPRIETY qntd
    | PROPRIETY exactly
    | PROPRIETY all
    | '(' seqProp ')'
    ;

only: ONLY CLASS                // basicamente to desconsiderando que pode vir "only (Classe)", apenas "only Classe"
    | ONLY '(' multClasses ')'
    ;

multClasses: CLASS
    | CLASS connect multClasses 
    ;

some: SOME CLASS
    | SOME '(' multClasses ')'
    | SOME DTYPE especificardtype
    | SOME prop             { std::cout << "Descrição aninhada! "; }
    //| error                 { std::cout << "Esperava CLASS, DTYPE, PROPRIETY\n"; }
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
    | VALUE DTYPE especificardtype
    ;

exactly: EXACTLY CARDINALIDADE CLASS
    | EXACTLY '{' instancies '}'
    ;

all: ALL CLASS 
    | ALL '(' multClasses ')'
    ;

%%

/* definido pelo analisador léxico */
extern FILE * yyin;  
int main(int argc, char ** argv)
{

    cout << "-------------------------------------------------------------------------------" << std::endl;
    cout << "\t\t\t\t ANÁLISE" << std::endl;
    cout << "-------------------------------------------------------------------------------" << std::endl;

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

    cout << "-------------------------------------------------------------------------------" << std::endl;
    cout << "\t\t\t\t RESULTADOS" << std::endl;
    cout << "-------------------------------------------------------------------------------" << std::endl;
    cout << "Classes comuns: " << comumClass << std::endl;
    cout << "Classes primitivas: " << primitiveClass << std::endl;
    cout << "Classes definidas: " << definedClass << std::endl;
    cout << "Classes com erro: " << numErrors << std::endl;
    cout << "Número de classes: " << numbClasses << std::endl;
    
}

void yyerror(const char * s)
{
	/* variáveis definidas no analisador léxico */
	extern int yylineno;    
	extern char * yytext;   

    numErrors++;
	/* mensagem de erro exibe o símbolo que causou erro e o número da linha */
    cout << "-------------------------------------------------------------------------------\n";
    cout << "ERRO SINTÁTICO: símbolo \"" << yytext << "\" (linha " << yylineno << " do arquivo)\n";
    cout << "ENCONTRADO NA CLASSE: " << currentClass << std::endl;
    cout << "ENCONTRADO NA PROPRIEDADE: \"" << currentProp << "\"\n";
    //cout << "Erro na " << numbClasses++ << "ª classe.\n";
    cout << "-------------------------------------------------------------------------------\n";
}