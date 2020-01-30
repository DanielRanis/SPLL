%%  Title:  Software Phase-Locked Loop (SPLL) Project    %
%   Author: Daniel Ranisavljevic                        %   
%-------------------------------------------------------%
clear all;
close all;
clc;

A=3.3;
phi=pi;
f=10;
fs=878;
T=50/f;
Ts=1/fs;
bit=12;


Bn=(1/100)*fs;
D=0.707;
Ko=1;Kd=0.5;
Kp=(1/(Kd*Ko))*(4*D/(D+(1/(4*D))))*(Bn/fs);
Ki=(1/(Kd*Ko))*(4/(D+((1/4*D))^2))*((Bn/fs)^2);


t = 0:1/100000000:T;
%Continous-Time Input Signal
Inc=A*sin(2*pi*t*f + phi);

%Discrete-Time Input Signal
ts = 0:1/fs:T-Ts;
xs = A*cos(2*pi*f*ts + phi) ;   % Sampling Process
q=max(xs)/(2^bit-1);        % Quantization Process
Ind=round(xs/q) ;


len=length(Ind);
ed=0;
ef=zeros(1,len);
NCO=0;
phi2=0;
temp1=0;temp2=0;temp3=0;temp4=0;
fc=5;
RC=1/(fc*2*pi);
dt=Ts;
a=dt/(RC+dt);
for k = 1:len
    %Input Normalization
    Indn(k)=Ind(k)/(2^bit-1);
    
    %Phase Detector Output
    ed=Kd*(NCO)*Indn(k);
    %Low-Pass Filter 
    yo=a*ed+(1-a)*temp4;
    ed=yo;
    dphi(k)=ed;
    %Filter Output
    ef2=Ki*ed+temp1;
    ef(k)=Kp*ed+ef2;
    
    %NCO Output
    phi2=temp2+Ko*temp3;
    Phi2(k)=phi2;
    NCO=-sin(2*pi*f*ts(k) + phi2);
    OUT(k)=NCO;
    %Phase Error
    phi_err(k)=phi-abs(Phi2(k));
    
    temp1=ef2;
    temp2=phi2;
    temp3=ef(k);
    temp4=yo;
end
 %% Plot
        figure;
        subplot(2,3,1);
        plot(t,Inc,'LineWidth',2);grid on;hold;
        title('Continous-Time Input Signal');
        subplot(2,3,4);
        stem(Ind,'LineWidth',2);hold;grid on;stairs(Ind,'LineWidth',2);
        title('Discrete-Time Input Signal');
        
        subplot(2,3,2);
        plot(ts,Phi2,'LineWidth',2); grid on; hold;
        title('Phase of Discrete Output Signal');
        legend('Phi2');
        subplot(2,3,5);
        stem(dphi,'LineWidth',2); grid on; hold;
        title('Phase Difference: Phi1 - Phi2');
        legend('dPhi');

        subplot(2,3,[3 6]);
        plot(ts,Indn,ts,OUT,'LineWidth',2); grid on; hold;
        title('Discrete Filter Output Signal');
        legend('Reference Signal','Resulting Signal');
        
        figure;
        plot(ts,phi_err,'LineWidth',2);grid on; hold;
        title('Phase Error');
        
