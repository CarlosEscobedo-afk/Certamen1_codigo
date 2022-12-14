#include <iostream>
#include <cstdlib>
#include <vector>
#include <sstream>
#include <string>
#include <cmath>
using namespace std;
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
	
	MATRIZ CON POBLACIONES:
	   
	["100,1,1,20"] ["100,1,1,20"] ["100,1,1,20"]
	["100,1,1,20"] ["100,1,1,20"] ["100,1,1,20"]
	["100,1,1,20"] ["100,1,1,20"] ["100,1,1,20"]
*/
// Esta función define la estructura de la grilla que se utilizará en todo el código:
typedef struct estructuraGrilla {
    string **casilla; //Array de posiciones
    unsigned int ancho;
    unsigned int largo;
} estructuraGrilla;

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

// El main establece el menú y las llamadas a funciones para el funcionamiento del AC para el modelo de contagio SIRD:
int main () {
	int ancho, largo, var, inf_to_rec, rec_to_sus, condicion;
	float sus_to_inf, inf_to_dead;
    estructuraGrilla grilla;
    grilla.casilla = NULL;
    
    cout << "Bienvenido al Automata Celular para modelos de contagio SIRD..." << endl;
    cout << "   Este AC utiliza la vecindad de Von Neumann para evaluar las reglas SIRD sobre cada casilla de la grilla." << endl << endl;
    cout << "Seleccione una opcion: " << endl << "1.- Probar un ejemplo. " << endl << "2.- Desea definir las condiciones de ejecucion." << endl;
    cin >> condicion;
    if (condicion == 1){
    	ancho = 10;
    	largo = 10;
    	sus_to_inf = 0.3;
    	inf_to_dead = 0.1;
    	inf_to_rec =5;
    	rec_to_sus = 3;
    	cout << "Tamaño de la Grilla: " << ancho << "x" << largo << endl;
	    cout << "1.- Cantidad de infectados (I) necesarios para que un susceptible (S) se infecte: " << sus_to_inf << endl;
	    cout << "2.- Probabilidad de que un infectado muera (0-100%): " << inf_to_dead << endl;
	    cout << "3.- Cantidad de dias (iteraciones) necesarios para que un infectado (I) pase a ser recuperado (R): " << inf_to_rec << endl;
	    cout << "4.- Cantidad de dias (iteraciones) necesarios para que un recuperado (R) pase a ser susceptible (S): " << rec_to_sus << endl;
	}
	else{
		cout << "Defina el tamaño de la grilla: " << endl;
	    cout << "Ancho: ";
	    cin >> ancho;
	    cout << "Largo: ";
	    cin >> largo;
	    cout << endl << "Defina las reglas de SIRD: " << endl;
	    cout << "1.- Probabilidad para que un susceptible (S) se infecte: ";
	    cin >> sus_to_inf;
	    sus_to_inf = sus_to_inf / 100;
	    cout << "SUS : " << sus_to_inf << endl;
	    cout << "2.- Probabilidad de que un infectado muera (0-100%): ";
	    cin >> inf_to_dead ;
	    inf_to_dead = inf_to_dead / 100;
	     cout << "muerte : " << inf_to_dead << endl;
	    cout << "3.- Cantidad de dias (iteraciones) necesarios para que un infectado (I) pase a ser recuperado (R): ";
	    cin >> inf_to_rec;
	    cout << "4.- Cantidad de dias (iteraciones) necesarios para que un recuperado (R) pase a ser susceptible (S): ";
	    cin >> rec_to_sus;
	}
	cargarInicial(grilla, ancho, largo, condicion);
    cout << endl << "Grilla inicial: " << endl;
    imprimirGrilla(grilla);	
    
    cout << endl << "Ingrese la cantidad de iteraciones que desea ver: " << endl;
    cin >> var;
    for (int i = 0; i < var; i++) {
        transcursoGrilla(grilla, i+1, sus_to_inf, inf_to_dead, inf_to_rec, rec_to_sus);
        cout << endl << "Iteracion: " << i+1 << endl;
        imprimirGrilla(grilla);
    }
    return 0;
}