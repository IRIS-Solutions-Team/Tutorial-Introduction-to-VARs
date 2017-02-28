%% Identify structural VAR
%
% Use a simple identification scheme based on Choleski decomposition to
% calculate a structural VAR from the estimated reduced-form VAR. Check the
% properites of the structural shocks, and run shock (impulse) response
% simulation.

%% Clear Workspace

clear;
close all;
clc;
%#ok<*NOPTS>

%% Load Estimated Reduced-Form VAR and Data
%
% Load the estimated reduced-form VAR object and its data.

load estimate_simple_VAR.mat v vd;

%% Identify Structural VAR
%
% Use simple Cholesky decomposition to identify a structural VAR; this is
% the default identification scheme in the functio `SVAR` <?svar?> . This
% gives a SVAR with a lower triangular matrix, `B`, of instantaneous shock
% multipliers. Use the option `'ordering='` <?ordering?> to change the
% order of shocks; in that case, the matrix `B` is a permuted lower
% triagular matrix <?BPermuted?>.
%
% The function `SVAR` also returns a new database, `sd1` or `sd2`, where
% the shocks are recomputed according to the identification scheme:
%
% $$y_t = A_1 y_{t-1} + A_2 y_{t-2} + B u_t$$
% $$\mathrm E [ u_t u_t' ] = \mathrm I$$
% $$ B B' = \Omega $$
%
% Compare this form with the reduced-form VAR equation in
% `estimate_simple_VAR`.

[s1,sd1] = SVAR(v,vd); %?svar?

[s2,sd2] = SVAR(v,vd, ...
    'ordering=',{'yy','pp','r','mm'}); %?ordering?

get(s1,'B')
get(s2,'B') %?BPermuted?

%% Covariance of Structural Shocks
%
% The identifying restrictions used to set up a structural VAR above
% included the assumption of uncorrelated structural shocks. Compute the
% sample covariance and correlation matrix of the reduced-form residuals
% (i.e. forecast errors from the reduced-form VAR, contained in the
% database `vd`), and those of the structural shocks: first manually
% <?manual?> and then using the function `acf` <?acf?>.

xv = [vd.res_r, ... %?reducedform?
    vd.res_pp, ...
    vd.res_yy, ...
    vd.res_mm];
xv(:,:).' * xv(:,:) / length(xv) %?manual?
acf(xv,Inf,'demean=',false,'smallSample=',false) %?acf?

xs = [sd2.res_r, ... %?structural?
    sd2.res_pp, ...
    sd2.res_yy, ...
    sd2.res_mm];
xs(:,:).' * xs(:,:) / length(xs)
acf(xs,Inf,'demean=',false,'smallSample=',false)

%% Asymptotic ACF for endogenous variables
%
% The asymptotic properties of the endogenous variables remain exactly the
% same in both the reduced-form VAR, `v`, and the structural VAR, `s`.
% Calculate and compare the asymptotical autocovariance (`CV`, `CS`) and
% autocorrelation (`RV`, `RS`) matrices up to second order for the VAR
% <?acfVar?> and the SVAR <?acfSvar?>.
%
% The matrices are all Ny-by-Ny-K, where Ny is the number of variables, and
% K is the maximum order requested (i.e. 2) plus 1 (for the contemporaneous
% matrices).
%
% Show the contemporaneous coveriances and correlations (i.e. the first
% pages in the `CV`, `RV`, `CS`, and `RS`). Verify that the matrices are
% identical for the VAR and the SVAR <?identical?>.

[CV,RV] = acf(v,'order=',2); %?acfVar?
[CS,RS] = acf(s2,'order=',2); %?acfSvar?

size(CV)

CV(:,:,1)
CS(:,:,1)
RV(:,:,1)
RS(:,:,1)

maxabs(CV-CS) %?identical?
maxabs(RV-RS) %?identical?

%% Simulate Shock Response Function
%
% Run the function `srf` <?srf?> to calculate shock (impulse) responses.
% The function returns two databases : `s` is a database with plain shock
% responses <?plainSrf?>, `sc` is a database with cumulative responses
% <?cumulSrf?>. The option `'presample='` is used to fill the output time
% series with zeros before the shock period; this is for reporting purposes
% only.
%
% Each variables in the output databases has 4 columns, i.e.
% the responses to the 4 shock <?shocks?>. Plot the plain shock responses
% in a 4-by-4 figure.ßßß

[s,sc] = srf(s2,1:30,'presample=',true); %?srf?
s %?plainSrf?
sc %?cumulSrf?

yNames = get(s2,'yNames')
eNames = get(s2,'eNames') %?shocks?

figure();
count = 0;
for i = 1 : 4
    for j = 1 : 4
        % Response of the i-th variable to the j-th shock.
        count = count + 1;
        subplot(4,4,count);
        
        plot(0:20,s.(yNames{i}){:,j});
        axis tight;
        grid on;
        grfun.zeroline();
        title(['Response in ',yNames{i},' to ',eNames{j}], ...
            'interpreter','none');
    end
end

grfun.ftitle('Shock (Impulse) Response Function');

%% Help on IRIS Functions Used in This File
%
% Use either `help` to display help in the command window, or `idoc`
% to display help in an HTML browser window.
%
%    help SVAR
%    help SVAR/SVAR
%    help VAR/acf
%    help SVAR/srf
%    help grfun/ftitle
%    help grfun/zeroline
%    help utils/maxabs
