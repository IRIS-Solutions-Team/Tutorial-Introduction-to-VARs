%% Produce Unconditional and Conditional Forecasts
% by Jaromir Benes
%
% Use the estimated VAR to produce unconditional and conditional forecasts.
% One forecast is conditioned upon a path for one endogenous variable.
% Another forecast is conditioned upon a path for a so-called instrument.
% Forecast conditioning instruments can be defined as linear combinations
% of endogenous variables and their lags, and added to VAR objects.

%% Clear Workspace

clear;
close all;
clc;
%#ok<*NOPTS>

%% Load Data, Estimated VAR, and Dates 
%
% Load the historical data and dates prepared in `read_data`. Load the VAR
% object estimated in `estimate_simple_VAR`.

load read_data.mat d g2 startHist endHist;
load estimate_simple_VAR.mat v;

%% Define Dates
%
% Run the forecast for 8 quarters after the end of the historical sample.

startFcast = endHist + 1;
endFcast = endHist + 8;

%% Run Unconditional Forecast
%
% Run the function `forecast` to produce an unconditional forecast
% <?uncFcast?>: unconditional in the sense it only uses information up
% until time t-1. Unless you modify some of the options, `forecast` returns
% a database with `.mean` and `.std` fields, with the point forecasts and
% the std deviations. Use the function `dboverlay` to combine the
% historical data and the forecast paths <?dboverlay?> (the output database
% only includes data for the forecast periods and the necessary pre-sample
% initial conditions); this is for reporting purposes only.

u = forecast(v,g2,startFcast:endFcast); %?uncFcast?

u
u.mean
u.std

u.mean = dboverlay(g2,u.mean); %?dboverlay?

%% Run Forecact Conditional Upon Endogenous Variable
%
% Run a forecast conditional upon the interest rate, `r`, being fixed at
% its last observed value for 2 quarters, `startFcast` and `startFcast+1`.
% To do that, create a conditioning database, `j1`, <?condDb?> and pass the
% database as the 4th input argument into the function `forecast`
% <?condFcast?>. Verify that the interest rate forecast complies with the
% conditions imposed <?verify1?>.

j1 = struct();
j1.r = tseries();
j1.r(startFcast:startFcast+1) = g2.r(endHist); %?condDb?

c1 = forecast(v,g2,startFcast:endFcast,j1); %?condFcast?

c1.mean.r %?verify1%

c1.mean = dboverlay(g2,c1.mean);


%% Define Forecast Conditioning Instrument
%
% A forecast conditioning instrument is simply a linear combination of
% endogenous variables (and/or their lags). The instrument can be then used
% to condition a forecast upon a particular path for it. You can define any
% number of instruments within a VAR object, and use them selectively in
% forecasting.

v = instrument(v,'nn := pp + yy');

get(v,'iList')
get(v,'iEqtn')

%% Run Forecast Conditional Upon Instrument
%
% Run another conditional forecast, this time using the instrument. Define
% a conditioning database, `j2`, with a desired path for the conditioning
% instrument `nn`. Impose an assumption of zero growth rate in nominal
% output throughout the entire forecast here <?instrPath?>. Verify that the
% forecast complies with the conditions imposed on the instrument
% <?verify2?>.

j2 = struct();
j2.nn = tseries();
j2.nn(startFcast:endFcast) = 0; %?instrPath?

c2 = forecast(v,g2,startFcast:endFcast,j2);

c2.mean.pp + c2.mean.yy %?verify2%

c2.mean = dboverlay(g2,c2.mean);

%% Report Forecasts
%
% Use the function `dbplot` to plot the four variables for each type of the
% forecast: unconditional <?reportUnc?>, conditional upon an endogenous
% variable <?reportCon1?>, and conditional upon the instrument
% <?reportCon2?>. Setting the option `'plotFunc='` to `@errorbar` produces
% error bar plots whenever the input time series have two columns: the mean
% and the std deviation. This is achieved by using the `&` operator <?et?>
% to combine the two respective databases.
%
% Note the general shrinkage in the std deviations in conditional forecasts
% compared with the unconditional one.

yList = get(v,'yList');
plotFunc = @(Rng,X,varargin) errorbar(Rng,X{:,1},X{:,2},varargin{:});

dbplot(u.mean & u.std, ... %?et?
    endHist-8:endFcast, ...
    yList, ...
    'plotFunc=',plotFunc, ...
    'zeroLine=',true, ...
    'highlight=',endHist-8:endHist); %?reportUnc?
grfun.ftitle('Unconditional forecasts');

dbplot(c1.mean & c1.std, ...
    endHist-8:endFcast, ...
    yList, ...
    'plotFunc=',plotFunc, ...
    'zeroLine=',true, ...
    'highlight=',endHist-8:endHist ...
    ); %?reportCon1?
grfun.ftitle('Forecasts condition upon fixed interest rate');

dbplot(c2.mean & c2.std, ...
    endHist-8:endFcast, ...
    yList, ...
    'plotFunc=',plotFunc, ...
    'zeroLine=',true, ...
    'highlight=',endHist-8:endHist); %?reportCon2?
grfun.ftitle('Forecasts condition upon constant nominal growth nn');

%% Help on IRIS Functions Used in This File
%
% Use either `help` to display help in the command window, or `idoc`
% to display help in an HTML browser window.
%
%    help VAR
%    help VAR/forecast
%    help VAR/instrument
%    help VAR/get
%    help dbase/dbplot
%    help grfun/ftitle
