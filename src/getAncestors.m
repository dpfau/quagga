function ancestorSet = getAncestors(G)
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
        if subset(ancestorList{n},ancestorList{m})
            S(m,n) = true;
            if S(n,m) % the sets are mutual subsets, therefore equal
                S(n,m) = false;
            end
        end
    end
end
ancestorSet = ancestorList(sum(S)==0);

    function [ancestors, visited] = ancestorRecurse(idx,parents,children,ancestors,visited)
        visited(idx) = 1;
        if isempty(ancestorList{idx})
            ancestors = union(ancestors, idx);
            for i = find(children' == idx)
                p = parents(i);
                if ~visited(p)
                    [ancestors, visited] = ancestorRecurse(p,parents,children,ancestors,visited);
                end
            end
        else
            ancestors = union(ancestors, ancestorList{idx});
        end
    end
end