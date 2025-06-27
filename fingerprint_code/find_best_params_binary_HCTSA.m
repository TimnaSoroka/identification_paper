function [params,prop]=find_best_params_binary_HCTSA(v_to_opt,l_to_opt,x)
%rng(5)
n=10000;
y=3;
for i=1:n
       p{i}=randperm(size(v_to_opt,2),y);
       [~,val_acc(i)]=linearDisc(v_to_opt(:,p{i}),l_to_opt);
end

l=prctile(val_acc,90);
f=find(val_acc>=l);
best=[p{f}];
for ii=1:x
    params(ii)=mode(best);
    score(ii)=sum(best==params(ii));
    best(best==params(ii))=[];
end

% par{1}=params;
% [~,acc_chosen1]=linearDisc(v_to_opt(:,par{1}),l_to_opt);
% 
% opt=fscmrmr(v_to_opt,l_to_opt);
% par{2}=opt(1:x);
% [~,acc_chosen2]=linearDisc(v_to_opt(:,par{2}),l_to_opt);
% 
% w=fscnca(v_to_opt,l_to_opt);
% [~,opt]=sort(w.FeatureWeights,'descend');
%           par{3}=opt(1:x);
% [~,acc_chosen3]=linearDisc(v_to_opt(:,par{3}),l_to_opt);
% 
% opt=fscchi2(v_to_opt,l_to_opt);
% par{4}=opt(1:x);
% [~,acc_chosen4]=linearDisc(v_to_opt(:,par{4}),l_to_opt);
% 
% [~,idx]=max([acc_chosen1;acc_chosen2;acc_chosen3;acc_chosen4]);
% params=par{idx};

prop.rep=n;
prop.num_parameters=x;
prop.n_to_class=y;
end