function x = x_analytic (t, Tp, n)

x = zeros(1, numel(t));
for ii=1:n
    x = x + 2/(ii*pi)*(1-cos(ii*pi))*sin(2*pi*ii*t/Tp);
end