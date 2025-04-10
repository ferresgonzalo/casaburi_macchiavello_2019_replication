clear all;
GG = (2:0.025:3)';        
sizeGG  = size(GG,1);  

%Set values for prices;
p = 31 ;
pd = 38 ;

%matrix of discount rates:  start from monthly and compute daily;
delta_yearly=(0.3:0.03:0.999)';
size=size(delta_yearly);
d=delta_yearly.^(1/365);

%Results matrix:mmonthly delta and a vector of gamma (to be filled);
R=[delta_yearly zeros(size)  ];

%Define monthly probability gamma
syms g;

%loop to solve for g ;
for i=1:size
    R(i,2)=min(1,vpasolve(p-1/30*d(i)*(1-g)*(1-d(i).^30)/(1-d(i))*pd == 0, g));
end



%main graph;
plot(R(:,1),R(:,2),'--r.')
annotation('textbox',...
    [.45 .22 .35 .10],...
    'String',{'Trader would not default'} )
annotation('textbox',...
    [.45 .70 .30 .10],...
    'String',{'Trader would default'} )
axis([0.3 1 0 0.5])
xlabel('\delta^Y: Yearly Discount Factor') % x-axis label
ylabel('\gamma: Monthly Probability Uninformed Farmer') % y-axis label
print('trader_IC_figure_180719','-depsc')
movefile('trader_IC_figure_180719.eps','../out')

