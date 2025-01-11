clear ; close ; clc;

%% Calcolo risposta libera del sistema climatizzatore

%% Inizializzazione

gamma_cs=12;          % Coefficiente di scambio termico tra climatizzatore e stanza
gamma_sa=2.3;         % Coefficiente di scambio termico tra la stanza e l'esterno
C_s=45225;            % Capacità termica dell'aria
C_c=2000;             % Capacità termica del climatizzatore
q=2.65;               % Potenza termica calcolata da un 9000 BTU/h
temp_amb=30;


%% Valutazione risposta libera

% Definizione matrici
A=[(-gamma_cs/C_c) (gamma_cs/C_c); (gamma_cs/C_s) -((gamma_cs/C_s)+(gamma_sa/C_s))];
B=[1/C_c; 0];
C=[0 1];
D=0;
x0=[23; 25];

%Analisi risposta libera
autovalori=eig(A); 
if autovalori<0
    disp('Sistema asintoticamente stabile')
else
    disp ('Il sistema non è asintoticamente stabile')
end

%Parametri

autovalore_dominante=max(autovalori);
costante_di_tempo=-1/(autovalore_dominante);
t_a=5*costante_di_tempo;
t_s=3*costante_di_tempo;

% Analisi a regime

u=q;
temp_des=20;
Y_inf=-C*(A\B)*temp_des;
errore=temp_des-Y_inf;
if(errore>0.1*u)
    disp('Il sistema a ciclo aperto presenta un errore a regime pari a:');
    errore
end


%% Progettare un controllore tale che t_a<600 e no oscillazioni con inseguimento di un gradino  a regime %%

% Analisi a ciclo aperto già fatta nella risposta del sistema in quanto il
% sistema è A.S. per cui gli autovalori sono minori di 0

% Controllabilità:
Contr=ctrb(A,B);
det_Contr=det(Contr);
if det_Contr ~= 0
    disp ('Sistema Completamente Controllabile')
else
    disp ('Sistema non Completamente Controllabile')
end

%% traduzione parametri

ta=600;
auto_desiderati= [-1/124 -1/120];

% Azione in feedback

K = place (A,B, auto_desiderati);

% Azione in feedforward

kr= -1/(C*((A-B*K)\B));




%% Supposto che lo stato non sia accessibile progettare un osservatore che garantisca l'implementabilità del controllo in retroazione di stato progettato nel passo 
%% precedente


% osservabilità

Matrix_observavility=obsv(A,C);
rango=rank(Matrix_observavility);
stato=2;
if (rango==stato)
    disp('Sistema osservabile');
else
    disp('Sistema non osservabile')
end

% Traduzione delle specifiche

aut_des_obs=[-20 -30];          % vanno scelti più piccoli perchè deve essere più veloce rispetto al controllo
M=place(A',C',aut_des_obs);
M=M';
