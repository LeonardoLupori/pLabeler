function Q = quantile(X,p)
% Quantile Analysis
%
% Author: David Ferreira - Federal University of Amazonas
% Contact: ferreirad08@gmail.com
% Date: February 2019
%
% Syntax
% 1. Q = quantile(X,p)
%
% Description 
% 1. Calculate the quantiles of a vector or matrix data using linear interpolation.
%
% Examples
% 1.
%      v = [10 1 2 3 4 7];
%      p = [0.25 0.50 0.75];
%      Q = quantile(v,p)
%      Q = 
%          2.2500
%          3.5000
%          6.2500
%
% 2.
%      X = [1 2; 2 5; 3 6; 4 10; 7 11; 10 13];
%      Q = quantile(X,p)
%      Q = 
%          2.2500    5.2500
%          3.5000    8.0000
%          6.2500   10.7500

if isrow(X), X = X'; end

X = sort(X); % Ordered elements
[n,m] = size(X);

if n < 2 || ismember(1,p), X(n+1,:) = 0; end

i = (n-1)*p(:)+1; % Indexes
f = floor(i); % Integer part of indexes
Q = X(f,:) + (X(f+1,:) - X(f,:)).*repmat(i-f,1,m);
end
