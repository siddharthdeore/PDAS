C     THIS PROGRAM USES "FLUID" TO DETERMINE PROPERTIES OF
C     HYDROGEN,OXYGEN,NITROGEN,ARGON,FLUORINE,STEAM,DRYAIR,CARBON
C    	DIOXIDE, OR METHANE
      REAL MU,K,MUL,MUV,KL,KV
      DIMENSION G(29,4),TT(27),DD(30),GG(27,30,8),SAT(35,8),C(8),M(4)
      INTEGER ENTRY,ERROR
      LOGICAL VAPOR
      DIMENSION PROPS(8)
      COMMON /FLUDPC/ G,TT,DD,GG,SAT,C,M,NG,N1,N2,N3,NS
      COMMON/FLUIDC/GAMMA,WL,WG,DENSL,DENSG,ENTL,ENTG,ENTHL,ENTHG
C
C     INPUT  ENTRY = 1 IS FOR T & RHO
C            ENTRY = 2 IS FOR P & RHO
C            ENTRY = 3 IS FOR T & P
C            ENTRY = 4 IS FOR P & S
C            ENTRY = 5 IS FOR P & H
C            KPROP = FLUID OPTION
C              1   = HYDROGEN
C              2   = OXYGEN
C              3   = NITROGEN
C              4   = ARGON
C              5   = FLUORINE
C              6   = STEAM
C              7   = DRYAIR
C              8   = CO2
C              9   = CH4
C     UNITS T = RANKINE (R)
C           P = PSIA
C           D = LBM/CU FT
C           H = BTU/LBM
C           S = BTU/LBM-R
C           CV = BTU/LBM-R
C           CP = BTU/LBM-R
C           SONIC = FT/SEC
C           MU = LBM/FT-SEC
C           K = BTU/FT-SEC-R
C
	WRITE (*,*) 'ENTER:P(PSIA),T(R),S(BTU/LBM-R),H(BTU/LBM),RHO(LBM/CU
     & FT),KPROP(1-9),ENTRY(1-5)'
      READ (*,*)P,T,S,H,RHO,KPROP,ENTRY
	WRITE(6,'(T35,A)')' INPUT DATA:'
	WRITE(6,*)' P=',P,' T  =',T,  ' S    =',S
      WRITE(6,*)' H=',H,' RHO=',RHO,' ENTRY=',ENTRY
C	INITIALIZE FLUID VARIABLES FOR THE DESIRED FLUID.
	IF (KPROP.EQ.1) THEN
		WRITE(6,*)'HYDROGEN'
         CALL PH2
	ELSE IF (KPROP.EQ.2) THEN
		WRITE(6,*)'OXYGEN'
         CALL O2
	ELSE IF (KPROP.EQ.3) THEN
		WRITE(6,*)'NITROGEN'
         CALL NITRO
	ELSE IF (KPROP.EQ.4) THEN
		WRITE(6,*)'ARGON'
         CALL AR
	ELSE IF (KPROP.EQ.5) THEN
		WRITE(6,*)'FLUORINE'
         CALL F2
	ELSE IF (KPROP.EQ.6) THEN
		WRITE(6,*)'STEAM'
         CALL STEAM
	ELSE IF (KPROP.EQ.7) THEN
		WRITE(6,*)'DRYAIR'
         CALL DRYAIR
	ELSE IF (KPROP.EQ.8) THEN
		WRITE(6,*)'CARBON DIOXIDE'
         CALL CO2
	ELSE IF (KPROP.EQ.9) THEN
		WRITE(6,*)'METHANE'
         CALL CH4
	ENDIF
	WRITE(6,'(//T35,A)')'OUTPUT DATA:'
C	CONVERSIONS TO INPUT DATA FOR FLUID
C	CONVERT PRESSURE IN PSI TO MPA AND TEMPERATURE IN R TO K
C	CONVERT DENSITY IN LB/FT3 TO G/CM3
C	CONVERT ENTROPY IN BTU/LB-R TO J/GM-K
C	CONVERT ENTHALPY IN BTU/LBM TO J/GM
      P = P/145.04
      T = T/1.8
      RHO = RHO/62.428
      PROPS(2) = S/.23901
      PROPS(3) = H/.43022
C	GET FLUID PROPERTIES
      CALL FLUID(T,P,RHO,PROPS,8,ENTRY,VAPOR,ERROR,1)
      IF(ERROR.NE.0)   WRITE(6,*)ERROR
      T = T*1.8
      P = P*145.04
C	IF FLUID IS SATURATED.....
      IF (VAPOR) THEN
         SL = ENTL*.23901
         SV = ENTG*.23901
         HL = ENTHL*.43022
         HV = ENTHG*.43022
         RHOL = DENSL*62.428
         RHOV = DENSG*62.428
         NP = 8
C	   GET THE TRANSPORT PROPERTIES FOR SATURATED LIQUID
         CALL FLUID(T,P,RHO,PROPS,8,ENTRY,VAPOR,ERROR,2)
         ZL=PROPS(1)
         CVL = PROPS(4)*.23901
         CPL = PROPS(5)*.23901
         CL = PROPS(6)*103.83
         MUL = PROPS(7)*.067198
         KL = PROPS(8)*.016061
         GAMMAL = CPL/CVL
C	   GET THE TRANSPORT PROPERTIES FOR SATURATED GAS
         CALL FLUID(T,P,RHO,PROPS,8,ENTRY,VAPOR,ERROR,3)
         ZV=PROPS(1)
         CVV = PROPS(4)*.23901
         CPV = PROPS(5)*.23901
         CV = PROPS(6)*103.83
         MUV = PROPS(7)*.067198
         KV = PROPS(8)*.016061
         GAMMAV = CPV/CVV
         WRITE(6,1000) P,T,ZL,ZV,SL,SV,HL,HV,RHOL,RHOV,CVL,CVV,
     &              CPL,CPV,CL,CV,GAMMAL,GAMMAV,MUL,MUV,KL,KV
 1000	FORMAT (' P=',G10.3,' PSI',T40,'T=',G10.3,' R'/
     &T20,'SATURATED LIQUID',T50,'SATURATED VAPOR'/
     &  ' COMPRESSIBILITY',T25,G10.3,T55,G10.3/
     &  ' ENTROPY(BTU/LBM-R)',T25,G10.3,T55,G10.3/
     &  ' ENTHALPY(BTU/LBM)',T25,G10.3,T55,G10.3/
     &  ' DENSITY(LBM/FT3)',T25,G10.3,T55,G10.3/
     &  ' CV(BTU/LBM-R)',T25,G10.3,T55,G10.3/
     &  ' CP(BTU/LBM-R)',T25,G10.3,T55,G10.3/
     &  ' SONIC VELOCITY(FT/S)',T25,G10.3,T55,G10.3/
     &  ' CP/CV',T25,G10.3,T55,G10.3/
     &  ' VISCOSITY(LBM/FT-S)',T25,G10.3,T55,G10.3/
     &  ' THERM. COND.(BTU/FT-S-R)',T25,G10.3,T55,G10.3)

	ELSE
         RHO = RHO*62.428
         Z=PROPS(1)
         S = PROPS(2)*.23901
         H = PROPS(3)*.43022
         CV = PROPS(4)*.23901
         CP = PROPS(5)*.23901
         SONIC = PROPS(6)*103.83
         MU = PROPS(7)*.067198
         K = PROPS(8)*.016061
         WRITE(6,1100) P,T,Z,S,H,RHO,CV,CP,GAMMA,SONIC,MU,K
      ENDIF
      STOP
 1100	FORMAT (' P=',G10.3,' PSI',T40,'T=',G10.3,' R'/
     &  ' COMPRESSIBILITY',T25,G10.3/
     &  ' ENTROPY(BTU/LBM-R)',T25,G10.3/
     &  ' ENTHALPY(BTU/LBM)',T25,G10.3/
     &  ' DENSITY(LBM/FT3)',T25,G10.3/
     &  ' CV(BTU/LBM-R)',T25,G10.3/
     &  ' CP(BTU/LBM-R)',T25,G10.3/
     &  ' CP/CV',T25,G10.3/
     &  ' SONIC VELOCITY(FT/S)',T25,G10.3/
     &  ' VISCOSITY(LBM/FT-S)',T25,G10.3/
     &  ' THERM.COND.(BTU/FT-S-R)',T25,G10.3)
      END
