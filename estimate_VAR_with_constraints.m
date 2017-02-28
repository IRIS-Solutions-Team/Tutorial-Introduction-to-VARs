%% Estimate VAR with Parameter Constraints
% by Jaromir Benes
%
% VARs can be estimated with various types of linear parameter constraints.
% Use two basic ways how to impose such constraints, and compare the
% results with the unrestricted VAR estimated previously in
% `estimate_simple_VAR`.

%% Clear Workspace

clear;
close all;
clc;
%#ok<*NOPTS>

%% Read Data, Dates and Previously Estimated VAR
%
% Load historical data prepared in `read_data`, and the dates defining the
% start and end of the historical sample. These are the same input as in
% `estimate_simple_VAR`. Load also the VAR estimated previously in
% `estimate_simple_VAR` as a point of reference.

load MAT/read_data.mat g2 startHist endHist;
load MAT/estimate_simple_VAR.mat v;

%% Impose Parameter Constraints
%
% Parameter constraints (i.e. constraints on the elements of the transition
% matrix, the constant vector, or the cointegration vector multiplier) can
% be imposed in two ways:
%
% 1. If you need to simply fix one or more parameters to certain numbers,
% use the options `'A='`, `'K=`' or `'G='`. Create an NaN matrix or vector
% of an appropriate size (see below), assign the desired numbers to the
% coefficients you want to fix, and leave those coefficients that are to be
% estimated freely as `NaN`.
%
% * the option `'A='` (for constraints on the transition matrix) needs to
% be an Ny-by-Ny-by-P matrix;
% * the option `'K='` (for constraints on the constant vector) needs to be
% an Ny-by-1 vector;
% * the option `'G='` (for constraints on the cointegration vector
% multipliers) needs to be an Ny-by-Ng matrix;
%
% where Ny is the number of variables, P is the order of the VAR, and Ng is
% the number of cointegration vectors specificed through the option
% `'cointeg='`.
%
% 2. If you need to impose general linear constraints, use the option
% `'constraints='`, and specify a string or cell array of strings with
% individual constraints, refering to the individual elements of `A`, `K`,
% or `G`.
%
% First, use three different ways to impose the same constraints on the
% transition matrix. The constraint is the the effect of the 1st and
% 2nd variables on the 3rd variable is zero across all lags; in other
% words, all the following elements of matrix `A` will be fixed to zero:
% `A(3,1,1)` (the effect of the 1st variable on the 3rd variable in the
% 1st lag), `A(3,2,1)` (2nd variable on 3rd variable, 1st lag), `A(3,1,2)`
% (1st variable on 3rd variable, 2nd lag), and `A(3,2,2)` (2nd variable on
% 3rd variable, 2nd lag).
%
% Impose these constraints using the option `'A='` <?optionA?>, the option
% `'constraints='` with four individual constraints specified as a cellstr,
% and finally using the same option `'constraints='` with the constraints
% specified in a more compact form.

yList = get(v,'yList');
p = get(v,'order');

v1 = VAR(yList);
constrA = nan(4,4,2);
constrA(3,1:2,:) = 0;
[v1,vd1] = estimate(v1,g2,startHist:endHist, ...
    'order=',p,'const=',false, ...
    'A=',constrA); %?optionA?

v2 = VAR(yList);
[v2,vd2] = estimate(v2,g2,startHist:endHist, ...
    'order=',p,'const=',false, ...
    'constraints=',{'A(3,1,1)=0','A(3,2,1)=0','A(3,1,2)=0','A(3,2,2)=0'});

v3 = VAR(yList);
[v3,vd3] = estimate(v3,g2,startHist:endHist, ...
    'order=',p,'const=',false, ...
    'constraints=','A(3,1:2,:)=0');

% ...
%
% Next, impose a more general constraint on the transition matrix: The sum
% of the first-lag effects of the 1st and 2nd variable on the 3rd variable
% is imposed to be 1.

v4 = VAR(yList);
[v4,vd4] = estimate(v4,g2,startHist:endHist, ...
    'order=',p,'const=',false, ...
    'constraints=','A(3,1,1)+A(3,2,1)=-1');

%% Compare Estimated Transition Matrices
%
% Use the function `get` with the query `'A*'` to retrieve the transition
% matrix from each estimated VAR. The returned matrices are all
% Ny-by-Ny-by-P where Ny is the number of variables, and P is the order of
% the VAR. `A0` is the transition matrix of the original unconstrained VAR
% <?origVAR?>, `A1`, `A2` and `A3` are the transition matrices of the three
% VARs with zero constraints, <?zeroConstr1?> <?zeroConstr2?>
% <?zeroConstr3?> (these transition matrices are obviously identical), and
% `A4` is the transition matrix of the VAR with a general linear constraint
% <?genConstr?>.

A0 = get(v, 'A*'); %?origVAR?

A1 = get(v1,'A*'); %?zeroConstr1?
A2 = get(v2,'A*'); %?zeroConstr2?
A3 = get(v3,'A*'); %?zeroConstr3?

A4 = get(v4,'A*'); %?genConstr?

size(A0)
size(A1)
size(A2)
size(A3)
size(A4)

% ...
% The transition matrices in `v1`, `v2`, and `v3` are identical.

maxabs(A1 - A2)
maxabs(A1 - A3)

% ...
%
% Print the transition matrices on the 1st lag, including the original
% unconstrained VAR. The zeros are the result of the parameter constraints
% imposed in estimation.

A0(:,:,1)
A1(:,:,1)
A2(:,:,1)
A3(:,:,1)

% ...
% Print the transition matrices on 2nd lag.

A0(:,:,2)
A1(:,:,2)
A2(:,:,2)
A3(:,:,2)

% ...
% Verify the constraint in the 4th case, `A(3,1,1)+A(3,2,1)=-1`.

A4(3,1,1)
A4(3,2,1)
A4(3,1,1) + A4(3,2,1)

%% Compare Eigenvalues
%
% Plot and compare the eigenvalues for the three types of VARs: the
% original unconstrained one (`v`) <?origEig?>, the one with `A(3,1:2,:)=0`
% (the VAR objects `v1`, `v2`, `v3` are identical) <?zeroConstrEig?>, and
% the ones with `A(3,1,1)+A(3,2,1)=-1` (`v4`) <?genConstrEig?>.

figure();
hold on;
ploteig(v,'color=',0.4*[1,1,1],'marker=','s','markerSize=',14); %?origEig?
ploteig(v1,'color=','red','marker=','o','markerSize=',8); %?zeroConstrEig?
ploteig(v4,'color=','blue'); %?genConstrEig?
grid on;

grfun.ftitle('Eigenvalues');
legend('Original unconstrained VAR', ...
    'VAR with A(3,1:2,:)=0', ...
    'VAR with A(3,1,1)+A(3,2,1)=-1');

%% Help on IRIS Functions Used in This File
%
% Use either `help` to display help in the command window, or `idoc`
% to display help in an HTML browser window.
%
%    help VAR
%    help VAR/VAR
%    help VAR/estimate
%    help VAR/get
%    help grfun/ploteig
%    help maxabs
