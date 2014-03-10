% Setting random state to get constant answers
randn('state',23432);
rand('state',3454);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Variables that will be used throughout the
% Program can be either set up randomly, obtained
% through the Yahoo Finance API, or read from a 
% file. Please comment/uncomment the following code
% as required to enable/disable these features


%%%%%%%%%%%%%%%% SET UP RANDOMLY %%%%%%%%%%%%%%%%
% roundcoeficient = 99;
% T = 100; % Total number of samples per hist set
% totalassets = 5;
% % Matrix containing historical return for all current assets
% fR = floor(roundcoeficient * rand(T,totalassets)+1);
% % Matrix containing historical returns for index assets
% fI = floor(roundcoeficient * rand(T,totalassets)+1);
% T = T-1;


%%%%%%%%%%%%%%%%%%% Yahoo Finance %%%%%%%%%%%%%%%
% qtimeout = 3;
% y = yahoo;
% % RIGHT NOW WE HAVE AN FPSE 99 BECAUSE 'CCH.L' DOES NOT FETCH!
% % securities = {'AAL.L','ABF.L','ADM.L'}%,'ADN.L','AGK.L','AMEC.L','ANTO.L','ARM.L','AV.L','AZN.L','BA.L','BAB.L','BARC.L','BATS.L','BG.L','BLND.L','BLT.L','BNZL.L','BP.L','BRBY.L','BSY.L','BT-A.L','CCL.L','CNA.L','CPG.L','CPI.L','CRDA.L','CRH.L','DGE.L','EXPN.L','EZJ.L','FRES.L','GFS.L','GKN.L','GLEN.L','GSK.L','HL.L','HMSO.L','HSBA.L','IAG.L','IHG.L','IMI.L','IMT.L','ITRK.L','ITV.L','JMAT.L','KGF.L','LAND.L','LGEN.L','LLOY.L','LSE.L','MGGT.L','MKS.L','MNDI.L','MRO.L','MRW.L','NG.L','NXT.L','OML.L','PFC.L','PRU.L','PSN.L','PSON.L','RB.L','RBS.L','RDSA.L','RDSB.L','REL.L','REX.L','RIO.L','RR.L','RRS.L','RSA.L','RSL.L','SAB.L','SBRY.L','SDR.L','SGE.L','SHP.L','SL.L','SMIN.L','SN.L','SPD.L','SSE.L','STAN.L','SVT.L','TATE.L','TLW.L','TPK.L','TSCO.L','TT.L','ULVR.L','UU.L','VED.L','VOD.L','WEIR.L','WMH.L','WOS.L','WPP.L'};
% securities = {'BBRY','YHOO'}
% index = '^FTSE';
% totalassets = size(securities,2);
% timeformat = 'd';
% fieldname = 'close';
% dtTimeFrom = '11/1/2011';
% dtTimeUntil = '12/1/2012';
% 
% % Fetching Index prices
% disp(index);
% fetched = fetch(y,index,fieldname,dtTimeFrom,dtTimeUntil,timeformat);
% fI = fetched(:,2);
% 
% fR = [];
% for i = 1:totalassets
%     symbol = securities(i);
%     disp(symbol);
%     
%     fetched = fetch(y,symbol,fieldname,dtTimeFrom,dtTimeUntil,timeformat);
%     
%     fR = [fR, fetched(:, 2)];
% end
% 
% T = min(size(fI, 1),size(fR, 1)) - 1; % Minus one because returns will have one less

%%%%%%%%%%%%%%%%%%% From File %%%%%%%%%%%%%%%%%%
fI = importdata('FPSEOnlyData');
fR = importdata('FPSESecuritiesData');
% fI = fI(1:100,1);
% fR = fR(1:100,1:50
% fR = fR(:,10:20);
T = size(fI, 1) - 1;
totalassets = size(fR,2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Returns and Proportions %%%%%%%%%%%%

% Generating Portfolio proportion random matrix with rows adding to 1
% pimat = rand(totalassets, 1); 
% pimat = pimat / sum(pimat, 1); % Each value over the total of the sum of
% columns

% Calculating returns for all individual assets
R = [];
for i = 1:totalassets
    
    returns = [];
    
    for curr = 2:(T+1)
        returns = [returns, fR(curr, i) / fR(curr-1, i)];
    end
    
    R = [R; returns];
end

% Calculating returns for Index
I = mean(R)';

% I = [];
% for curr = 2:(T+1)
%     I = [I; fI(curr) / fI(curr-1)];
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Hard Coded Test Data %%%%%%%%%%%%%%
% T = 12;
% totalassets = 100;
% 
% I = 0.95+(.1).*rand(T,1);
% R = [];
% for i = 1:totalassets
%     R = [R , I + (0.025 - (0.05).*rand(T,1))];
% end
% R = transpose(R)
% R = fliplr(R)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% MAIN CVX PROGRAM %%%%%%%%%%%%%%%
Beta = 0.8;
k = 1;
C = 1/sqrt(totalassets) + k*(1-1/sqrt(totalassets))/(10*sqrt(totalassets));
divcoef = 1 / (T*(1-Beta));

%%%%%%%%%%%%%%%%%% Calculations %%%%%%%%%%%%%%%%%
% C2 = 20
% 
% % CVX to find optimal value for NCCVAR
% cvx_begin % quiet
%     variable z_n(T)
%     variable Alpha_n
%     variable pimat_n(totalassets)
%     minimize( Alpha_n + divcoef * sum(z_n) )
%     subject to
%         z_n >= 0
%         z_n - abs(I - transpose(R)*pimat_n) + Alpha_n >= 0
% %         norm(pimat_n) < C
%         nnz(lt(.0000001,pimat_n)) > C2
%         % QUESTION: If the following constraint is not set, pi is given
%         % negative numbers, should this constrain be added? the constraints
%         % are is specified in the paper when tracking variance is
% %         introduced 
%         pimat_n >= 0
%         sum(pimat_n) == 1
% cvx_end
% 
% % CVX to find optimal value for CVAR
% cvx_begin 
%     variable z_c(T)
%     variable Alpha_c
%     variable pimat_c(totalassets)
%     minimize( Alpha_c + divcoef * sum(z_c) )
%     subject to
%         z_c >= 0
% %         transpose(z_c)*z_c <= power(C,2)
%         transpose(R)*pimat_c + Alpha_c + z_c >= 0
%         norm(pimat_c) < C
%         pimat_c >= 0
%         sum(pimat_c) == 1
% cvx_end
% 
% % CVX to find optimal value for Tracking Error Abs
% cvx_begin 
%     variable z_a(T)
%     variable pimat_a(totalassets)
%     minimize( (1/T) * sum(z_a) )
%     subject to
%         z_a >= 0
% %         transpose(z_c)*z_c <= power(C,2)
%         z_a - abs(I - transpose(R)*pimat_n) >= 0
%         norm(pimat_a) < C
%         pimat_a >= 0
%         sum(pimat_a) == 1
% cvx_end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% TRACKING ERROR %%%%%%%%%%%%%%%
% % In this case our distribution for the ratio 
% % invested on each stock is equal, adding to 1
% balancedpimat = ones(totalassets,1) / totalassets; 
% % Formula to Calculate Tracking Error
% totalSum = 0;
% z_tracking_err = [];
% for i = 1:T
%     iRet = I(i);
%     currR = R(:,i);
%     mRet = transpose(currR) * balancedpimat;
%     currErr = iRet - mRet;
%     absSum = abs(currErr);
%     z_tracking_err = [z_tracking_err ; absSum]
% end
% 
% pimats = [pimat_n, pimat_c];
% allz = [z_n, z_c, z_tracking_err];




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Tracking error of Portfolio Subset %%%%%%%
%Initialize
step = 12
curr = step

all_pimat_n = [];
all_pimat_c = [];
all_pimat_a = [];
all_pimat_l = [];

pimats_n = [];
pimats_c = [];
pimats_a = [];
pimats_l = [];


idx = [];

disp('Calculating Tracking Errors');
disp('totalassets=');
disp(totalassets);

% This loop can be used to test the behaviour of k and B
for i = 1:1

    Beta = .3;
    k = 5;
    divcoef = 1 / (T*(1-Beta));
    delta = 10;
    
    curr = step
    
    te_n = [];
    te_c = [];
    te_a = [];
    te_l = [];
    idx = [];
    
    while curr <= totalassets
        disp(curr);

        total_n = 0;
        total_c = 0;
        total_a = 0;
        total_l = 0;

        currR = R(1:curr,:);

        C = 1/sqrt(curr) + k*(1-1/sqrt(curr))/(10*sqrt(curr));

        clearvars pimat_n pimat_c pimat_a;
        clearvars Alpha_n Alpha_c Alpha_a;
        clearvars z_n z_c z_a;

        % CVX to find optimal value for NCCVAR
        cvx_begin quiet
            variable z_n(T)
            variable Alpha_n
            variable pimat_n(curr)
            minimize( Alpha_n + divcoef * sum(z_n) )
            subject to
                z_n >= 0
                z_n - abs(I - transpose(currR)*pimat_n) + Alpha_n >= 0
                
                % QUESTION: This constrain ensures that less assets have a position of 0?
                % (Also performs better without this constrain)
                norm(pimat_n) <= C
                pimat_n >= 0
                sum(pimat_n) == 1
        cvx_end

        % CVX to find optimal value for CVAR
        cvx_begin quiet
            variable z_c(T)
            variable Alpha_c
            variable pimat_c(curr)
            minimize( Alpha_c + divcoef * sum(z_c) )
            subject to
                z_c >= 0
        %         transpose(z_c)*z_c <= power(C,2)
                transpose(currR)*pimat_c + Alpha_c + z_c >= 0
                pimat_c >= 0
                sum(pimat_c) == 1
                
                % QUESTION: Should this norm constraint be in CVAR as well?
                % Note: This performs better without this constraint
                norm(pimat_c) <= C
        cvx_end

        % CVX to find optimal value for Tracking Error Abs
        cvx_begin quiet
            variable z_a(T)
            variable pimat_a(curr)
            minimize( (1/T) * sum(z_a) )
            subject to
                z_a >= 0
        %         transpose(z_c)*z_c <= power(C,2)
                z_a - abs(I - transpose(currR)*pimat_a) >= 0
                pimat_a >= 0
                sum(pimat_a) == 1
                % QUESTION: Should this norm constraint be in CVAR as well?
                norm(pimat_a) <= C
        cvx_end
        
        % CVX to find optimal value for Lasso
        cvx_begin quiet
            variable z_l(T)
            variable pimat_l(curr)
            % This is the same as: minimize( sum(power(I - transpose(currR)*pimat_l, 2) + delta * sum(pimat_l)) )
            minimize( sum(z_l) )
            subject to
                z_l >= 0
        %         transpose(z_c)*z_c <= power(C,2)
                z_l - power(I - transpose(currR)*pimat_l, 2) - delta * sum(pimat_l) >= 0
                pimat_l >= 0
                sum(pimat_l) == 1
                
                % QUESTION: Should this norm constraint be in CVAR as well?
                % Note: This performs better without this constraint
                norm(pimat_l) <= C
        cvx_end

        % Calculating Tracking Error
        Ret_n = abs(I - transpose(currR) * pimat_n);
        Ret_c = abs(I - transpose(currR) * pimat_c);
        Ret_a = abs(I - transpose(currR) * pimat_a);
        Ret_l = abs(I - transpose(currR) * pimat_l);

        % Tracking Errors
        te_n = [te_n; sum(Ret_n)];
        te_c = [te_c; sum(Ret_c)];
        te_a = [te_a; sum(Ret_a)];
        te_l = [te_l; sum(Ret_l)];

        pimats_n = [pimats_n, [pimat_n ; zeros(totalassets-curr,1)] ];
        pimats_c = [pimats_c, [pimat_c ; zeros(totalassets-curr,1)] ];
        pimats_a = [pimats_a, [pimat_a ; zeros(totalassets-curr,1)] ];
        pimats_l = [pimats_l, [pimat_l ; zeros(totalassets-curr,1)] ];

        idx = [idx ; curr];

        if(curr == totalassets) 
            break;
        end

        curr = min(curr + step, totalassets); 

    end
    
    all_pimat_n = [all_pimat_n, te_n];
    all_pimat_c = [all_pimat_c, te_c];
    all_pimat_a = [all_pimat_a, te_a]; 
    all_pimat_l = [all_pimat_l, te_l]; 
    
    figure(i);
%     plot(idx,all_pimat_n(:,i),'black', idx,all_pimat_c(:,i),'red', idx,all_pimat_a(:,i),'blue', idx,all_pimat_l(:,i),'green');
    plot(idx,all_pimat_n(:,i),'black', idx,all_pimat_a(:,i),'blue', idx,all_pimat_l(:,i),'green');
end

% legend('NCCVAR', 'CVAR', 'ABS', 'LASSO');
legend('NCCVAR', 'ABS', 'LASSO');

count_n = 0;
count_l = 0;
count_a = 0;
count_c = 0;


for i = 1:totalassets
    if(pimat_n(i) < 0.0001)
        count_n = count_n+1;
    end
    
    if(pimat_l(i) < 0.0001)
        count_l = count_l+1;
    end
    
    if(pimat_a(i) < 0.0001)
        count_a = count_a+1;
    end
    
    if(pimat_c(i) < 0.0001)
        count_c = count_c+1;
    end
end

count_n
count_l
count_a
% count_c


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Plotting Results %%%%%%%%%%%%%%%
% RR_n = transpose(R) * pimat_n;
% RR_c = transpose(R) * pimat_c;
% RR_a = transpose(R) * pimat_a;
% 
% idx = transpose(linspace(1,T,T));
% figure(1)
% plot(idx,RR_n,'red', idx,RR_c,'blue', idx,RR_a,'green', idx,I,'black');





% Checking z on behaviour of Alpha
% alphamat = transpose(linspace(0,.2,20));
% alphabehaviour = [];
% for i = 1:size(alphamat)
%     disp(i);
%     curralpha = alphamat(i);
%     z = [];
%     cvx_begin quiet
%         variable z(T)
%         minimize( divcoef * sum(z) )
%         subject to
%             z >= 0
%             z - abs(I - transpose(R)*pimat) + curralpha >= 0
%     cvx_end
%     alphaans = curralpha + divcoef * sum(z,1);
%     alphabehaviour = [alphabehaviour; curralpha, alphaans];
% end
% figure(3)
% plot(alphabehaviour(:,1),alphabehaviour(:,2))


% Checking z on behaviour of Beta
% betamat = transpose(linspace(0,.99,20));
% betabehaviour = [];
% for i = 1:size(betamat)
%     disp(i);
%     currbeta = betamat(i);
%     divcoef = 1 / (T*(1-currbeta));
%     z = [];
%     cvx_begin quiet
%         variable z(T)
%         minimize( divcoef * sum(z) )
%         subject to
%             z >= 0
%             z - abs(I - transpose(R)*pimat) + Alpha >= 0
%     cvx_end
%     betaans = Alpha + divcoef * sum(z,1);
%     betabehaviour = [betabehaviour; currbeta, betaans];
% end
% figure(4)
% plot(betabehaviour(:,1),betabehaviour(:,2))