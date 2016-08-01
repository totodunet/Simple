#include "simple.h"

unsigned int nb_boucle=0;

void debut_code(){
	fprintf(fichier, "/* FICHIER GENERE PAR LE COMPILATEUR SIMPLE */\n\n");
	fprintf(fichier, "#include<stdlib.h>\n#include<stdbool.h>\n#include<stdio.h>\n#include<string.h>\n\n");
	fprintf(fichier, "int main(void){\n");
}

void fin_code(){
	fprintf(fichier, "\treturn EXIT_SUCCESS;\n");
	fprintf(fichier, "}\n");
}

void genere_code(GNode* ast){
	if(ast){
		switch((long)ast->data){
			case SEQUENCE:
				genere_code(g_node_nth_child(ast,0));
				genere_code(g_node_nth_child(ast,1));
				break;
			case VARIABLE:
				fprintf(fichier,"%s",(char*)g_node_nth_child(ast,0)->data);
				break;
			case AFFECTATIONE:
				fprintf(fichier,"\tint ");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"=");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,";\n");
				break;
			case AFFECTATIONB:
				fprintf(fichier,"\tbool ");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"=");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,";\n");
				break;
			case AFFECTATION:
				fprintf(fichier,"\t");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"=");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,";\n");
				break;
			case AFFECTATION_PLUS:
				fprintf(fichier,"\t");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"+=");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,";\n");
				break;
			case AFFECTATION_MOINS:
				fprintf(fichier,"\t");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"-=");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,";\n");
				break;
			case AFFECTATION_MUL:
				fprintf(fichier,"\t");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"*=");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,";\n");
				break;
			case AFFECTATION_DIV:
				fprintf(fichier,"\t");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"/=");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,";\n");
				break;
			case AFFECTATION_MOD:
				fprintf(fichier,"\t");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"%%=");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,";\n");
				break;
			case AFFECTATION_ET:
				fprintf(fichier,"\t");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"&=");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,";\n");
				break;
			case AFFECTATION_OU:
				fprintf(fichier,"\t");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"|=");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,";\n");
				break;
			case AFFECTATION_INCR:
				fprintf(fichier,"\t");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"++;\n");
				break;
			case AFFECTATION_DECR:
				fprintf(fichier,"\t");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"--;\n");
				break;
			case AFFICHAGEE:
				fprintf(fichier,"\tprintf(\"%%d\",");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,");\n");
				break;
			case AFFICHAGEB:
				fprintf(fichier,"\tprintf(\"%%s\",");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"?\"vrai\":\"faux\");\n");
				break;
			case ENTIER:
				fprintf(fichier,"%s",(char*)g_node_nth_child(ast,0)->data);
				break;
			case ADDITION:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"+");
				genere_code(g_node_nth_child(ast,1));
				break;
			case SOUSTRACTION:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"-");
				genere_code(g_node_nth_child(ast,1));
				break;
			case MULTIPLICATION:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"*");
				genere_code(g_node_nth_child(ast,1));
				break;
			case DIVISION:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"/");
				genere_code(g_node_nth_child(ast,1));
				break;
			case MODULO:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"%%");
				genere_code(g_node_nth_child(ast,1));
				break;
			case INCREMENTATION:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"+1");
				break;
			case DECREMENTATION:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"-1");
				break;
			case VRAI:
				fprintf(fichier,"true");
				break;
			case FAUX:
				fprintf(fichier,"false");
				break;
			case ET:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"&&");
				genere_code(g_node_nth_child(ast,1));
				break;
			case OU:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"||");
				genere_code(g_node_nth_child(ast,1));
				break;
			case NON:
				fprintf(fichier,"!");
				genere_code(g_node_nth_child(ast,0));
				break;
			case EXPR_PAR:
				fprintf(fichier,"(");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,")");
				break;
			case EGALITE:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"==");
				genere_code(g_node_nth_child(ast,1));
				break;
			case DIFFERENT:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"!=");
				genere_code(g_node_nth_child(ast,1));
				break;
			case INFERIEUR:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"<");
				genere_code(g_node_nth_child(ast,1));
				break;
			case SUPERIEUR:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,">");
				genere_code(g_node_nth_child(ast,1));
				break;
			case INFEGAL:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"<=");
				genere_code(g_node_nth_child(ast,1));
				break;
			case SUPEGAL:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,">=");
				genere_code(g_node_nth_child(ast,1));
				break;
			case DANSII:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,">=");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,"&&");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"<=");
				genere_code(g_node_nth_child(ast,2));
				break;
			case DANSEI:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,">");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,"&&");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"<=");
				genere_code(g_node_nth_child(ast,2));
				break;
			case DANSIE:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,">=");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,"&&");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"<");
				genere_code(g_node_nth_child(ast,2));
				break;
			case DANSEE:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,">");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,"&&");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"<");
				genere_code(g_node_nth_child(ast,2));
				break;
			case NEGATIF:
				fprintf(fichier,"-");
				genere_code(g_node_nth_child(ast,0));
				break;
			case CONDITION_SI:
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"\n");
				break;
			case CONDITION_SI_SINON:
				genere_code(g_node_nth_child(ast,0));
				genere_code(g_node_nth_child(ast,1));
				break;
			case SI:
				fprintf(fichier,"\tif(");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"){\n");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,"\t}");
				break;
			case SINON:
				fprintf(fichier,"else{\n");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"\t}\n");
				break;
			case BOUCLE_FOR:
				fprintf(fichier,"\tint i%i;\n\tfor(i%i=0;i%i<",nb_boucle,nb_boucle,nb_boucle);
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,";i%i++){\n",nb_boucle);
				nb_boucle++;
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,"\t}\n");
				break;
			case BOUCLE_WHILE:
				fprintf(fichier,"\twhile(");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"){\n");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,"\t}\n");
				break;
			case BOUCLE_DO_WHILE:
				fprintf(fichier,"\tdo{\n");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"\t}while(");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,");\n");
				break;
			case BLOC_CODE:
				genere_code(g_node_nth_child(ast,0));
				break;
			case AFFICHAGET:
				fprintf(fichier,"\tprintf(\"%%s\",");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,");\n");
				break;
			case TEXTE:
				fprintf(fichier,"%s",(char*)g_node_nth_child(ast,0)->data);
				break;
			case AFFECTATIONT:
				fprintf(fichier,"\tchar* ");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"=malloc(sizeof(char)*strlen(");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,"));\n");
				fprintf(fichier,"\tif(");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,"==NULL){\n");
				fprintf(fichier,"\tprintf(\"Erreur d'allocation memoire sur la variable ");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier," !\");\n\texit(-1);\n}\n\t");
				fprintf(fichier,"strcpy(");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,",");
				genere_code(g_node_nth_child(ast,1));
				fprintf(fichier,");\n");
				break;
			case SUPPRESSIONT:
				fprintf(fichier,"\tfree(");
				genere_code(g_node_nth_child(ast,0));
				fprintf(fichier,");\n");
				break;
		}
	}
}
