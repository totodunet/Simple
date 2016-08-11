%{

#include "simple.h"
bool error_syntaxical=false;
bool error_semantical=false;
/* Notre table de hachage */
GHashTable* table_variable;

/* Fonction de suppression des variables declarees a l'interieur d'un arbre syntaxique */
void supprime_variable(GNode*);

/* Fonction permettant de dire si un noeud d'arbre contient un decimal ou non */
bool decimal(GNode*);

/* Notre structure Variable qui a comme membre le type et un pointeur generique vers la valeur */
typedef struct Variable Variable;

struct Variable{
	char* type;
	GNode* value;
};

%}

/* L'union dans Bison est utilisee pour typer nos tokens ainsi que nos non terminaux. Ici nous avons declare une union avec trois types : nombre de type int, texte de type pointeur de char (char*) et noeud d'arbre syntaxique (AST) de type (GNode*) */

%union {
	long entier;
	double decimal;
	char* texte;
	GNode*	noeud;
}

/* Nous avons ici les operateurs, ils sont definis par leur ordre de priorite. Si je definis par exemple la multiplication en premier et l'addition apres, le + l'emportera alors sur le * dans le langage. Les parenthese sont prioritaires avec %right */

%left			TOK_INCREMENTATION	TOK_DECREMENTATION	/* ++ -- */
%left			TOK_PLUS	TOK_MOINS	/* +- */
%left			TOK_MUL		TOK_DIV		TOK_MOD		/* /*% */
%left			TOK_PUISSANCE	/* ^ */
%left			TOK_ET		TOK_OU		TOK_NON		/* et ou non */
%left			TOK_EQU		TOK_DIFF	TOK_SUP         TOK_INF         TOK_SUPEQU      TOK_INFEQU      /* comparaisons */
%right			TOK_PARG	TOK_PARD	/* () */

/* Nous avons la liste de nos expressions (les non terminaux). Nous les typons tous en noeud de l'arbre syntaxique (GNode*) */

%type<noeud>		code
%type<noeud>		bloc_code
%type<noeud>		commentaire
%type<noeud>		instruction
%type<noeud>        condition
%type<noeud>        condition_si
%type<noeud>        condition_sinon
%type<noeud>        boucle_for
%type<noeud>        boucle_while
%type<noeud>        boucle_do_while
%type<noeud>		variable_entiere
%type<noeud>		variable_decimale
%type<noeud>		variable_booleenne
%type<noeud>		variable_texte
%type<noeud>		affectation
%type<noeud>		affichage
%type<noeud>		suppression
%type<noeud>		expression_arithmetique
%type<noeud>		expression_booleenne
%type<noeud>		expression_texte
%type<noeud>		addition
%type<noeud>		soustraction
%type<noeud>		multiplication
%type<noeud>		division
%type<noeud>		modulo

/* Nous avons la liste de nos tokens (les terminaux de notre grammaire) */

%token<entier>          TOK_ENTIER
%token<decimal>       	TOK_DECIMAL
%token                  TOK_VRAI        /* true */
%token                  TOK_FAUX        /* false */
%token                  TOK_AFFECT      /* = */
%token                  TOK_FINSTR      /* ; */
%token                  TOK_IN          /* dans */
%token                  TOK_CROG    TOK_CROD    /* [] */
%token                  TOK_AFFICHER    /* afficher */
%token<texte>           TOK_VARB        /* variable booleenne */
%token<texte>           TOK_VARE        /* variable entiere */
%token<texte>           TOK_VARD        /* variable decimale */
%token<texte>			TOK_VART
%token                  TOK_SI          /* si */
%token                  TOK_ALORS       /* alors */
%token                  TOK_SINON       /* sinon */
%token					TOK_COMMENT		/* commentaire */
%token					TOK_AFFECT_PLUS	TOK_AFFECT_MOINS	TOK_AFFECT_MUL	TOK_AFFECT_DIV	TOK_AFFECT_MOD	/* += -= *= /= %= */
%token					TOK_AFFECT_ET	TOK_AFFECT_OU	/* &= |= */
%token					TOK_POINT_INTERROGATION	/* ? */
%token					TOK_DOUBLE_POINT	/* : */
%token					TOK_FAIRE		/* faire */
%token					TOK_CROIX		/* x */
%token<texte>			TOK_TEXTE		/* texte libre */
%token					TOK_SUPPR		/* supprimer */

%%

/* Nous definissons toutes les regles grammaticales de chaque non terminal de notre langage. Par defaut on commence a definir l'axiome, c'est a dire ici le non terminal code. Si nous le definissons pas en premier nous devons le specifier en option dans Bison avec %start */

entree:		code{
				genere_code($1);
				g_node_destroy($1);
			};

bloc_code:	code{
				$$=g_node_new((gpointer)BLOC_CODE);
				g_node_append($$,$1);
				supprime_variable($1);
			}

code: 		%empty{$$=g_node_new((gpointer)CODE_VIDE);}
		|
		code commentaire{
			$$=g_node_new((gpointer)SEQUENCE);
			g_node_append($$,$1);
			g_node_append($$,$2);
		}
		|
 		code instruction{
			printf("Resultat : C'est une instruction valide !\n\n");
			$$=g_node_new((gpointer)SEQUENCE);
			g_node_append($$,$1);
			g_node_append($$,$2);
		}
		|
		code error{
			fprintf(stderr,"\tERREUR : Erreur de syntaxe a la ligne %d.\n",lineno);
 			error_syntaxical=true;
		};

commentaire:	TOK_COMMENT{
					$$=g_node_new((gpointer)CODE_VIDE);
				};

instruction:	affectation{
			printf("\tInstruction type Affectation\n");
			$$=$1;
 		}
		|
 		affichage{
			printf("\tInstruction type Affichage\n");
			$$=$1;
		}
		|
		condition{
		    printf("Condition si/sinon\n");
		    $$=$1;
		}
		|
		boucle_for{
			printf("Boucle repetee\n");
			$$=$1;
		}
		|
		boucle_while{
			printf("Boucle tant que\n");
			$$=$1;
		}
		|
		boucle_do_while{
			printf("Boucle faire tant que\n");
			$$=$1;
		}
		|
		suppression{
			printf("\tInstruction type Suppression\n");
			$$=$1;
		};

variable_entiere:	TOK_VARE{
				printf("\t\t\tVariable entiere %s\n",$1);
				$$=g_node_new((gpointer)VARIABLE);
				g_node_append_data($$,strdup($1));
			};
			
variable_decimale:	TOK_VARD{
				printf("\t\t\tVariable decimale %s\n",$1);
				$$=g_node_new((gpointer)VARIABLE);
				g_node_append_data($$,strdup($1));
			};

variable_booleenne:	TOK_VARB{
				printf("\t\t\tVariable booleenne %s\n",$1);
				$$=g_node_new((gpointer)VARIABLE);
				g_node_append_data($$,strdup($1));
			};

variable_texte:	TOK_VART{
				printf("\t\t\tVariable texte %s\n",$1);
				$$=g_node_new((gpointer)VARIABLE);
				g_node_append_data($$,strdup($1));
			};

condition:      condition_si TOK_FINSTR{
                    printf("\tCondition si\n");
                    $$=g_node_new((gpointer)CONDITION_SI);
                    g_node_append($$,$1);
                }
                |
                condition_si condition_sinon TOK_FINSTR{
                    printf("\tCondition si/sinon\n");
                    $$=g_node_new((gpointer)CONDITION_SI_SINON);
                    g_node_append($$,$1);
                    g_node_append($$,$2);
                }
                |
                TOK_PARG expression_booleenne TOK_PARD TOK_POINT_INTERROGATION bloc_code TOK_DOUBLE_POINT bloc_code TOK_FINSTR{
                	printf("\tCondition si/sinon\n");
                    $$=g_node_new((gpointer)CONDITION_SI_SINON);
                    g_node_append($$,g_node_new((gpointer)SI));
                    g_node_append(g_node_nth_child($$,0),$2);
                    g_node_append(g_node_nth_child($$,0),$5);
                    g_node_append($$,g_node_new((gpointer)SINON));
                    g_node_append(g_node_nth_child($$,1),$7);

                };

condition_si:   TOK_SI expression_booleenne TOK_ALORS bloc_code{
                    $$=g_node_new((gpointer)SI);
                    g_node_append($$,$2);
                    g_node_append($$,$4);
                };

condition_sinon:   TOK_SINON bloc_code{
                        $$=g_node_new((gpointer)SINON);
                        g_node_append($$,$2);
                    };

boucle_for:		TOK_PARG expression_arithmetique TOK_PARD TOK_CROIX bloc_code TOK_FINSTR{
					$$=g_node_new((gpointer)BOUCLE_FOR);
					g_node_append($$,g_node_new((gpointer)ENTIER));
					g_node_append_data(g_node_nth_child($$,0),strdup("0"));
					g_node_append($$,g_node_new((gpointer)ENTIER));
					g_node_append_data(g_node_nth_child($$,1),strdup("1"));
                    g_node_append($$,$2);
                    g_node_append($$,$5);
				}
				|
				TOK_PARG expression_arithmetique TOK_DOUBLE_POINT expression_arithmetique TOK_PARD bloc_code TOK_FINSTR{
					$$=g_node_new((gpointer)BOUCLE_FOR);
					g_node_append($$,$2);
					g_node_append($$,g_node_new((gpointer)ENTIER));
					g_node_append_data(g_node_nth_child($$,1),strdup("1"));
                    g_node_append($$,$4);
                    g_node_append($$,$6);
				}
				|
				TOK_PARG expression_arithmetique TOK_DOUBLE_POINT expression_arithmetique TOK_DOUBLE_POINT expression_arithmetique TOK_PARD bloc_code TOK_FINSTR{
					$$=g_node_new((gpointer)BOUCLE_FOR);
					g_node_append($$,$2);
                    g_node_append($$,$4);
                    g_node_append($$,$6);
                    g_node_append($$,$8);
				};

boucle_while:	TOK_PARG expression_booleenne TOK_PARD TOK_POINT_INTERROGATION bloc_code TOK_FINSTR{
					$$=g_node_new((gpointer)BOUCLE_WHILE);
					g_node_append($$,$2);
                    g_node_append($$,$5);
				};

boucle_do_while:	TOK_FAIRE bloc_code TOK_POINT_INTERROGATION TOK_PARG expression_booleenne TOK_PARD TOK_FINSTR{
						$$=g_node_new((gpointer)BOUCLE_DO_WHILE);
						g_node_append($$,$2);
	                    g_node_append($$,$5);
					};

affectation:	variable_entiere TOK_AFFECT expression_arithmetique TOK_FINSTR{
			/* $1 est la valeur du premier non terminal. Ici c'est la valeur du non terminal variable. $3 est la valeur du 2nd non terminal. */
			printf("\t\tAffectation sur la variable\n");
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				/* On cree une Variable et on lui affecte le type que nous connaissons et la valeur */
				var=malloc(sizeof(Variable));
				if(var!=NULL){
					var->type=strdup("entier");
					var->value=$3;
					/* On l'insere dans la table de hachage (cle: <nom_variable> / valeur: <(type,valeur)>) */
					if(g_hash_table_insert(table_variable,g_node_nth_child($1,0)->data,var)){
    					$$=g_node_new((gpointer)AFFECTATIONE);
    					g_node_append($$,$1);
    					g_node_append($$,$3);
					}else{
					    fprintf(stderr,"ERREUR - PROBLEME CREATION VARIABLE !\n");
					    exit(-1); 
					}
				}else{
					fprintf(stderr,"ERREUR - PROBLEME ALLOCATION MEMOIRE VARIABLE !\n");
					exit(-1);
				}
			}else{
				$$=g_node_new((gpointer)AFFECTATION);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_entiere TOK_AFFECT_PLUS expression_arithmetique TOK_FINSTR{
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
				error_semantical=true;
			}else{
				$$=g_node_new((gpointer)AFFECTATION_PLUS);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_entiere TOK_AFFECT_MOINS expression_arithmetique TOK_FINSTR{
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
				error_semantical=true;
			}else{
				$$=g_node_new((gpointer)AFFECTATION_MOINS);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_entiere TOK_AFFECT_MUL expression_arithmetique TOK_FINSTR{
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
				error_semantical=true;
			}else{
				$$=g_node_new((gpointer)AFFECTATION_MUL);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_entiere TOK_AFFECT_DIV expression_arithmetique TOK_FINSTR{
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
				error_semantical=true;
			}else{
				$$=g_node_new((gpointer)AFFECTATION_DIV);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_entiere TOK_AFFECT_MOD expression_arithmetique TOK_FINSTR{
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
				error_semantical=true;
			}else{
				$$=g_node_new((gpointer)AFFECTATION_MOD);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_entiere TOK_INCREMENTATION TOK_FINSTR{
			printf("\t\t\tIncrementation de +1 sur la variable\n");
		    $$=g_node_new((gpointer)AFFECTATION_INCR);
		    g_node_append($$,$1);
		}
		|
		variable_entiere TOK_DECREMENTATION TOK_FINSTR{
			printf("\t\t\tDecrementation de -1 sur la variable\n");
		    $$=g_node_new((gpointer)AFFECTATION_DECR);
		    g_node_append($$,$1);
		}
		|
		variable_decimale TOK_AFFECT expression_arithmetique TOK_FINSTR{
			/* $1 est la valeur du premier non terminal. Ici c'est la valeur du non terminal variable. $3 est la valeur du 2nd non terminal. */
			printf("\t\tAffectation sur la variable\n");
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				/* On cree une Variable et on lui affecte le type que nous connaissons et la valeur */
				var=malloc(sizeof(Variable));
				if(var!=NULL){
					var->type=strdup("decimal");
					var->value=$3;
					/* On l'insere dans la table de hachage (cle: <nom_variable> / valeur: <(type,valeur)>) */
					if(g_hash_table_insert(table_variable,g_node_nth_child($1,0)->data,var)){
    					$$=g_node_new((gpointer)AFFECTATIOND);
    					g_node_append($$,$1);
    					g_node_append($$,$3);
					}else{
					    fprintf(stderr,"ERREUR - PROBLEME CREATION VARIABLE !\n");
					    exit(-1); 
					}
				}else{
					fprintf(stderr,"ERREUR - PROBLEME ALLOCATION MEMOIRE VARIABLE !\n");
					exit(-1);
				}
			}else{
				$$=g_node_new((gpointer)AFFECTATION);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_decimale TOK_AFFECT_PLUS expression_arithmetique TOK_FINSTR{
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
				error_semantical=true;
			}else{
				$$=g_node_new((gpointer)AFFECTATION_PLUS);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_decimale TOK_AFFECT_MOINS expression_arithmetique TOK_FINSTR{
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
				error_semantical=true;
			}else{
				$$=g_node_new((gpointer)AFFECTATION_MOINS);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_decimale TOK_AFFECT_MUL expression_arithmetique TOK_FINSTR{
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
				error_semantical=true;
			}else{
				$$=g_node_new((gpointer)AFFECTATION_MUL);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_decimale TOK_AFFECT_DIV expression_arithmetique TOK_FINSTR{
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
				error_semantical=true;
			}else{
				$$=g_node_new((gpointer)AFFECTATION_DIV);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_decimale TOK_AFFECT_MOD expression_arithmetique TOK_FINSTR{
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
				error_semantical=true;
			}else{
				$$=g_node_new((gpointer)AFFECTATION_MOD);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_decimale TOK_INCREMENTATION TOK_FINSTR{
			printf("\t\t\tIncrementation de +1 sur la variable\n");
		    $$=g_node_new((gpointer)AFFECTATION_INCR);
		    g_node_append($$,$1);
		}
		|
		variable_decimale TOK_DECREMENTATION TOK_FINSTR{
			printf("\t\t\tDecrementation de -1 sur la variable\n");
		    $$=g_node_new((gpointer)AFFECTATION_DECR);
		    g_node_append($$,$1);
		}
		|
		variable_booleenne TOK_AFFECT expression_booleenne TOK_FINSTR{
			/* $1 est la valeur du premier non terminal. Ici c'est la valeur du non terminal variable. $3 est la valeur du 2nd non terminal. */
			printf("\t\tAffectation sur la variable\n");
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				/* On cree une Variable et on lui affecte le type que nous connaissons et la valeur */
				var=malloc(sizeof(Variable));
				if(var!=NULL){
					var->type=strdup("booleen");
					var->value=$3;
					/* On l'insere dans la table de hachage (cle: <nom_variable> / valeur: <(type,valeur)>) */
					if(g_hash_table_insert(table_variable,g_node_nth_child($1,0)->data,var)){
    					$$=g_node_new((gpointer)AFFECTATIONB);
    					g_node_append($$,$1);
    					g_node_append($$,$3);
					}else{
					    fprintf(stderr,"ERREUR - PROBLEME CREATION VARIABLE !\n");
					    exit(-1); 
					}
				}else{
					fprintf(stderr,"ERREUR - PROBLEME ALLOCATION MEMOIRE VARIABLE !\n");
					exit(-1);
				}
			}else{
				$$=g_node_new((gpointer)AFFECTATION);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_booleenne TOK_AFFECT_ET expression_booleenne TOK_FINSTR{
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
				error_semantical=true;
			}else{
				$$=g_node_new((gpointer)AFFECTATION_ET);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_booleenne TOK_AFFECT_OU expression_booleenne TOK_FINSTR{
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
				error_semantical=true;
			}else{
				$$=g_node_new((gpointer)AFFECTATION_OU);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_texte TOK_AFFECT expression_texte TOK_FINSTR{
			/* $1 est la valeur du premier non terminal. Ici c'est la valeur du non terminal variable. $3 est la valeur du 2nd non terminal. */
			printf("\t\tAffectation sur la variable\n");
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				/* On cree une Variable et on lui affecte le type que nous connaissons et la valeur */
				var=malloc(sizeof(Variable));
				if(var!=NULL){
					var->type=strdup("texte");
					var->value=$3;
					/* On l'insere dans la table de hachage (cle: <nom_variable> / valeur: <(type,valeur)>) */
					if(g_hash_table_insert(table_variable,g_node_nth_child($1,0)->data,var)){
    					$$=g_node_new((gpointer)AFFECTATIONT);
    					g_node_append($$,$1);
    					g_node_append($$,$3);
					}else{
					    fprintf(stderr,"ERREUR - PROBLEME CREATION VARIABLE !\n");
					    exit(-1); 
					}
				}else{
					fprintf(stderr,"ERREUR - PROBLEME ALLOCATION MEMOIRE VARIABLE !\n");
					exit(-1);
				}
			}else{
				$$=g_node_new((gpointer)AFFECTATION);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		}
		|
		variable_texte TOK_AFFECT_PLUS expression_texte TOK_FINSTR{
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
			if(var==NULL){
				fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
				error_semantical=true;
			}else{
				$$=g_node_new((gpointer)AFFECTATIONT_CONCAT);
				g_node_append($$,$1);
				g_node_append($$,$3);
			}
		};

affichage:	TOK_AFFICHER expression_arithmetique TOK_FINSTR{
			printf("\t\tAffichage de la valeur de l'expression arithmetique\n");
			if(decimal($2)){
				$$=g_node_new((gpointer)AFFICHAGED);
				g_node_append($$,$2);
			}else{
				$$=g_node_new((gpointer)AFFICHAGEE);
				g_node_append($$,$2);
			}
		}
		|
		TOK_AFFICHER expression_booleenne TOK_FINSTR{
			printf("\t\tAffichage de la valeur de l'expression booleenne\n");
			$$=g_node_new((gpointer)AFFICHAGEB);
			g_node_append($$,$2);
		}
		|
		TOK_AFFICHER expression_texte TOK_FINSTR{
			printf("\t\tAffichage de la valeur de l'expression textuelle\n");
			$$=g_node_new((gpointer)AFFICHAGET);
			g_node_append($$,$2);
		};

suppression:	TOK_SUPPR variable_texte TOK_FINSTR{
					/* On recupere un pointeur vers la structure Variable */
					Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($2,0)->data);
					/* Si on a trouve un pointeur valable */
					if(var!=NULL){
						/* On verifie que le type est bien un entier - Inutile car impose a l'analyse syntaxique */
						if(strcmp(var->type,"texte")==0){
							printf("\t\t\tSuppression de la variable texte\n");
							$$=g_node_new((gpointer)SUPPRESSIONT);
							g_node_append($$,$2);
							/* suppression de la variable dans la table de hachage */
							printf("suppresion variable %s\n",(char*)g_node_nth_child($2,0)->data);
						    if(g_hash_table_remove(table_variable,(char*)g_node_nth_child($2,0)->data)){
						        printf("Variable supprimee !\n");
						    }else{
						        fprintf(stderr,"ERREUR - PROBLEME DE SUPPRESSION VARIABLE !\n");
						        exit(-1);
						    }
						}else{
							fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Type incompatible !\n",lineno);
							error_semantical=true;
						}
					/* Sinon on conclue que la variable n'a jamais ete declaree car absente de la table */
					}else{
						fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($2,0)->data);
						error_semantical=true;
					}
				}

expression_arithmetique:	TOK_ENTIER{
					printf("\t\t\tNombre entier : %ld\n",$1);
					/* Comme le token TOK_NOMBRE est de type entier et que on a type expression_arithmetique comme du texte, il nous faut convertir la valeur en texte. */
					int length=snprintf(NULL,0,"%ld",$1);
					char* str=malloc(length+1);
					snprintf(str,length+1,"%ld",$1);
					$$=g_node_new((gpointer)ENTIER);
					g_node_append_data($$,strdup(str));
					free(str);
				}
				|
				TOK_DECIMAL{
					printf("\t\t\tNombre decimal : %f\n",$1);
					/* Comme le token TOK_NOMBRE est de type entier et que on a type expression_arithmetique comme du texte, il nous faut convertir la valeur en texte. */
					int length=snprintf(NULL,0,"%f",$1);
					char* str=malloc(length+1);
					snprintf(str,length+1,"%f",$1);
					$$=g_node_new((gpointer)DECIMAL);
					g_node_append_data($$,strdup(str));
					free(str);
				}
				|
				variable_entiere{
					/* On recupere un pointeur vers la structure Variable */
					Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
					/* Si on a trouve un pointeur valable */
					if(var!=NULL){
						/* On verifie que le type est bien un entier ou un decimal - Inutile car impose a l'analyse syntaxique */
						if(strcmp(var->type,"entier")==0){
							$$=$1;
						}else{
							fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Type incompatible (entier attendu - valeur : %s) !\n",lineno,(char*)g_node_nth_child($1,0)->data);
							error_semantical=true;
						}
					/* Sinon on conclue que la variable n'a jamais ete declaree car absente de la table */
					}else{
						fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
						error_semantical=true;
					}
				}
				|
				variable_decimale{
					/* On recupere un pointeur vers la structure Variable */
					Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
					/* Si on a trouve un pointeur valable */
					if(var!=NULL){
						/* On verifie que le type est bien un entier ou un decimal - Inutile car impose a l'analyse syntaxique */
						if(strcmp(var->type,"decimal")==0){
							$$=$1;
						}else{
							fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Type incompatible (decimal attendu - valeur : %s) !\n",lineno,(char*)g_node_nth_child($1,0)->data);
							error_semantical=true;
						}
					/* Sinon on conclue que la variable n'a jamais ete declaree car absente de la table */
					}else{
						fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
						error_semantical=true;
					}
				}
				|
				addition{
					$$=$1;
				}
				|
				soustraction{
					$$=$1;
				}
				|
				multiplication{
					$$=$1;
				}
				|
				division{
					$$=$1;
				}
				|
				modulo{
					$$=$1;
				}
				|
				TOK_PLUS expression_arithmetique{
				    $$=$2;
				}
				|
				expression_arithmetique TOK_INCREMENTATION{
					printf("\t\t\tIncrementation de +1\n");
				    $$=g_node_new((gpointer)INCREMENTATION);
				    g_node_append($$,$1);
				}
				|
				expression_arithmetique TOK_DECREMENTATION{
					printf("\t\t\tDecrementation de -1\n");
				    $$=g_node_new((gpointer)DECREMENTATION);
				    g_node_append($$,$1);
				}
				|
				TOK_MOINS expression_arithmetique{
				    printf("\t\t\tOperation unaire negation\n");
				    $$=g_node_new((gpointer)NEGATIF);
					g_node_append($$,$2);
				}
				|
				TOK_PARG expression_arithmetique TOK_PARD{
					printf("\t\t\tC'est une expression arithmetique entre parentheses\n");
					$$=g_node_new((gpointer)EXPR_PAR);
					g_node_append($$,$2);
				};

expression_booleenne:		TOK_VRAI{
					printf("\t\t\tBooleen Vrai\n");
					$$=g_node_new((gpointer)VRAI);
				}
				|
				TOK_FAUX{
					printf("\t\t\tBooleen Faux\n");
					$$=g_node_new((gpointer)FAUX);
				}
				|
				variable_booleenne{
					/* On recupere un pointeur vers la structure Variable */
					Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
					/* Si on a trouve un pointeur valable */
					if(var!=NULL){
						/* On verifie que le type est bien un entier - Inutile car impose a l'analyse syntaxique */
						if(strcmp(var->type,"booleen")==0){
							$$=$1;
						}else{
							fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Type incompatible (booleen attendu - valeur : %s) !\n",lineno,(char*)g_node_nth_child($1,0)->data);
							error_semantical=true;
						}
					/* Sinon on conclue que la variable n'a jamais ete declaree car absente de la table */
					}else{
						fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
						error_semantical=true;
					}
				}
				|
				TOK_NON expression_booleenne{
					printf("\t\t\tOperation booleenne Non\n");
					$$=g_node_new((gpointer)NON);
					g_node_append($$,$2);
				}
				|
				expression_booleenne TOK_ET expression_booleenne{
					printf("\t\t\tOperation booleenne Et\n");
					$$=g_node_new((gpointer)ET);
					g_node_append($$,$1);
					g_node_append($$,$3);
				}
				|
				expression_booleenne TOK_OU expression_booleenne{
					printf("\t\t\tOperation booleenne Ou\n");
					$$=g_node_new((gpointer)OU);
					g_node_append($$,$1);
					g_node_append($$,$3);
				}
				|
				TOK_PARG expression_booleenne TOK_PARD{
					printf("\t\t\tC'est une expression booleenne entre parentheses\n");
					$$=g_node_new((gpointer)EXPR_PAR);
					g_node_append($$,$2);
				}
				|
				expression_booleenne TOK_EQU expression_booleenne{
					printf("\t\t\tOperateur d'egalite ==\n");
					$$=g_node_new((gpointer)EGALITE);
					g_node_append($$,$1);
					g_node_append($$,$3);
				}
				|
				expression_booleenne TOK_DIFF expression_booleenne{
					printf("\t\t\tOperateur d'inegalite !=\n");
					$$=g_node_new((gpointer)DIFFERENT);
					g_node_append($$,$1);
					g_node_append($$,$3);
				}
				|
				expression_arithmetique TOK_EQU expression_arithmetique{
					printf("\t\t\tOperateur d'egalite ==\n");
					$$=g_node_new((gpointer)EGALITE);
					g_node_append($$,$1);
					g_node_append($$,$3);
				}
				|
				expression_arithmetique TOK_DIFF expression_arithmetique{
					printf("\t\t\tOperateur d'inegalite !=\n");
					$$=g_node_new((gpointer)DIFFERENT);
					g_node_append($$,$1);
					g_node_append($$,$3);
				}
				|
				expression_arithmetique TOK_SUP expression_arithmetique{
					printf("\t\t\tOperateur de superiorite >\n");
					$$=g_node_new((gpointer)SUPERIEUR);
					g_node_append($$,$1);
					g_node_append($$,$3);
				}
				|
				expression_arithmetique TOK_INF expression_arithmetique{
					printf("\t\t\tOperateur d'inferiorite <\n");
					$$=g_node_new((gpointer)INFERIEUR);
					g_node_append($$,$1);
					g_node_append($$,$3);
				}
				|
				expression_arithmetique TOK_SUPEQU expression_arithmetique{
					printf("\t\t\tOperateur >=\n");
					$$=g_node_new((gpointer)SUPEGAL);
					g_node_append($$,$1);
					g_node_append($$,$3);
				}
				|
				expression_arithmetique TOK_INFEQU expression_arithmetique{
					printf("\t\t\tOperateur <=\n");
					$$=g_node_new((gpointer)INFEGAL);
					g_node_append($$,$1);
					g_node_append($$,$3);
				}
				|
                expression_arithmetique TOK_IN TOK_CROG expression_arithmetique TOK_FINSTR expression_arithmetique TOK_CROD{
					printf("\t\t\tOperateur dans\n");
					$$=g_node_new((gpointer)DANSII);
					g_node_append($$,$1);
					g_node_append($$,$4);
					g_node_append($$,$6);
				}
				|
                expression_arithmetique TOK_IN TOK_CROD expression_arithmetique TOK_FINSTR expression_arithmetique TOK_CROD{
					printf("\t\t\tOperateur dans\n");
					$$=g_node_new((gpointer)DANSEI);
					g_node_append($$,$1);
					g_node_append($$,$4);
					g_node_append($$,$6);
				}
				|
                expression_arithmetique TOK_IN TOK_CROG expression_arithmetique TOK_FINSTR expression_arithmetique TOK_CROG{
					printf("\t\t\tOperateur dans\n");
					$$=g_node_new((gpointer)DANSIE);
					g_node_append($$,$1);
					g_node_append($$,$4);
					g_node_append($$,$6);
				}
				|
                expression_arithmetique TOK_IN TOK_CROD expression_arithmetique TOK_FINSTR expression_arithmetique TOK_CROG{
					printf("\t\t\tOperateur dans\n");
					$$=g_node_new((gpointer)DANSEE);
					g_node_append($$,$1);
					g_node_append($$,$4);
					g_node_append($$,$6);
				};

expression_texte:	TOK_TEXTE{
						printf("\t\t\tTexte %s\n",$1);
						$$=g_node_new((gpointer)TEXTE);
						g_node_append_data($$,strdup($1));
					}
					|
					variable_texte{
						/* On recupere un pointeur vers la structure Variable */
						Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child($1,0)->data);
						/* Si on a trouve un pointeur valable */
						if(var!=NULL){
							/* On verifie que le type est bien un entier - Inutile car impose a l'analyse syntaxique */
							if(strcmp(var->type,"texte")==0){
								$$=$1;
							}else{
								fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Type incompatible (texte attendu - valeur : %s) !\n",lineno,(char*)g_node_nth_child($1,0)->data);
								error_semantical=true;
							}
						/* Sinon on conclue que la variable n'a jamais ete declaree car absente de la table */
						}else{
							fprintf(stderr,"\tERREUR : Erreur de semantique a la ligne %d. Variable %s jamais declaree !\n",lineno,(char*)g_node_nth_child($1,0)->data);
							error_semantical=true;
						}
					};

addition:	expression_arithmetique TOK_PLUS expression_arithmetique{
    			printf("\t\t\tAddition\n");
    			$$=g_node_new((gpointer)ADDITION);
    			g_node_append($$,$1);
    			g_node_append($$,$3);
    		};

soustraction:	expression_arithmetique TOK_MOINS expression_arithmetique{
        			printf("\t\t\tSoustraction\n");
        			$$=g_node_new((gpointer)SOUSTRACTION);
        			g_node_append($$,$1);
        			g_node_append($$,$3);
        		};

multiplication:	expression_arithmetique TOK_MUL expression_arithmetique{
			printf("\t\t\tMultiplication\n");
			$$=g_node_new((gpointer)MULTIPLICATION);
			g_node_append($$,$1);
			g_node_append($$,$3);
		};

division:	expression_arithmetique TOK_DIV expression_arithmetique{
				printf("\t\t\tDivision\n");
				$$=g_node_new((gpointer)DIVISION);
				g_node_append($$,$1);
				g_node_append($$,$3);
			};

modulo:		expression_arithmetique TOK_MOD expression_arithmetique{
				printf("\t\t\tModulo\n");
				$$=g_node_new((gpointer)MODULO);
				g_node_append($$,$1);
				g_node_append($$,$3);
			};

%%

/* Dans la fonction main on appelle bien la routine yyparse() qui sera genere par Bison. Cette routine appellera yylex() de notre analyseur lexical. */

int main(int argc, char** argv){
	/* recuperation du nom de fichier d'entree (langage Simple) donne en parametre */
	char* fichier_entree=strdup(argv[1]);
	/* ouverture du fichier en lecture dans le flux d'entree stdin */
	stdin=fopen(fichier_entree,"r");
	/* creation fichier de sortie (langage C) */
	char* fichier_sortie=strdup(argv[1]);
	/* remplace l'extension par .c */
	strcpy(rindex(fichier_sortie, '.'), ".c");
	/* ouvre le fichier cree en ecriture */
	fichier=fopen(fichier_sortie, "w");
	/* Creation de la table de hachage */
	table_variable=g_hash_table_new_full(g_str_hash,g_str_equal,NULL,free);
	printf("Debut de l'analyse syntaxique :\n");
	debut_code();
	yyparse();
	fin_code();
	printf("Fin de l'analyse !\n");	
	printf("Resultat :\n");
        if(error_lexical){
                printf("\t-- Echec : Certains lexemes ne font pas partie du lexique du langage ! --\n");
		printf("\t-- Echec a l'analyse lexicale --\n");
        }
        else{
                printf("\t-- Succes a l'analyse lexicale ! --\n");
        }
	if(error_syntaxical){
                printf("\t-- Echec : Certaines phrases sont syntaxiquement incorrectes ! --\n");
		printf("\t-- Echec a l'analyse syntaxique --\n");
        }
        else{
                printf("\t-- Succes a l'analyse syntaxique ! --\n");
		if(error_semantical){
		        printf("\t-- Echec : Certaines phrases sont semantiquement incorrectes ! --\n");
			printf("\t-- Echec a l'analyse semantique --\n");
		}
		else{
		        printf("\t-- Succes a l'analyse semantique ! --\n");
		}
        }
	/* Suppression du fichier genere si erreurs analyse */
	if(error_lexical||error_syntaxical||error_semantical){
		remove(fichier_sortie);
		printf("ECHEC GENERATION CODE !\n");
	}
	else{
		printf("Le fichier \"%s\" a ete genere !\n",fichier_sortie);
	}
	/* Fermeture des flux */
	fclose(fichier);
	fclose(stdin);
	/* Liberation memoire */
	free(fichier_entree);
	free(fichier_sortie);
	g_hash_table_destroy(table_variable);
	return EXIT_SUCCESS;
}

void yyerror(char *s) {
        fprintf(stderr, "Erreur de syntaxe a la ligne %d: %s\n", lineno, s);
}

/* Cette fonction supprime dans la table de hachage toutes les variables declarees pour la premiere fois dans l'arbre syntaxique donne en parametre */

void supprime_variable(GNode* ast){
    /* si l'element n'est pas NULL et que ce n'est pas une feuille et que ce n'est pas un type bloc code (pour eviter de supprimer une variable deja suprimee) */
    if(ast&&!G_NODE_IS_LEAF(ast)&&(long)ast->data!=BLOC_CODE){
        /* si le noeud est de type declaration */
        if((long)ast->data==AFFECTATIONB||(long)ast->data==AFFECTATIONE|(long)ast->data==AFFECTATIONT|(long)ast->data==AFFECTATIOND){
            /* suppression de la variable dans la table de hachage */
            if(g_hash_table_remove(table_variable,(char*)g_node_nth_child(g_node_nth_child(ast,0),0)->data)){
                printf("Variable supprimee !\n");
            }else{
                fprintf(stderr,"ERREUR - PROBLEME DE SUPPRESSION VARIABLE !\n");
                exit(-1);
            }
        /* sinon on continue de parcourir l'arbre */
        }else{
            int nb_enfant;
            for(nb_enfant=0;nb_enfant<=g_node_n_children(ast);nb_enfant++){
                supprime_variable(g_node_nth_child(ast,nb_enfant));
            }
        }
    }
}

/* Cette fonction dit si un arbre contient un decimal */

bool decimal(GNode* ast){
    /* si l'element n'est pas NULL et que ce n'est pas une feuille et que ce n'est pas un type bloc code (pour eviter de supprimer une variable deja suprimee) */
    bool nbdecimal=false;
    if(ast&&!G_NODE_IS_LEAF(ast)){
        /* si le noeud est de type decimal */
        if((long)ast->data==DECIMAL){
            nbdecimal=true;
        /* si le noeud est une variable */
        }else if((long)ast->data==VARIABLE){
        	/* On recupere un pointeur vers la structure Variable */
			Variable* var=g_hash_table_lookup(table_variable,(char*)g_node_nth_child(ast,0)->data);
			/* Si on a trouve un pointeur valable */
			if(var!=NULL){
				/* On regarde si le type de la variable est un decimal */
				if(strcmp(var->type,"decimal")==0)
					nbdecimal=true;	
			}
        /* sinon on continue de parcourir l'arbre */
        }else{
            int nb_enfant;
            for(nb_enfant=0;nb_enfant<=g_node_n_children(ast);nb_enfant++){
                nbdecimal|=decimal(g_node_nth_child(ast,nb_enfant));
            }
        }
    }
    return nbdecimal;
}
