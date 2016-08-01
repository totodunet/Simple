# Simple
A compiler which converts Simple code (Simple is a pseudo-language) into C code.

Simple is a pseudo-language with as main goal to be easy to use. It illustrates my tutorial (written in French language) about the compiling :
http://totodu.net/Compilation/

Simple is developped with these tools : Flex (Fast lexical analyzer), Bison (Syntaxical analyzer) and GLib-2.0

To use the compiler and develop in Simple, we have to compile the compiler :

## 1st step : Compile the lexical analyzer

```bash
flex -o lexique_simple.c lexique_simple.lex
```

## 2nd step : Compile the syntaxical and semantical analyzer

```bash
bison -d syntaxe_simple.y
```

## 3rd step : Build the final compiler

```bash
gcc lexique_simple.c syntaxe_simple.tab.c generation_code.c `pkg-config --cflags --libs glib-2.0` -o simple
```

## Test

Here an example of program written in Simple language :

```
//affichage d'une chaine de texte
afficher "Bonjour le monde ! (oui on est en France ici, pas de Hallo Welt !!)\n";

//affectation de la variable texte
tphrase_de_thomas="Thomas a dit :

\"J'aime bien la science-fiction et les dessins animés Disney !\".

Mais voilà on s'en fiche un peu...

";

//affiche la variable texte
afficher tphrase_de_thomas;

//supprime la variable texte (libere la memoire) - la variable est desormais inutilisable en l'etat
supprimer tphrase_de_thomas;

<!--

AFFICHAGE DE LA TABLE DE MULTIPLICATION DE 1 A 10

-->

afficher "---------------------------------TABLE DE MULTIPLICATION---------------------------------\n";
afficher "|X\t1\t2\t3\t4\t5\t6\t7\t8\t9\t10\t|\n";
e_i=0;
(10)x
    e_j=0;
    e_i++;
    afficher "|";
    afficher e_i;
    (10)x
        e_j++;
        afficher "\t";
        afficher e_i*e_j;
    ;
    e_j++;
    afficher "\t|\n";
;
afficher "-----------------------------------------------------------------------------------------\n";
```

```bash
./simple input_file.simple
```

The following file is generated by the compiler :

```c
/* FICHIER GENERE PAR LE COMPILATEUR SIMPLE */

#include<stdlib.h>
#include<stdbool.h>
#include<stdio.h>
#include<string.h>

int main(void){
	printf("%s","Bonjour le monde ! (oui on est en France ici, pas de Hallo Welt !!)\n");
	char* tphrase_de_thomas=malloc(sizeof(char)*strlen("Thomas a dit :\n\n\"J'aime bien la science-fiction et les dessins animés Disney !\".\n\nMais voilà on s'en fiche un peu...\n\n"));
	if(tphrase_de_thomas==NULL){
	printf("Erreur d'allocation memoire sur la variable tphrase_de_thomas !");
	exit(-1);
}
	strcpy(tphrase_de_thomas,"Thomas a dit :\n\n\"J'aime bien la science-fiction et les dessins animés Disney !\".\n\nMais voilà on s'en fiche un peu...\n\n");
	printf("%s",tphrase_de_thomas);
	free(tphrase_de_thomas);
	printf("%s","---------------------------------TABLE DE MULTIPLICATION---------------------------------\n");
	printf("%s","|X\t1\t2\t3\t4\t5\t6\t7\t8\t9\t10\t|\n");
	int e_i=0;
	int i0;
	for(i0=0;i0<10;i0++){
	int e_j=0;
	e_i++;
	printf("%s","|");
	printf("%d",e_i);
	int i1;
	for(i1=0;i1<10;i1++){
	e_j++;
	printf("%s","\t");
	printf("%d",e_i*e_j);
	}
	e_j++;
	printf("%s","\t|\n");
	}
	printf("%s","-----------------------------------------------------------------------------------------\n");
	return EXIT_SUCCESS;
}
```

We recompile again the new file generated with a C compiler as gcc :

```bash
gcc input_file.c
```

and execute it :

```bash
./a.out
```

We can see the output :
```
Bonjour le monde ! (oui on est en France ici, pas de Hallo Welt !!)
Thomas a dit :

"J'aime bien la science-fiction et les dessins animés Disney !".

Mais voilà on s'en fiche un peu...

---------------------------------TABLE DE MULTIPLICATION---------------------------------
|X      1       2       3       4       5       6       7       8       9       10      |
|1      1       2       3       4       5       6       7       8       9       10      |
|2      2       4       6       8       10      12      14      16      18      20      |
|3      3       6       9       12      15      18      21      24      27      30      |
|4      4       8       12      16      20      24      28      32      36      40      |
|5      5       10      15      20      25      30      35      40      45      50      |
|6      6       12      18      24      30      36      42      48      54      60      |
|7      7       14      21      28      35      42      49      56      63      70      |
|8      8       16      24      32      40      48      56      64      72      80      |
|9      9       18      27      36      45      54      63      72      81      90      |
|10     10      20      30      40      50      60      70      80      90      100     |
-----------------------------------------------------------------------------------------
```
