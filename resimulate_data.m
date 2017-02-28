%% Resimulate Data
% by Jaromir Benes
%
% Take the estimated VAR, and resimulate the historical data to see that we
% indeed reproduce the observed paths. Calculate the contributions of
% residuals to the historical paths of the VAR variables, and run a
% counterfactual exercise with one type of residuals removed from the
% history.

%% Clear Workspace

clear;
close all;
clc;
%#ok<*NOPTS>

%% Load estimate VAR
%
% Load the estimated VAR and the VAR database, and the dates.

load estimate_simple_VAR.mat v vd;
load read_data.mat startHist endHist;

%% Resimulate Data
%
% Plot the observations used in estimating the VAR, together with the
% estimated residuals <?plotVData?>. Resimulate the date to reproduce the
% historical paths. The function `simulate` <?simulate?> takes only the
% pre-sample initial conditions for endogenous variables, and the in-sample
% residuals to run the VAR model from the input database, `vd`; nothing
% else. Note that we can only start the simulation at `startHist+p` for the
% initial condition to exist in the database. Report the maximum
% differences between the input series (database `vd`) and the simulated
% series (database `s`). They all amount to numerical rounding errors only
% <?maxAbsDiff?>.


yNames = get(v,'yNames');
eNames = get(v,'eNames');
p = get(v,'order');

dbplot(vd,Inf,[yNames,eNames], ... %?plotVData?
    'tight=',true, ...
    'zeroline=',true, ...
    'subplot=',[4,2]);
grid on;
grfun.ftitle('VAR Variables and Residuals');

s = simulate(v,vd,startHist+p:endHist); %?simulate?

s
disp('Max abs discrepancy between original and resimulated data');
maxabs(vd, s) %?maxAbsDiff?

%% Simulate Contributions of Residuals
%
% Resimulate the historical data again, but now request the contributions
% of individual residuals to the observed paths by using the option
% `'contributions='` <?contrib?>. The output database, `c`, now contains 5
% columns for each variable<?fiveCols?>: the first 4 columns are
% contributions of the 4 residuals (`res_r`, `res_pp`, `res_yy`, `res_mm`),
% whereas the last, 5-th, column is the contribution of the initial
% condition and constant. Adding the 5 columns up simply reproduces the
% original paths <?addup?>.

c = simulate(v,vd,startHist+p:endHist, ...
    'contributions=',true); %?contrib?

c %?fiveCols?

r = sum(c.r,2); %?addup?
maxabs(r,vd.r);

% ...
%
% Retrieve the first 4 columns for each series <?firstFour?>, i.e. only the
% contributions of residuals but not the initial condition and constant.
% Plot the contributions of residuals to all variables (in the first three
% years). Use the option `'plotFunc='` to call the function `barcon` to
% plot the contributions <?plotFunc?>.

c = dbcol(c,1:4) %<firstFour?>
dbplot(c,startHist+p+1:startHist+p+12,yNames, ...
    'plotFunc=',@barcon); %?plotFunc?

le = grfun.bottomlegend(get(v,'eNames'), ...
    'interpreter','none');

%% Run Counterfactual Simulation
%
% Remove the inflation residuals, `res_pp`, from the historical database
% <?remove?>, and resimulate the data again <?counterfactual?>. The
% simulated paths now correspond to a hypothetical situation with no
% forecast errors in inflation, `pp`. Plot the counterfactual
% paths against the actually observed ones.

vd1 = vd;
vd1.res_pp(:) = 0; %?remove?

s1 = simulate(v,vd1,startHist+p:endHist); %?counterfactual?

dbplot(vd & s1,startHist:endHist,yNames);
grfun.bottomlegend('Actual', 'Counterfactual');

%% Help on IRIS Functions Used in This File
%
% Use either `help` to display help in the command window, or `idoc`
% to display help in an HTML browser window.
%
%    help VAR/simulate
%    help dbase/dbplot
%    help grfun/title
%    help maxabs
