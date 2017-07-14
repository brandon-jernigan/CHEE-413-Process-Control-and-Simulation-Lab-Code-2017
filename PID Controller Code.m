%neutral is 6.5 half rotations from wide open
loop = 1; position = 0; t0 = 0; e0 = 0; integralarray = [];
pinMode(a,12,'output'); pinMode(a,9,'output');
uicontrol('style', 'text', 'string', 'hsp', 'position', ...
    [15 80 20 15]); 
u = uicontrol('style', 'edit', 'string', '10', 'position', ...
    [10 60 30 20]); %initial set point
uicontrol('style', 'pushbutton', 'position', ...
    [10 10 30 25], 'string', 'quit', 'callback', ...
    'loop = 0'); %quit button
uicontrol('style', 'text', 'string', 'v:', 'position', ...
    [10 100 10 15]); 
positiongui = uicontrol('style', 'text', 'string', num2str(position), 'position', ...
    [20 100 20 15]); %valve position tracker
analogWrite(a,3,255); %speed of motor
maxposition = 4; minposition = -4.5; %valve limits
Kc = 0.1;
ti = 1000;
td = 0.1;
tic %clock initiate
while loop == 1
    set(positiongui, 'string', num2str(position)); %refresh valve position tracker
    av=analogRead(a,3); 
    v=(av/1023)*5; 
    h=15.225*v-28.928; %read height of tank
    A = get(u, 'string');
    hsp = str2double(A);
    e=h-hsp %error between current height and set point
    de = e - e0; %difference between error and past error
    e0 = e;
    dt = toc - t0; %time interval
    t0 = toc;
    integral = e*dt;
    integralarray = [integralarray integral];
    pcontrol = e
    icontrol = sum(integralarray)/ti
    dcontrol = td*(de/dt)
    pid = Kc*(pcontrol + icontrol + dcontrol)
    plot(toc,hsp,'r.');
    plot(toc,h,'k.');
    hold on
    xlim('auto');
    ylim([0 20]);
    if pid > 0
        if position > minposition
            digitalWrite(a,9,0); %release brake
            digitalWrite(a,12,0); %close direction
            pause(abs(pid)); %time to close valve
            digitalWrite(a,9,1); %engage brake
            position = position - (abs(pid));
            if position < minposition
                position = minposition;
            end
        end
    end
    if pid < 0
        if position < maxposition
            digitalWrite(a,9,0); %release brake
            digitalWrite(a,12,1); %open direction
            pause(abs(pid)); %time to open valve
            digitalWrite(a,9,1); %engage brake
            position = position + (abs(pid));
            if position > maxposition
                position = maxposition;
            end
        end
    end
    if toc > 100
        set(u, 'string', num2str(5)); %auto change set point for consistent graphing
    end
    if toc > 500
        set(u, 'string', num2str(10)); %auto change set point for consistent graphing
    end
    pause(0.2)
end