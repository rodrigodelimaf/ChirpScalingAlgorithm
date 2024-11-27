clear all; clc;
%% ET-291 - Rômulo Fernandes da Costa
%Este script gera parametros para teste dos algoritmos de processamento sar
%coloca-se novos alvos nos vetores offset_alvo_azimute e offset_alvo_range.

%kaiser_beta = 2.5;
squint_angle =0*pi/180; 
offset_alvo_azimute = [0.0e0,-0.1e0,0.2e0]; %% coloque valores entre -1.2 até 1.2 (em segundos)
offset_alvo_range = [0.0e-6,-0.4e-6,0.0e-6]; %% valores entre -3e-6 até 3e-6

    %% aqui usa-se dados aerotransportados dos slides - aula 9, slide 24
Naz = 256;
Nrg = 256;    

PRF             = 100;           % Pulse Reputation Frequency (Hz)
Fr              = 60e+6;     % Radar sampling rate (Hz)
f0              = 5.300e+9;      % Radar center frequency (Hz)
c               = 2.9979e+8;     % Speed of light (m/s)
R0              = 20e3;%200;          % Slant range at scene center
Kr              = 20e+12;   % FM rate of radar pulse (Hz/s)
Tr              = 2.5e-6;                % Chirp duration (s)


Vr = 150;       %velocidade do radar
% Vs = Vr*1.06;   %velocidade de vs é 6% maior que Vr
% Vg = Vr*0.94;   %velocidade do feixe é 6% menos que vr

La = 5;        %comprimento da antena


%% calculo da resposta s0(eta=tempo lento, tau = tempo rapido) no dominio do tempo
s0_upchirp = 0;
% s0_downchirp = 0;

Vg = Vr; %velocidade do feixe é a mesma da plataforma em sistema aerotransportado

% data = zeros(Naz,Nrg);                                      %placeholder para os dados de verdade 

for (index_offset=1:length(offset_alvo_azimute))
    lambda = c/f0;                                          %comprimento de onda
    eta_c = -R0*tan(squint_angle)/Vr;
    if (squint_angle==0)
        R_eta_c = R0;
    else
        R_eta_c = -Vr*eta_c/sin(squint_angle);
    end
    eta = (((1:Naz)-(Naz/2))/PRF)'+eta_c + offset_alvo_azimute(index_offset);
    tau = ((1:Nrg)-(Nrg/2))/Fr +2*R_eta_c/c + offset_alvo_range(index_offset);
    %eta = (((1:Naz)-(Naz/2))/PRF)'+eta_c + offset_alvo_azimute(index_offset);       %tempo lento
    %tau = ((1:Nrg)-(Nrg/2))/Fr +2*R_eta_c/c + offset_alvo_range(index_offset);   %tempo rápido
    
    R_eta = sqrt(R0.^2+((eta)*Vr).^2);                            %slant range (distancia) em funcao do tempo
    %R_eta = R0+(eta*Vr).^2/(2*R0);
    %theta = atan((eta-eta_c).*Vr./(R_eta));      
    theta = atan((eta-eta_c).*Vr./(R0));  %aula 6, slide 35
    
    p_a = sinc(0.886*theta/(0.886*lambda/La));
    wa = p_a.^2;                                                % aula 6 slide 36
    A0 = 1;
    wr = rect((tau-2*R_eta/c)/Tr);                          %funcao de janelamento do chirp; removido: %.*kaiser(size(data,2),2.5)';
    %calculo do sinal gerado pelo alvo pontual.
    s0_upchirp = s0_upchirp + A0.*wr.*wa.*exp(-1i.*4.*pi.*f0.*R_eta/c).*exp(1i.*pi.*Kr.*((tau-2*R_eta/c).^2) );      
end
raw_data = s0_upchirp;

%%funcao pra gerar o rect
function output = rect(input)
    output = 1*(input.^2<0.25);
end