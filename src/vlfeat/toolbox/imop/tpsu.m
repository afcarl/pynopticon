function [U,dU,delta]=tpsu(X,Y)
% TPSU  Compute the U matrix of a thin-plate spline transformation
%   U=TPSU(X,Y) returns the matrix
%
%   [ U(|X(:,1) - Y(:,1)|) ... U(|X(:,1) - Y(:,N)|) ]
%   [                                               ]
%   [ U(|X(:,M) - Y(:,1)|) ... U(|X(:,M) - Y(:,N)|) ]
%
%   where X is a 2xM matrix and Y a 2xN matrix of points and U(r) is
%   the opposite -r^2 log(r^2) of the radial basis function of the
%   thin plate spline specified by X and Y.
%
%   [U,dU]=tpsu(x,y) returns the derivatives of the columns of U with
%   respect to the parameters Y. The derivatives are arranged in a
%   Mx2xN array, one layer per column of U.
%
%   See TPS.

if exist('tpsumx') 
	U = tpsumx(X,Y) ;
else  
  M=size(X,2) ;
  N=size(Y,2) ;
  
  % Faster than repmat, but still fairly slow
  r2 = ...
      (X(   ones(N,1), :)' - Y(  ones(1,M), :)).^2 + ...
      (X( 1+ones(N,1), :)' - Y(1+ones(1,M), :)).^2 ;
  U = - rb(r2) ;
end

if nargout > 1
  M=size(X,2) ;
  N=size(Y,2) ;

  dx = X(  ones(N,1), :)' - Y(  ones(1,M), :) ;
  dy = X(1+ones(N,1), :)' - Y(1+ones(1,M), :) ; 
  r2 = (dx.^2 + dy.^2) ;
  r = sqrt(r2) ;
  coeff = drb(r)./(r+eps) ;
  dU  = reshape( [coeff .* dx ; coeff .* dy], M, 2, N) ;
end

% The radial basis function
function y = rb(r2) 
y = zeros(size(r2)) ;
sel = find(r2 ~= 0) ;
y(sel) = - r2(sel) .* log(r2(sel)) ;

% The derivative of the radial basis function
function y = drb(r)
y = zeros(size(r)) ;
sel = find(r ~= 0) ;
y(sel) = - 4 * r(sel) .* log(r(sel)) - 2 * r(sel) ;


