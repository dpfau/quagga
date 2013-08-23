function x = recursiveFor(f,varargin)
% Given a function f that takes k arguments and k lists of arguments to pass,
% implements k nested for loops and returns a k-dimensional cell array of the
% result of applying this function with every combination of values

if length(varargin) > get(0,'RecursionLimit')
	set(0,'RecursionLimit',length(varargin))
end

n = find(cellfun(@(x) length(x)>1,varargin),1);
if isempty(n) % trivial case
	x = f(varargin{:});
elseif n == length(varargin) % base case
    x = cell(length(varargin{n}),1);
    for i = 1:length(varargin{n})
        x{i} = f(varargin{1:n-1},varargin{n}(i));
    end
else
    x = cell(cellfun(@length,varargin(n:end)));
	for i = 1:length(varargin{n})
        idx = cellfun(@(x)1:length(x),varargin(n+1:end),'UniformOutput',0);
		x(i,idx{:}) = ...
            recursiveFor(f,varargin{1:n-1},varargin{n}(i),varargin{n+1:end});
	end
end