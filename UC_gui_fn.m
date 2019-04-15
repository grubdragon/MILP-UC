function[Pit, Uit] = UC_gui_fn(units, demand, res_p)
%fields = ["Pmax", "Pmin", "a", "b", "c", "min_up", "min_down", "hot_start_cost", "cold_start_cost", "cold_start_hrs", "init_stat"];

% 5 UNIT DATA
%{
units = [[455,150,1000, 16.19, 0.00048, 8, 8, 4500, 9000, 5, 8];
         [130, 20, 700, 16.60, 0.002, 5, 5, 550, 1100, 4, -5];
         [130, 20, 680, 16.50, 0.00211, 5, 5, 560, 1120, 4, -5];
         [80, 20, 370, 22.26, 0.00712, 3, 3, 170, 340, 2, -3];
          [130, 20, 700, 16.60, 0.00413, 1, 1, 30, 60, 0, -1]];
%}

% 10 UNIT DATA
%{
units = [[455,150,1000, 16.19, 0.00048, 8, 8, 4500, 9000, 5, 8];
         [455,150,970, 17.26, 0.00031, 8, 8, 5000, 10000, 5, 8];
         [130, 20, 700, 16.60, 0.002, 5, 5, 550, 1100, 4, -5];
         [130, 20, 680, 16.50, 0.00211, 5, 5, 560, 1120, 4, -5];
         [162, 25, 450, 19.70, 0.00398, 6, 6, 900, 1800, 4, -6];
         [80, 20, 370, 22.26, 0.00712, 3, 3, 170, 340, 2, -3];
         [85, 25, 480, 27.74, 0.00079, 3, 3, 260, 520, 2, -3];
         [55, 10, 660, 25.92, 0.00413, 1, 1, 30, 60, 0, -1];
         [55, 10, 665, 27.27, 0.00222, 1, 1, 30, 60, 0, -1];
         [55, 10, 670, 27.79, 0.00173, 1, 1, 30, 60, 0, -1]];
%}

% demand vs time
%demand = [400,450,480,500,530,550,580,600,620,650,680,700,650,620,600,550,500,550,600,650,600,550,500,450,];
%demand = [700,750,850,950,1000,1100,1150,1200,1300,1400,1450,1500,1400,1300,1200,1050,1000,1100,1200,1400,1300,1100,900,800,];

reserve = res_p*demand;

% make a piecewise linear function of two pieces
lin_appx = [];
for i=1:size(units,1)
    p_m = (units(i,1)+units(i,2))/2;
    f_min = cost(units(i,3),units(i,4),units(i,5),units(i,2));
    s_1i = (cost(units(i,3),units(i,4),units(i,5),p_m)-f_min)/(p_m - units(i,2));
    s_2i = (cost(units(i,3),units(i,4),units(i,5),units(i,1)) - cost(units(i,3),units(i,4),units(i,5),p_m))/(units(i,1) - p_m);
    res = [p_m, s_1i, s_2i, f_min];
    lin_appx = vertcat(lin_appx,res);
end

units_mod = units;
units_mod = horzcat(units_mod, lin_appx);
units_mod(:, 3:5) = [];

% Deciding variables on x
% My ideology: club similar variables of different units, add constraints
% wherever possible, to avoid missing any since MATLAB itself will cut off
% any variables which are not required in its preprocessing. Might increase
% preprocessing time but willing to take the extra time increase

N = size(units,1);
T = size(demand,2);

u = optimvar('u', N, T,'Type','integer','LowerBound',0,'UpperBound',1);
y = optimvar('y', N, T,'Type','integer','LowerBound',0,'UpperBound',1);
z = optimvar('z', N, T,'Type','integer','LowerBound',0,'UpperBound',1);

p_it = optimvar('p_it', N, T);
%individual components of p_it
p_it_A = optimvar('p_it_A', N, T);
p_it_B = optimvar('p_it_B', N, T,'LowerBound',0);
p_it_C = optimvar('p_it_c', N, T,'LowerBound',0);

% Cold/Hot start
v = optimvar('v', N, T,'Type','integer','LowerBound',0,'UpperBound',1); % denotes cold start i.e. 1 if cold start
t_off = optimvar('t_off', N, T+1,'Type','integer','LowerBound',0);

prob = optimproblem('Objective', sum(units_mod(:,12)'*u) + sum(units_mod(:,10)'*p_it_B) + sum(units_mod(:,11)'*p_it_C) + sum(units_mod(:,5)'*y) + sum((units_mod(:,6)-units_mod(:,5))'*v));
%prob = optimproblem('Objective', sum(sum(u)));

%Total Power constraint
prob.Constraints.p_i_t = p_it == p_it_A + p_it_B + p_it_C;
prob.Constraints.p_i_t2 = sum(p_it,1) >= demand;

%Total Reserve constraint
prob.Constraints.res = sum(u.*(repmat(units_mod(:,1),1,T))-p_it,1) >= reserve;

%Unit power max min constraints
prob.Constraints.p_min = p_it >= repmat(units_mod(:,2),1,T).*u;
prob.Constraints.p_max = p_it <= repmat(units_mod(:,1),1,T).*u;

%Unit power approximation constraints
prob.Constraints.power_linappx_A = p_it_A == repmat(units_mod(:,2),1,T).*u;
prob.Constraints.power_linappx_B = p_it_B <= repmat(units_mod(:,9) - units_mod(:,2),1,T).*u;
prob.Constraints.power_linappx_C = p_it_C <= repmat(units_mod(:,1) - units_mod(:,9),1,T).*u;

%Unit startup shutdown constraints
constr_uyz = optimconstr(N,T-1);
for j=2:T
    constr_uyz(:,j-1) = u(:,j) - u(:, j-1) == y(:, j) - z(:, j);
end

prob.Constraints.constr_uyz = constr_uyz;
prob.Constraints.constr_yz = y + z <= 1;

% Min up+down time constraint
% Made new variables, each with a length going back in time atleast the
% maximum initial status. This was followed by setting their values using
% the init.

init_stat = units_mod(:,8);

up = init_stat>0;
down = init_stat<0;

min_up_gen = units_mod(:,3);
min_down_gen = units_mod(:,4);

zeta = min(T, (min_up_gen-init_stat).*up);

prob.Constraints.min_up_A = optimconstr(N);
prob.Constraints.min_up_B = optimconstr(N,T);

for i=1:N
    if zeta(i)>0
        prob.Constraints.min_up_A(i) = sum(1 - u(i,1:zeta(i)) ) == 0;
    end
    
    for k = zeta(i)+1:T-min_up_gen(i)+1
        prob.Constraints.min_up_B(i,k) = sum(u(i,k:k+min_up_gen(i)-1)) >= min_up_gen(i) * y(i,k);
    end
    
    for k = T-min_up_gen(i)+2:T
        prob.Constraints.min_up_B(i,k) = sum(u(i,k:T)-y(i,k:T)) >= 0;
    end
end


eta = min(T, (min_down_gen+init_stat).*down);

prob.Constraints.min_down_A = optimconstr(N);
prob.Constraints.min_down_B = optimconstr(N,T);

for i = 1:N
    if eta(i)>0
        prob.Constraints.min_down_A(i) = sum(u(i,1:eta(i))) == 0;
    end
    
    for k = eta(i)+1:T-min_down_gen(i)+1
        prob.Constraints.min_down_B(i,k) = sum(1-u(i,k:k+min_down_gen(i)-1)) >= min_down_gen(i) * z(i,k);
    end
    
    for k=T-min_down_gen(i)+2:T
        prob.Constraints.min_down_B(i,k) = sum(1-u(i,k:T)-z(i,k:T)) >= 0;
    end
end


% Hot start and cold start constraint
% Added new variables and now setting up some extra constants

M = 50; % sufficiently large constant s.t. constraint B is deactivated when u 0

prob.Constraints.t_off_A = t_off(:,1) == (units_mod(:, 8)<0) .* (-units_mod(:, 8));
prob.Constraints.t_off_B = t_off(:, 2:T+1) <= M*(1-y);

prob.Constraints.t_off_C = optimconstr(N, T);
for i=1 :T
    prob.Constraints.t_off_C(:, i) = t_off(:,i+1) - t_off(:, i) - 1 + u(:, i) <= M * y(:, i);
end

prob.Constraints.t_off_D = optimconstr(N, T);
for i=1:T
    prob.Constraints.t_off_D(:, i) = t_off(:,i+1) - t_off(:, i) - 1 + u(:, i) >= -M * y(:, i);
end

% Determining warm and cold start condition
kappa = T + max(init_stat);
eps1 = 1/(kappa+1);
eps2 = 1/(kappa+1+5);

prob.Constraints.t_off_E = optimconstr(N, T);
for i=1:T
    prob.Constraints.t_off_E(:, i) = v(:, i) >= y(:, i) - 1 - eps1 + eps2 *(t_off(:, i) - units_mod(:, 7));
end


problem = prob2struct(prob);
[sol,fval,exitflag,output] = intlinprog(problem);

Pit = reshape(sol(1:240), 10, 24);
Uit = reshape(sol(1211:1450), 10, 24);