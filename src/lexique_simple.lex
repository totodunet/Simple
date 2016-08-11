%{

#include "simple.h"
unsigned int lineno=1;
bool error_lexical=false;

/* definition de la fonction de concatenation pour les chaines de texte */
void* concat(char*,char*);

%}

%option noyywrap

entier 0|[1-9][[:digit:]]*
decimal {entier}\.{entier}
variable_booleenne b(_|[[:alnum:]])*
variable_entiere e(_|[[:alnum:]])*
variable_decimale d(_|[[:alnum:]])*
variable_texte t(_|[[:alnum:]])*

/* regex de commentaire d'une seule ligne */
commentaire ((\/\/|#).*)

/* pour les commentaires de plusieurs lignes, on declare nos deux lexemes en tant que conditions de demarrage exclusives (%x) dans Flex */
%x  commentaire_1
%x  commentaire_2

/* chaine de caractere */
%x  chaine

%%

"/*"    {
            /* un marqueur de debut de commentaire trouve -> on lui dit que le lexeme commentaire_1 commence */
            BEGIN(commentaire_1);
            printf("Commentaire detecte en ligne %i\n",lineno);
        }

<commentaire_1>"\n"     {
                            /* si on trouve des retours chariots et que la condition de demarrage est commentaire_1, alors on incremente la variable lineno. sans cela, on serait en decalage pour la suite de l'analyse */
                            lineno++;
                        }

<commentaire_1>"*"+"/"      {
                                /* si on au moins une fois "*" suivi de "/" et que la condition de demarrage est commentaire_1, alors on lui dit que le lexeme commentaire_1 est fini */
                                BEGIN(INITIAL);
                                printf("Fin du commentaire en ligne %i\n",lineno);
                                return TOK_COMMENT;
                            }

<commentaire_1>.    {/* les autres caracteres suivants la conditions de demarrage sont absorbes par l'analyse est donc ingores */}

"<!--"      {
                BEGIN(commentaire_2);
                printf("Commentaire detecte en ligne %i\n",lineno);
            }
<commentaire_2>"\n"         {lineno++;}
<commentaire_2>"-"+"-"+">"  {
                                BEGIN(INITIAL);
                                printf("Fin du commentaire en ligne %i\n",lineno);
                                return TOK_COMMENT;
                            }
<commentaire_2>.            {}

"\""         {
                /* debut de la chaine de texte (premier guillemet) */
                BEGIN(chaine);
                yylval.texte=malloc(sizeof(char)*strlen(yytext));
                if(yylval.texte==NULL){
                    fprintf(stderr,"\tERREUR : Probleme de memoire sur une chaine texte a la ligne %i !\n",lineno);
                    exit(-1);
                }
                yylval.texte=strdup(yytext);
                printf("Chaine de texte detectee en ligne %i\n",lineno);
            }

<chaine>"\n"    {
                    /* on prend en compte les sauts de ligne que l'on traduira par "\n" */
                    lineno++;
                    yylval.texte=(char*)concat(yylval.texte,"\\n");
                    if(yylval.texte==NULL){
                        fprintf(stderr,"\tERREUR : Probleme de memoire sur une chaine texte a la ligne %i !\n",lineno);
                        exit(-1);
                    }
                }

<chaine>"\t"    {
                    /* on prend en compte les tabulations que l'on traduira par "\t" */
                    yylval.texte=(char*)concat(yylval.texte,"\\t");
                    if(yylval.texte==NULL){
                        fprintf(stderr,"\tERREUR : Probleme de memoire sur une chaine texte a la ligne %i !\n",lineno);
                        exit(-1);
                    }
                }

<chaine>"\\\""    {
                    /* pour echapper le guillemet dans la chaine \" */
                    yylval.texte=(char*)concat(yylval.texte,yytext);
                    if(yylval.texte==NULL){
                        fprintf(stderr,"\tERREUR : Probleme de memoire sur une chaine texte a la ligne %i !\n",lineno);
                        exit(-1);
                    }
                }

<chaine>"\""     {
                    /* fin de la chaine (deuxieme guillemet non echappe) */
                    BEGIN(INITIAL);
                    yylval.texte=(char*)concat(yylval.texte,yytext);
                    if(yylval.texte==NULL){
                        fprintf(stderr,"\tERREUR : Probleme de memoire sur une chaine texte a la ligne %i !\n",lineno);
                        exit(-1);
                    }
                    printf("Fin de la chaine en ligne %i\n",lineno);
                    return TOK_TEXTE;
                }

<chaine>.  {
                /* les caracteres de la chaine */
                yylval.texte=(char*)concat(yylval.texte,yytext);
                if(yylval.texte==NULL){
                        fprintf(stderr,"\tERREUR : Probleme de memoire sur une chaine texte a la ligne %i !\n",lineno);
                        exit(-1);
                }
            }
            
{decimal} {
    sscanf(yytext, "%lf", &yylval.decimal);
    return TOK_DECIMAL;
}

{entier} {
    sscanf(yytext, "%ld", &yylval.entier);
    return TOK_ENTIER;
}

"si"    {return TOK_SI;}

"alors" {return TOK_ALORS;}

"sinon" {return TOK_SINON;}

"++"    {return TOK_INCREMENTATION;}

"--"    {return TOK_DECREMENTATION;}

"+="    {return TOK_AFFECT_PLUS;}

"-="    {return TOK_AFFECT_MOINS;}

"*="    {return TOK_AFFECT_MUL;}

"/="    {return TOK_AFFECT_DIV;}

"%="    {return TOK_AFFECT_MOD;}

"&="    {return TOK_AFFECT_ET;}

"|="    {return TOK_AFFECT_OU;}

"egal a"|"equivalent a"|"=="        {return TOK_EQU;}

"different de"|"!="|"<>"            {return TOK_DIFF;}

"superieur a"|"plus grand que"|">"  {return TOK_SUP;}

"inferieur a"|"plus petit que"|"<"  {return TOK_INF;}

"superieur ou egal a"|">="          {return TOK_SUPEQU;}

"inferieur ou egal a"|"<="          {return TOK_INFEQU;}

"compris dans"|"dans"               {return TOK_IN;}

"afficher"      {return TOK_AFFICHER;}

"supprimer"     {return TOK_SUPPR;}

"faire"         {return TOK_FAIRE;}

"x"             {return TOK_CROIX;}

"="             {return TOK_AFFECT;}

"+"             {return TOK_PLUS;}

"-"             {return TOK_MOINS;}

"*"             {return TOK_MUL;}

"/"             {return TOK_DIV;}

"%"             {return TOK_MOD;}

"^"             {return TOK_PUISSANCE;}

"("             {return TOK_PARG;}

")"             {return TOK_PARD;}

"["             {return TOK_CROG;}

"]"             {return TOK_CROD;}

"?"             {return TOK_POINT_INTERROGATION;}

":"             {return TOK_DOUBLE_POINT;}

"et"            {return TOK_ET;}

"ou"            {return TOK_OU;}

"non"|"!"           {return TOK_NON;}

";"             {return TOK_FINSTR;}

"vrai"          {return TOK_VRAI;}

"faux"          {return TOK_FAUX;}

"\n"            {lineno++;}

{variable_booleenne} {
    yylval.texte = yytext;
    return TOK_VARB;
}


{variable_entiere} {
    yylval.texte = yytext;
    return TOK_VARE;
}

{variable_decimale} {
    yylval.texte = yytext;
    return TOK_VARD;
}

{variable_texte} {
    yylval.texte = yytext;
    return TOK_VART;
}

{commentaire}   {
    printf("Commentaire detecte en ligne %i\n",lineno);
    printf("Fin du commentaire en ligne %i\n",lineno);
    return TOK_COMMENT;
}

" "|"\t" {}

. {
    fprintf(stderr,"\tERREUR : Lexeme inconnu a la ligne %d. Il s'agit de %s et comporte %d lettre(s)\n",lineno,yytext,yyleng);
    error_lexical=true;
    return yytext[0];
}

%%

/* fonction de concatenation - realloue la memoire a la variable texte dimensionne a la taille memoire du tableau de char ajout puis concatene */

void* concat(char* texte, char* ajout){
    void* p=NULL;
    /* realloue la memoire -> taille de texte + taille de ajout + 1 (caractere de fin \0) */
    if((p=realloc(texte,sizeof(char)*(strlen(texte)+strlen(ajout)+1)))){
        texte=p;
        return strcat(texte,ajout);
    }else{
        /* appel de la macro FREE pour liberer correctement la memoire */
        FREE(texte);
        return NULL;
    }
}
