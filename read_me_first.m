%% Introduction to VAR Modeling in IRIS
% by Jaromir Benes
%
% The tutorial is an introduction into VAR modeling in IRIS. We prepare
% data, estimate a reduced-form VAR, check its properties, and assess the
% sampling uncertainty by bootstrapping. We then produce conditional and
% unconditional forecasts, and show how to identify a structural VAR
% (SVAR).

%% How to Best Run This Tutorial?
%
% Each m-file in this tutorial is split into what is called "code sections"
% in Matlab. A code cell is a shorter block of code performing a specific
% task, separated from other code cells by a double percent sign, `%%`
% (usually with a title and brief introduction added). By default, the
% cells are visually separated from each other by a horizontal rule in the
% Matlab editor.
%
% Instead of running each m-file from the command window, or executing this
% `read_me_first` as a whole, do the following. Open one tutorial m-file in
% the Matlab editor. Arrange the editor window and the command window next
% to each other so that you can see both of them at the same time. Then run
% the m-file cell by cell. This will help you watch closely what exactly
% is going on.
%
% To execute one particular cell, place the cursor in that cell (the
% respective block of code will get highlighted), and select "Run Current
% Section" from a contextual menu (upon a right click on the mouse), or
% pressing a keyboard shortcut (which differ on different systems and
% Matlab versions). To learn more on code sections, search Matlab
% documentation for "code section".

%% Read and Prepare Data for VAR Estimation
%
% In this file, we read two CSV data files with some basic U.S. time series
% (some monthly, some quarterly), filter the data using an HP filter with
% tunes, and prepare a database that will be later used to estimate a VAR
% model.

% edit read_data.m;
read_data;

%% Estimate Simple Reduced-Form VAR
% 
% In this file, we estimate an unconstrained reduced-form VAR using the
% data prepared in `read_data`. We look inside the VAR object at the
% estimated coefficient matrices and eigenvalues. We then resimulate the
% historical data using the estimated residuals.

% edit estimate_simple_VAR.m;
estimate_simple_VAR;

%% Resimulate Data
%
% In this file, we take the estimated VAR, and resimulate the historical
% data to see that we indeed reproduce the observed paths. We then
% calculate the contributions of residuals to the historical paths of the
% VAR variables, and run a counterfactual exercise with one type of
% residuals removed from the history.

% edit resimulate_data.m;
resimulate_data;

%% Estimate VAR with Parameter Constraints
%
% VARs can be estimated with various types of linear parameter constraints.
% In this file, we show two basic ways how to impose such constraints, and
% compare the results with the unrestricted VAR estimated previously in
% `estimate_simple_VAR`.

% edit estimate_VAR_with_constraints.m;
estimate_VAR_with_constraints;

%% Bootstrap VAR
%
% Bootstrap is a simple yet powerful method to assess sampling uncertainty
% in the estimated characteristics of, or simulation results based on,
% parametric models, such as VARs or SVARs. In this file, we show how to
% resample from an estimated VAR object, plot bootstrapped histograms for
% the estimated coefficients and the VAR autocorrelation function, and
% generate confidence intervals for parameter uncertainty in out-of-sample
% simulations.

% edit bootstrap_VAR.m;
bootstrap_VAR;

%% Produce Unconditional and Conditional Forecasts
%
% In this file, we use the estimated VAR to produce unconditional and
% conditional forecasts. One forecast is conditioned upon a path for one
% endogenous variable. Another forecast is conditioned upon a path for a
% so-called instrument. Forecast conditioning instruments can be defined as
% linear combinations of endogenous variables and their lags, and added to
% VAR objects.

% edit produce_forecasts.m;
produce_forecasts;

%% Identify structural VAR
%
% Use a simple identification scheme based on Choleski decomposition to
% calculate a structural VAR from the estimated reduced-form VAR. Check the
% properites of the structural shocks, and run shock (impulse) response
% simulation.

% edit identify_structural_VAR.m;
identify_structural_VAR;

%% Publish M-Files to PDFs
%
% The following commands can be used to create PDF versions of the model
% file and the m-files:
%
%     latex.publish('read_me_first.m',[],'evalCode=',false);
%     latex.publish('read_data.m');
%     latex.publish('estimate_simple_VAR.m');
%     latex.publish('resimulate_data.m');
%     latex.publish('estimate_VAR_with_constraints.m');
%     latex.publish('bootstrap_VAR.m');
%     latex.publish('produce_forecasts.m');
%     latex.publish('identify_structural_VAR.m');
