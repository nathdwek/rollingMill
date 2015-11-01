function current = lmController(speedRef, measuredSpeed)
    FRICTION_COMPENSATOR = 2.7;
    KP = 2;
    KI = KP/3.642;
    
    errorIntegral = 0;
    
    error = speedRef - measuredSpeed;
    errorIntegral = errorIntegral + error*T_S;
    
    current = FRICTION_COMPENSATOR + KP*error + KI*errorIntegral;
    
