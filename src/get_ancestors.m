function ancestor_set = get_ancestors(G)
% Given a directed graph G
% find all sets of ancestors from a given node which are not subsets of any
% other such sets

subset = @(x,y) length(unique(x)) == length(intersect(x,y));
N = size(G,1);
[parents, children] = find(G);
ancestor_list = cell(N,1);
for n = 1:N
    if isempty(ancestor_list{n})
        ancestor_list{n} = ancestor_recurse(n,parents,children,[],zeros(N,1));
    end
end

% find the ancestor sets that are subsets of no other sets. 
% there's probably a way to do this in linear time, but this should work fine.
S = zeros(N);
for m = 1:N 
    for n = [1:m-1,m+1:N]
        if subset(ancestor_list{n},ancestor_list{m})
            S(m,n) = true;
            if S(n,m) % the sets are mutual subsets, therefore equal
                S(n,m) = false;
            end
        end
    end
end
ancestor_set = ancestor_list(sum(S)==0);

    function [ancestors, visited] = ancestor_recurse(idx,parents,children,ancestors,visited)
        visited(idx) = 1;
        if isempty(ancestor_list{idx})
            ancestors = union(ancestors, idx);
            for i = find(children' == idx)
                p = parents(i);
                if ~visited(p)
                    [ancestors, visited] = ancestor_recurse(p,parents,children,ancestors,visited);
                end
            end
        else
            ancestors = union(ancestors, ancestor_list{idx});
        end
    end
end