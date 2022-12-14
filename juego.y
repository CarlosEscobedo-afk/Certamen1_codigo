%{
/*
	[S,I,R,D] [S,I,R,D] [S,I,R,D]
	S = Susceptibles
	I = Infectados
	R = Recuperados
	D = Muertos
	
	sus_to_inf = probabilidad de que los susceptibles se infecten
	inf_to_dead = probabilidad de que los infectados mueran cada iteracion
	inf_to_rec = cantidad de iteraciones para que los infectados se recuperen
	rec_to_sus = cantidad de iteraciones para que los recuperados sean susceptibles otra vez
	
	MATRIZ CONe POBLACIONES:
	   
	["100,1,1,20"] ["100,1,1,20"] ["100,1,1,20"]
	["100,1,1,20"] ["100,1,1,20"] ["100,1,1,20"]
	["100,1,1,20"] ["100,1,1,20"] ["100,1,1,20"]
*/
// Esta función define la estructura de la grilla que se utilizará en todo el código:
#include <cstdio>
#include <algorithm>
#include <iterator>
#include <cstring>
#include <iostream>
#include <cstdlib>
#include <vector>
#include <sstream>
#include <string>
#include <cmath>
extern int yylex();
extern int yyparse();
extern FILE* yyin;
using namespace std;
void yyerror(const char* s);


int ancho, largo, var, inf_to_rec, rec_to_sus, condicion, posx,posy;
float sus_to_inf, inf_to_dead;

typedef struct estructuraGrilla {
    string **casilla; //Array de posiciones
    unsigned int ancho;
    unsigned int largo;
} estructuraGrilla;

estructuraGrilla grilla;



// Split
vector<string> split(string str, vector<string> vec){
    string token;
    stringstream ss(str);
    while (getline(ss, token, ',')){
        vec.push_back(token);
    }
    return vec;
}
// Esta función permite recorrer cada casilla de forma Von Neumann y calcular las reglas establecidas para el modelo SIRD en cada una de las casillas de la grilla:
string calcularCondiciones(estructuraGrilla &grilla, unsigned int i, unsigned int j, int iteracion, float sus_to_inf, float inf_to_dead, int inf_to_rec, int rec_to_sus) {
    vector<string> transit;
    transit = split(grilla.casilla[i][j], transit);
	float S = stof(transit[0]);
    float I = stof(transit[1]);
    float R = stof(transit[2]);
    float D = stof(transit[3]);
    float S2 = 0;
	float I2 = 0;
	float R2 = 0;
	float D2 = 0;
    
	int susceptible, recuperado = 0;
    if (iteracion % rec_to_sus == 0) {
		susceptible++;
	}
	if (iteracion % inf_to_rec == 0) {	
		recuperado++;
	}
	
	//INF to DEAD
	D2 = D + round(I*inf_to_dead);
	I2 = I - round(I*inf_to_dead);
	//INF to REC
	if(recuperado >= 1){
		recuperado--;
		R2 = R + I2;
		I2 = I2 - I2;
	}
	//SUS to INF
	I2 = I2 + round(S*sus_to_inf);
	S2 = S - round(S*sus_to_inf);
	//REC to SUS
	if(susceptible >= 1){
		susceptible--;
		S2 = S2 + R;
	}
	
	stringstream ss;
	ss << S2 << "," << I2 << "," << R2 << "," << D2;
	//cout << ss.str() << endl;
	return (grilla.casilla[i][j] = ss.str());
}

// Esta función inicia la grilla repleta de casillas susceptibles (S):
void iniciarGrilla(estructuraGrilla &grilla, unsigned int ancho, unsigned int largo) {
    unsigned int i, j;
    if (grilla.casilla != NULL) {
        for (unsigned short i=0;i<grilla.largo;i++){
            delete[] grilla.casilla[i];
        }
        delete[] grilla.casilla;
    }
    grilla.ancho = ancho;
    grilla.largo = largo;

    grilla.casilla = new string *[grilla.largo];
    for (i=0; i<grilla.largo; i++) {
        grilla.casilla[i] = new string[grilla.ancho];
        for (j=0; j<grilla.ancho; j++) {
            float S2 = 0;
	        float I2 = 0;
	        int valor_maximo = 0;
            S2 = 100 + rand() % 500;
            valor_maximo = 1 +round(S2 - S2 /2);
            I2 = 1 + rand() % valor_maximo;
            stringstream ss;
			ss << S2 << "," << I2 << "," << 0 << "," << 0;
            
            grilla.casilla[i][j] = ss.str();
            
        }
    }
}

// Esta función copia la grilla actual para utilizarla en la siguiente iteración:
void copiarGrilla(estructuraGrilla a, estructuraGrilla &b) {
    unsigned int i, j;
    for (i=0;i<a.largo;i<i++) {
        for (j=0;j<a.ancho;j++) {
            b.casilla[i][j] = a.casilla[i][j];
        }
    }
}

// Esta función permite iterar la grilla y llamar a la función con las condiciones:
void transcursoGrilla(estructuraGrilla &grilla, int iteracion, float sus_to_inf, float inf_to_dead, int inf_to_rec, int rec_to_sus) {
    estructuraGrilla grillaNuevo;
    grillaNuevo.casilla=NULL;
    iniciarGrilla(grillaNuevo, grilla.ancho, grilla.largo);
    copiarGrilla(grilla, grillaNuevo);
    
    unsigned int i, j;
    for (i=0; i<grilla.largo; i++) {
        for (j=0; j<grilla.ancho; j++) {
            grilla.casilla[i][j] = calcularCondiciones(grillaNuevo, i, j, iteracion, sus_to_inf, inf_to_dead, inf_to_rec, rec_to_sus);  
        }
    }
}

// Esta función muestra la grilla en pantalla:
void imprimirGrilla(estructuraGrilla &grilla){
    int i, j;
    for (i = 0; i < grilla.largo; i++) {
        for (j = 0; j < grilla.ancho; j++) {
            cout << grilla.casilla[i][j] << " | ";
            if (j == grilla.ancho - 1){
                cout << "" << endl;
            }
        }
    }
}

// Esta función carga la vista inicial de la grilla, ya sea un ejemplo o configuración manual:
void cargarInicial(estructuraGrilla &grilla, int ancho, int largo, int condicion) {
    iniciarGrilla(grilla, ancho, largo);
}

void casoEjemplo(){
    grilla.casilla = NULL;
	ancho = 10;
	largo = 10;
	sus_to_inf = 30;
	inf_to_dead = 5;
	inf_to_rec =5;
	rec_to_sus = 3;
	cargarInicial(grilla, ancho, largo, condicion);
	cout << endl << "Grilla inicial: " << endl;
    imprimirGrilla(grilla);	
    for (int i = 0; i < var; i++) {
        transcursoGrilla(grilla, i+1, sus_to_inf, inf_to_dead, inf_to_rec, rec_to_sus);
        cout << endl << "Iteracion: " << i+1 << endl;
        imprimirGrilla(grilla);
    }
}

void iniciarTodo(){
    grilla.casilla = NULL;
	sus_to_inf = sus_to_inf / 100;
	inf_to_dead = inf_to_dead / 100;
	cargarInicial(grilla, ancho, largo, condicion);
	cout << endl << "Grilla inicial: " << endl;
    imprimirGrilla(grilla);	
    for (int i = 0; i < var; i++) {
        transcursoGrilla(grilla, i+1, sus_to_inf, inf_to_dead, inf_to_rec, rec_to_sus);
        cout << endl << "Iteracion: " << i+1 << endl;
        imprimirGrilla(grilla);
    }
}


void mostrarCasilla(int pos1, int pos2) {
    estructuraGrilla grillaNuevo;
    grillaNuevo.casilla=NULL;
    iniciarGrilla(grillaNuevo, grilla.ancho, grilla.largo);
    copiarGrilla(grilla, grillaNuevo);
    //hay que pasarle la grilla actual
    vector<string> transit;
    transit = split(grilla.casilla[pos1][pos2], transit);
	float S = stof(transit[0]);
	float I = stof(transit[1]);
	float R = stof(transit[2]);
	float D = stof(transit[3]);
	cout << "Susceptibles: " << S << endl;
	cout << "Infectados: " << I << endl;
	cout << "Recuperados: " << R << endl;
	cout << "Muertos: " << D << endl;
	cout << "Total de Poblacion: " << S+I+R+D << endl;
}

void mostrarTasas(float sus_to_inf, float inf_to_dead, int inf_to_rec, int rec_to_sus) {
	cout << "Probabilidad de que los susceptibles (S) de una poblacion se infecten (I): " << sus_to_inf  << endl;
	cout << "Probabilidad de que los infectados (I) de una poblacion mueran (D): " << inf_to_dead << endl;
	cout << "Cantidad de dias (iteraciones) necesarios para que un infectado (I) pase a ser recuperado (R): " << inf_to_rec << endl;
	cout << "Cantidad de dias (iteraciones) necesarios para que un recuperado (R) pase a ser susceptible (S): " << rec_to_sus << endl;
}

%}

%union {
	int ival;
}

%token<ival> EJEC
%token LARGO ANCHO ITER FINLINEA EXIT ITER STOI ITOD ITOR RTOS EJEMPLO CARGAR MOSTRAR_CASILLA MOSTRAR_TASAS POSX POSY ESC1 ESC2 ESC3 
%start inicio
%type<ival> exp

%%

inicio:
	   | inicio linea
;
linea: FINLINEA
	| EXIT FINLINEA	{cout<<"Adios";exit(0);}
    | exp FINLINEA
;


exp: EJEC	
        | LARGO exp { largo = $2 ;cout << "Largo: " << largo<< "\n" <<endl;}
        | ANCHO exp { ancho = $2 ;cout << "Ancho: " << ancho << "\n"<<endl;}
		| ITER exp { var = $2 ;cout << "Iteraciones: " << var << "\n"<< endl;}
		| STOI exp { sus_to_inf = $2 ;cout << "Probabilidad de que los susceptibles (S) de una poblacion se infecten (I): " << sus_to_inf <<"%\n"<<endl;}
		| ITOD exp { inf_to_dead = $2 ;cout << "Probabilidad de que los infectados (I) de una poblacion mueran (D): " << inf_to_dead <<"%\n"<<endl;}
		| ITOR exp { inf_to_rec = $2 ;cout << "Cantidad de dias (iteraciones) necesarios para que un infectado (I) pase a ser recuperado (R): " << inf_to_rec <<"\n"<< endl;}
		| RTOS exp { rec_to_sus = $2 ;cout << "Cantidad de dias (iteraciones) necesarios para que un recuperado (R) pase a ser susceptible (S): " << rec_to_sus<<"\n" <<endl;}
		| POSX exp {posx = $2; cout << endl;}
        | POSY exp {posy = $2; cout << endl;}
        | EJEMPLO mostrar_ejemplo
        | CARGAR mostrar_carga
        | MOSTRAR_CASILLA mostrar_c
        | MOSTRAR_TASAS mostrar_t
        | esc1
        | esc2
        | esc3
		;

mostrar_ejemplo : {casoEjemplo(); cout << endl;};
mostrar_carga : {iniciarTodo(); cout << endl;};
mostrar_c : {mostrarCasilla(posx, posy); cout << endl;};
mostrar_t : {mostrarTasas(sus_to_inf, inf_to_dead, inf_to_rec, rec_to_sus); cout << endl;};
esc1    :  ESC1 {var=30; sus_to_inf=40; inf_to_dead=45;inf_to_rec=7;rec_to_sus=4;iniciarTodo();}
;
esc2    :  ESC2 {var=30; sus_to_inf=50; inf_to_dead=70;inf_to_rec=4;rec_to_sus=3;iniciarTodo();}
;
esc3    :  ESC3 {var=30; sus_to_inf=50; inf_to_dead=70;inf_to_rec=4;rec_to_sus=3;iniciarTodo();}
;

%%

int main() {
	yyin = stdin;

	do {
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}