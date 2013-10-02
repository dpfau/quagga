function RGB=showmask(V,M,display_flag,Vmin,Vmax)
% showmask(V,M);
%
% M is a nonneg. mask
% Jianbo Shi, 1997

if nargin < 5, Vmax = max(V(:)); end
if nargin < 4, Vmin = min(V(:)); end
V=V-Vmin;
V=V/(Vmax-Vmin);
%V=.25+0.75*V; %brighten things up a bit

M=M-min(M(:));
M=M/max(M(:));

H=0.0+zeros(size(V));
S=M;
RGB=hsv2rgb(H,S,V);

if display_flag
   image(RGB)
   axis('image')
end
