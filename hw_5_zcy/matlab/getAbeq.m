function [Aeq beq]= getAbeq(n_seg, n_order, waypoints, ts, start_cond, end_cond)
    n_all_poly = n_seg*(n_order+1);
    %#####################################################
    % p,v,a,j constraint in start, 
    Aeq_start = zeros(4, n_all_poly);
    beq_start = zeros(4, 1);
    % STEP 2.1: write expression of Aeq_start and beq_start
    % i*(i-1)*...*(i-j+1)*ts(1)^(i-j)
    beq_start = start_cond.';
    for j = 0:3
        Aeq_start(j+1,j+1) = factorial(j); % this time j=k
    end
    %#####################################################
    % p,v,a,j constraint in end
    Aeq_end = zeros(4, n_all_poly);
    beq_end = zeros(4, 1);
    % STEP 2.2: write expression of Aeq_end and beq_end
    beq_end = end_cond.';
    for i = 0:3
        for j = i:n_order
            Aeq_end(i+1,j+1+(n_seg-1)*(n_order+1)) = factorial(j)/factorial(j-i)*ts(end)^(j-i);
        end
    end
    %#####################################################
    % position constrain in all middle waypoints
    Aeq_wp = zeros(n_seg-1, n_all_poly);
    beq_wp = zeros(n_seg-1, 1);
    % STEP 2.3: write expression of Aeq_wp and beq_wp
    for i = 1:n_seg-1
        Aeq_wp(i,1+i*(n_order+1)) = 1; % start pos of 2nd to last seg
        beq_wp(i) = waypoints(i+1);
    end
    %#####################################################
    % position continuity constrain between each 2 segments
    Aeq_con_p = zeros(n_seg-1, n_all_poly);
    beq_con_p = zeros(n_seg-1, 1);
    % STEP 2.4: write expression of Aeq_con_p and beq_con_p
    [Aeq_con_p, beq_con_p] = get_continuity_constraint(n_seg, n_order, ts, 0);
    %#####################################################
    % velocity continuity constrain between each 2 segments
    Aeq_con_v = zeros(n_seg-1, n_all_poly);
    beq_con_v = zeros(n_seg-1, 1);
    % STEP 2.5: write expression of Aeq_con_v and beq_con_v
    [Aeq_con_v, beq_con_v] = get_continuity_constraint(n_seg, n_order, ts, 1);
    %#####################################################
    % acceleration continuity constrain between each 2 segments
    Aeq_con_a = zeros(n_seg-1, n_all_poly);
    beq_con_a = zeros(n_seg-1, 1);
    % STEP 2.6: write expression of Aeq_con_a and beq_con_a
    [Aeq_con_a, beq_con_a] = get_continuity_constraint(n_seg, n_order, ts, 2);
    %#####################################################
    % jerk continuity constrain between each 2 segments
    Aeq_con_j = zeros(n_seg-1, n_all_poly);
    beq_con_j = zeros(n_seg-1, 1);
    % STEP 2.7: write expression of Aeq_con_j and beq_con_j
    [Aeq_con_j, beq_con_j] = get_continuity_constraint(n_seg, n_order, ts, 3);
    %#####################################################
    % combine all components to form Aeq and beq   
    Aeq_con = [Aeq_con_p; Aeq_con_v; Aeq_con_a; Aeq_con_j];
    beq_con = [beq_con_p; beq_con_v; beq_con_a; beq_con_j];
    Aeq = [Aeq_start; Aeq_end; Aeq_wp; Aeq_con];
    beq = [beq_start; beq_end; beq_wp; beq_con];
end

function [Aeq, beq] = get_continuity_constraint(n_seg, n_order, ts, order_deri)
    k = order_deri; % order of deri
    n_all_poly = n_seg*(n_order+1);
    Aeq = zeros(n_seg-1, n_all_poly);
    beq = zeros(n_seg-1, 1);
    for i = 1:n_seg-1
        for j = k:n_order
            Aeq(i,j+1+(i-1)*(n_order+1)) = factorial(j)/factorial(j-k)*ts(i)^(j-k); % end pos/vel/... of 1st to 2nd last seg
        end
        Aeq(i,1+k+i*(n_order+1)) = -factorial(k); % start pos/vel/... of 2nd to last seg, this time j=k, dont forget the minus sign!!!!!
        beq(i) = 0;
    end
end