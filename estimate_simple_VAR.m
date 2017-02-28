%% Estimate Simple Reduced-Form VAR
% by Jaromir Benes
% 
% Estimate an unconstrained reduced-form VAR using the data prepared in
% `read_data`. Look inside the VAR object at the estimated coefficient
% matrices and eigenvalues. Resimulate then the historical data using the
% estimated residuals.

%% Clear Workspace

clear;
close all;
clc;
%#ok<*NOPTS>

%% Read Data
%
% Load historical data prepared in `read_data`, and the dates defining the
% start and end of the historical sample.

load read_data.mat g2 startHist endHist;

g2 
startHist
endHist

%% Estimate Reduced-Form VAR
%
% Estimate a second-order reduced-form VAR on the historical data. First,
% create an empty VAR object with variable names corresponding to those in
% the database, `r`, `pp`, `yy`, `mm` <?emptyVAR?>. Then, run the function
% `estimate` to estimate the coefficient matrices in the following model
%
% $$y_t = A_1 y_{t-1} + A_2 y_{t-2} + \epsilon_t$$
% $$\mathrm E \epsilon_t \epsilon_t' = \Omega$$
%
% Note that the constant is omitted from the VAR model by setting `'const='
% false'. Request the covariance matrix of parameters by setting
% `'covParameters=' true` <?covParameters?> (this covariance matrix, unlike
% the covariance matrix of residuals, is not calculated by default).
%
% The function `estimate` also returns a VAR database <?vdata?>, with the
% observations on endogenous variables clipped down to the estimation range
% (including pre-sample initical conditions) and the estimated residuals
% (forecast errors). The residuals are named `res_XX` where `XX` is
% the name of the corresponding variable.

v = VAR({'r','pp','yy','mm'}); %?emptyVAR?
v

p = 2;
[v,vd] = estimate(v,g2,startHist:endHist, ...
    'order=',p,'const=',false, ...
    'covParameters=',true); %?covParameters?

v
vd %?vdata?

%% Look Inside VAR Object
%
% Use various functions, such as `get`, `mean`, or `eig`, to retrieve
% various pieces of information on the estimated VAR object.
%
% Get the names of variables and residuals <?getNames?>. 

yNames = get(v,'yNames'); %?getNames?
eNames = get(v,'eNames');

disp('Names of variables');
yNames

disp('Names of residuals');
eNames

% ...
%
% Get the estimated coefficients in the transition matrix (which is a lag
% polynomial) <?A?> and the constant vector <?K?>.

A = get(v,'A*'); %?A%?
K = get(v,'K'); %?K?
Omg = get(v,'Omega');

disp('Transition matrices');
disp('A(1)')
A(:,:,1)
disp('A(p)');
A(:,:,p)

disp('Constant vector');
K

disp('Cov matrix of reduced-form residuals');
Omg

% ...
%
% Get the cov matrix of parameter estimates. The matrix `Sgm` is organized
% as follows:
%
% $$ \Sigma = \mathrm{cov} (\beta), $$
%
% where the beta vector is
% 
% $$ \beta = \mathrm{vec}([K,A_1,...A_p]). $$
%
% This covariance matrix is calculated and stored in the VAR object only if
% you use the option `'covParameters=' true` when estimating the VAR, see
% the section above <?covParameters?>.

Sgm = get(v,'covParameters');

disp('Size of cov matrix of parameter estimates');
size(Sgm)

% ...
%
% Get the asymptotic mean for the endogenous variables implied by the
% estimated VAR.

mu = mean(v);

disp('VAR mean'); %?mean?
mu

% ...
%
% Get the eigenvalues implied by the estimated transition matrix. The
% number of eigenvalues is always Ny-by-P, where Ny is the number of
% variables and P is the order of the VAR. Display the eigenvalue with the
% largest magnitude; this eigenvalue determines the upper bound on the
% persistence of the VAR responses.

e = eig(v);

size(e)

disp('Eigenvalues');
e.'

disp('Magnitude of the largest root');
absEig = abs(e);
max(absEig)

% ...
%
% Plot the eigenvalues in a unit circle. The position of eigenvalues gives
% a good idea about the dynamics of the VAR in response to shocks and
% initial conditions.

figure();
grfun.ploteig(v);
grid('on');
title('Estimated eigenvalues');

%% Save Estimated VAR and Data for Further Use

save estimate_simple_VAR.mat v vd;

%% Help on IRIS Functions Used in This File
%
% Use either `help` to display help in the command window, or `idoc`
% to display help in an HTML browser window.
%
%    help VAR
%    help VAR/estimate
%    help VAR/get
%    help VAR/mean
%    help VAR/eig
%    help grfun/ploteig
