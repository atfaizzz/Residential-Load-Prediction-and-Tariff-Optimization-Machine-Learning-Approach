scenario_selection
activities
if xeimonas==1
    thermos1=zeros(1,96);
    thermos2=zeros(1,96);
    thermopower=2400;
    tsys2=92;
    tsys1=20;
    for f=1:1:p
        if f<=tsys1
            thermos1(f)=thermopower;
        end
    end
    for xx=(tsys2):1:p
        thermos2(xx)=thermopower;
    end
else
    thermos1=zeros(1,96);
    thermos2=zeros(1,96);
end
lthermosys=thermos1+thermos2;
