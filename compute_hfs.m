    function [Yu,Yl,Y,l_idx,u_idx,label] = compute_hfs(graph_type, graph_thresh)

%%%%%%%%%%%% the number of samples to generate
num_samples = 100;%100;

%%%%%%%%%%%% the sample distribution function with the options necessary for the
%%%%%%%%%%%% distribuion


sample_dist = @two_moons;
% [1,0.02,0] % 0.2 at first 
dist_options = [1, 0.02, 0]; % two moons: radius of the moons,
                          %        variance of the moons
                          %        number of mislabeled nodes

plot_results = 0;

if nargin < 1

    plot_results = 1;

    %%%%%%%%%%%% the type of the graph to build and the respective threshold

    %graph_type = 'knn';
    %graph_thresh = 7; % the number of neighbours for the graph

    graph_type = 'eps';
    graph_thresh = 0.15; % the epsilon threshold

end

%%%%%%%%%%%% similarity function
similarity_function = @exponential_euclidean;

%%%%%%%%%%%% similarity options
similarity_options = [0.5]; % exponential_euclidean: sigma

[X, Y] = get_samples(sample_dist, num_samples, dist_options);

%%%%%%%%%%%% automatically infer number of labels from samples
num_classes = length(unique(Y));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% randomly sample six labels                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while true 
    
idx_obs = round( length(Y)*rand(1, 30) );
if ~ sum( idx_obs == 0 )
    break;
end
end

% Yobs = Y( idx_obs );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use the build_similarity_graph function to build the graph W  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

W = build_similarity_graph(graph_type, graph_thresh, X, similarity_function, similarity_options);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% build the laplacian                                          %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

D = diag( sum(W,2) );
L = D - W;

dd = diag( D);
invsqrtD = diag( 1./ sqrt(dd) ) ;
invD = diag( 1./ dd ) ;

Lsym = eye( size(L,1)) -  invsqrtD * W * invsqrtD;
Lrw = eye( size(L,1) ) - invD * W; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute hfs solution                                      %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

l_idx = idx_obs;
u_idx = setdiff( 1:length(Y), l_idx) ;

Yl = zeros(length(l_idx),2);
% 2 classes
Yl(:,1) = (Y(l_idx)==2)*(-1) + ((Y(l_idx) == 1) )  ;
Yl(:,2) = - Yl(:,1);

Luu = L(u_idx, u_idx);
Wul = W(u_idx, l_idx);

Yu =  inv(Luu) * (Wul*Yl );% sol of Yl
% return;

diagC = ones(1,length(Y)) ;
diagC(u_idx) = abs( Yu(:,1) );
C = diag( diagC ) ;

SYl = zeros(length(Y),2); % SYl 
SYl ( l_idx, 1 ) = Y(l_idx);
SYl( l_idx, 2) = - Y(l_idx);
gamma = 1; % to be tuned / mentined in cours-5

Q = L + gamma*eye(size(L,1));
SYu =  ( inv(C)*Q + eye(length(Y)) )\SYl ;      % SYu
% soft version

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute the labels assignment from the HFS solution       %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[~, label ] = max(Yu, [],2) ;

% return;

[~, soft_label] = max(SYu, [], 2 );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

final_label = Y;
final_label(u_idx) = label;

if plot_results
    plot_classification(X,Y,W,final_label, soft_label);
end

