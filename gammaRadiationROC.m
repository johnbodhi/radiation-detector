clear all; close all; clc

% Sensor distance from radiation source.

D = 1;

% Source radiation factor in CPM (Gamma photons per minute).

A = 10^5;

% H0 parameters... (LAMBDA = MU = VAR)

LAMBDA = 8; 

% H1 parameters... (LAMBDA_ = MU_ = VAR_ )

LAMBDA_ = LAMBDA + A / D^2;

% Poisson observation array...

N = 2000; M = 400; L = 20; X = zeros(N,M); % Ensure detection of H1 with large N.

% First colum in H0 with onyl background radiation.

X(:,1) = poissrnd(LAMBDA,[N,1]);

% Second column is H1 at 1 meter, etc...

X(:,2) = poissrnd(LAMBDA_,[N,1]);

% Array generation as a function of distance with static source radiation term.

for j = 3:400  
    LAMBDA_ = LAMBDA + A / j^2;
    X(:,j) = poissrnd(LAMBDA_,[N,1]);        
end

% Histograms at selected distances...

figure(1);histogram(X(:,1)); % H0 at 1 meter.

figure(2);histogram(X(:,2)); % H1 at 1 meter.

figure(3); histogram(X(:,100),100); % H1 at 100 meters.

figure(4); histogram(X(:,200)); % H1 at 200 meters.

figure(5); histogram(X(:,300),100); % H1 at 300 meters.

figure(6); histogram(X(:,400),100); % H1 at 400 meters.

% PD and PFA analytically with CDF...

PD0 = poisscdf(14,8); PFA0 = 1 - poisscdf(14,8);


PD1 = poisscdf(14,18); PFA1 = 1 - poisscdf(14,18);

% We need to make decsions on selected distances given some random sensor
% input using function npDetector...

LAMBDA_ = LAMBDA + A / D^2;

for k = 1:20
    
    % First colum in H0 with only background radiation.

    X(:,1) = poissrnd(LAMBDA,[N,1]);

    % Second column is H1 at 1 meter, etc...
    
    LAMBDA_ = LAMBDA + A / D^2;

    X(:,2) = poissrnd(LAMBDA_,[N,1]);

    % Array generation as a function of distance with static source radiation term.

    for j = 3:M
        LAMBDA_ = LAMBDA + A / j^2; X(:,j) = poissrnd(LAMBDA_,[N,1]);        
    end

    for j = 1:M
        LAMBDA_ = LAMBDA + A / j^2;        
        for i = 1:N
            KD   = size( find(X(:,j) > k ),1 ); PD(i,j,k) = KD / N;
            KFA = size( find(X(:,j) < k ),1 ); PFA(i,j,k) = KFA / N;                         
        end
    end    
end

% Plot PR for H0 and H1 at 1-400 meters.

for j = 1:M
    for k = 1:L
        U(k,j) = PD(1,j,k); V(k,j) = PFA(1,j,k);
    end
end

U = flip(U,1);

U(:,1:99) = 0; U(:,101:199) = 0; U(:,201:299) = 0; U(:,301:399) = 0;
V(:,1:99) = 0; V(:,101:199) = 0; V(:,201:299) = 0; V(:,301:399) = 0;

figure(7); plot(V,U, 'k-', (0:0.05:1), (0:0.05:1), 'g'); 

title('ROC'); xlabel('PFA'); ylabel('PD');