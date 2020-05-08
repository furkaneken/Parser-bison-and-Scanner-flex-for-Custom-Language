%{
#define YYSTYPE char *
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
extern FILE *yyin;

void yyerror (const char *s) 
{
	printf ("%s\n", s); 
}
char global[100][200];
char local[100][200];
int globalindex = 0;
int localindex = 0;
bool globalbool = true;
int yylex();
%}
%locations
%token tINTVAL EOE tINT tSTRING tRETURN tPRINT tLPAR tRPAR tCOMMA tMOD tASSIGNM tMINUS tPLUS tDIV tSTAR tSEMI tLBRAC tRBRAC tSTRINGVAL tIDENT tNL


%left tASSIGNM
%left tSEMI
%left tPLUS tMINUS
%left tSTAR tDIV tMOD
%left tLPAR tRPAR
%start prog

%%

prog: 		stmtlst
;
stmtlst:	stmtlst stmt 
			| stmt
;

stmt:       decl
            | assign
            | funccall
 	    | func
	    | print 
;
expr:		value   
            | expr	tSTAR expr
            | expr	tDIV expr
            | expr	tPLUS expr
            | expr	tMINUS expr
	    |expr tMOD expr
	    |funccall    
;   

decl:	type vars2 tASSIGNM expr tSEMI 
;

vars2 : tIDENT ',' vars2
	| tIDENT { 
char ident[50];
strcpy(ident , $1);  
bool check = false;
bool check2 = false;
for(int x=0; x < globalindex +1 ; x++)   
{
	if(strcmp(ident, global[x]) == 0)
	{
		extern int yylineno;
		printf("%d Redefinition of variable  \n" , yylineno );
		check = true;
		exit(1);

	}
}
if(check == false)
{
for(int x=0; x < localindex +1 ; x++)
{
	if(strcmp(ident, local[x]) == 0)  
	{
		extern int yylineno;
		printf("%d Redefinition of variable \n" , yylineno);
		check2 = true;
		exit(2);

	}
}

}
if(check == false && check2 == false)
{
	if(globalbool)
	{
		strcpy(global[globalindex] , ident); 
		globalindex++;
	}
	else
	{
		strcpy(local[localindex], ident);
		localindex++;
	}


}



}
;

type : tINT
	| tSTRING
;
funccall : tIDENT tLPAR vars tRPAR
;
value : tINTVAL
	| tSTRINGVAL
	| tIDENT { 
char ident[50];
strcpy(ident , $1);
bool fine = false;
bool check = false;
bool check2 = false;
for(int x=0; x < globalindex +1 ; x++)       
{
	if(strcmp(ident, global[x]) == 0)
	{
		fine = true;
		check = true;
		

	}
}
if(check == false)
{
for(int x=0; x < localindex +1 ; x++)
{
	if(strcmp(ident, local[x]) == 0)
	{
		fine = true;
		
	}
}

}
if(!fine)
{
extern int yylineno;
printf("%d Undefined variable  \n" ,yylineno);
exit(3);
}

}
;
vars:		expr ',' vars
			| expr

;
assign : vars tASSIGNM expr tSEMI
;
func : type tIDENT tLPAR params tRPAR  globalsem body return globalsemoff
;

globalsem : tLBRAC { globalbool = false;}
;
globalsemoff :  tRBRAC {	globalbool = true; localindex = 0;
for(int j = 0; j < 100; j++)
	{
   		for(int i = 0; i < 200; i++)
    		{  
        		local[j][i] = '\0';
    		}
	}




}
;
	
body  : decl body
	| assign body
	| print body
	| decl
	|assign
	|print
; 
return : tRETURN expr tSEMI
;
params : params ',' type tIDENT
	| type tIDENT
;

print :	tPRINT tLPAR expr tRPAR tSEMI
;


%%
int main ()
{
   if (yyparse()) {
   // parse error
       printf("ERROR\n");
       return 1;
   }
   else {
   // successful parsing
      printf("OK\n");
      return 0;
   }
}