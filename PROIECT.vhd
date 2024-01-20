library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity VGA is
    Port ( CLK :      in  STD_LOGIC;
           RST :      in  STD_LOGIC;
           HSYNC :    inout  STD_LOGIC;
           VSYNC :    inout  STD_LOGIC;
           ROSU :     inout STD_LOGIC;
		   VERDE :    inout STD_LOGIC;
		   ALBASTRU : inout STD_LOGIC;
		   SUS :      in STD_LOGIC;
		   JOS :      in STD_LOGIC;
		   STANGA :   in STD_LOGIC;
		   DREAPTA :  in STD_LOGIC;
		   SELECTIE : in STD_LOGIC_VECTOR ( 2 downto 0);
		   CULOARE :  in STD_LOGIC_VECTOR ( 2 downto 0);
		   ANOD:      out STD_LOGIC_VECTOR(3 downto 0);
		   CATOD:     out STD_LOGIC_VECTOR(6 downto 0)); 
end vga;

architecture ARH_VGA of VGA is
	
	signal CLK25 : std_logic := '0';
	signal CLK50 : std_logic := '0';
	
	constant hActive : integer := 640;  --  639   Horizontal Display (640)
	constant HFP : integer := 16;         --   16   Right border (front porch)
	constant hSynch : integer := 96;       --   96   Sync pulse (Retrace)
	constant HBP : integer := 48;        --   48   Left boarder (back porch)
	
	constant vActive : integer := 480;   --  479   Vertical Display (480)
	constant VFP : integer := 9;       	 --   10   Right border (front porch)
	constant vSynch : integer := 2;				 --    2   Sync pulse (Retrace)
	constant VBP : integer := 29;       --   33   Left boarder (back porch)	 
	
	constant hTotal : integer := 800;
	constant vTotal : integer :=525;
	
	signal hPos : integer := 0;
	signal vPos : integer := 0;
	
	signal videoOn : std_logic := '0';
	
	signal Rosu_aux,Verde_aux,Albastru_aux : std_logic := '0';   
	
	signal X : integer :=240;
	signal Y : integer :=320;
	
	signal Sus_aux, Jos_aux, Stanga_aux, Dreapta_aux : std_logic := '0';
begin


process(CLK)	 --Divizor frecventa din 100 mHZ in 50 mHZ
    begin
	if(rising_edge(CLK))then
		clk50 <= not clk50;
	end if;
end process;


process(CLK50)	--Divizior frecventa din 50 mHZ in 25 mHZ
    begin
	if(rising_edge(CLK50))then
		clk25 <= not clk25;
	end if;
end process;

process(clk25, RST) --Numarator pentru orizontala
    begin
	if(RST = '1')then
		hPos <= 0;
	elsif rising_edge(CLK25) then
		if (hPos = (hTotal)) then
			hPos <= 0;
		  else
			hPos <= hPos + 1;
		end if;
	end if;
end process;


process(clk25, RST, hPos)	--Numarator pentru verticala
    begin
	if(RST = '1')then
		vPos <= 0;
	elsif(rising_edge(CLK25))then  
		if(hPos = (hTotal))then
			if (vPos = (vTotal)) then
				vPos <= 0;
			 else
				vPos <= vPos + 1;
			end if;
		end if;
	end if;
end process;

process(clk25, RST, hPos)	--HSYNC
    begin
	if(RST = '1')then
		HSYNC <= '0';
	elsif(rising_edge(CLK25))then
		if((hPos <= (hActive + hFP)) OR (hPos > hActive + HFP + HSynch))then
			HSYNC <= '1';
		  else
			HSYNC <= '0';
		end if;
	end if;	 
end process;

process(clk25, RST, vPos)	--VSYNC
    begin
	if(RST = '1')then
		VSYNC <= '0';
	elsif(rising_edge(CLK25))then
		if((vPos <= (vActive + VFP)) OR (vPos > vActive + VFP + VSynch))then
			VSYNC <= '1';
		  else
			VSYNC <= '0';
		end if;
	end if;
end process;

process(clk25, RST, hPos, vPos)	 --PROCES PENTRU ZONA IN CARE VOM DESENA
    begin
	if(RST = '1')then
	   videoOn<='0';
	elsif(rising_edge(CLK25))then
	    if(hPos <= hActive and vPos <= vActive)then
		   videoOn <= '1';
		  else
	       videoOn <= '0';
		 end if;
	 end if;	 
end process;



process(clk25, CULOARE)	  --PROCES PENTRU ALEGEREA CULORILOR,IN FUNCTIE DE SELECTIA CULOARE
	begin
	if(rising_edge(CLK25))then
	   -- rosu
			if(CULOARE = "000")  then
				Rosu_aux<='1';
				Verde_aux<='0';
				Albastru_aux<='0';
	   -- verde
			elsif(CULOARE = "001")  then
				Rosu_aux<='0';			
				Verde_aux<='1';
				Albastru_aux<='0';
		-- albastru
			elsif(CULOARE = "010")  then
				Rosu_aux<='0';			
				Verde_aux<='0';
				Albastru_aux<='1';
		-- galben
			elsif(CULOARE = "011")  then
				Rosu_aux<='1';			
				Verde_aux<='1';
				Albastru_aux<='0';
		-- violet
			elsif(CULOARE = "100")  then
				Rosu_aux<='1';			
				Verde_aux<='0';
				Albastru_aux<='1';
		-- turcoaz
			elsif(CULOARE = "101")  then
				Rosu_aux<='0';			
				Verde_aux<='1';
				Albastru_aux<='1';
		-- alb
			elsif(CULOARE = "110")  then
				Rosu_aux<='1';			
				Verde_aux<='1';
				Albastru_aux<='1';
		-- negru
			elsif(CULOARE = "111")  then
				Rosu_aux<='0';			
				Verde_aux<='0';
				Albastru_aux<='0';
			end if;
	end if;
end process;
		
		
		
process(clk25, SUS, JOS, STANGA, DREAPTA, X, Y) --PROCES PENTRU MISCARE FIGURII PE CELE DOUA AXE X SI Y	
	begin
		if(rising_edge(CLK25))then
	
			if(SUS = '1' and Sus_aux = '0') then 
				X <= X + 10 ;
			elsif (JOS = '1' and Jos_aux = '0') then
				X <= X - 10 ;
			elsif (STANGA = '1' and Stanga_aux = '0') then
				Y <= Y - 10 ;
			elsif(DREAPTA = '1' and Dreapta_aux = '0') then 
				Y <= Y + 10 ; 
			end if;
		Sus_aux <= SUS;
		Jos_aux <= JOS;
		Stanga_aux <= STANGA;
		Dreapta_aux <= DREAPTA;
	end if;
end process;
		

process(clk25, RST, hPos, vPos, videoOn, X, Y)	  --PROCES PENTRU DESENAREA FIGURILOR
	begin 	 
		
	if(RST = '1') then
		Rosu <= '0';
		Verde <= '0';
		Albastru <= '0';		
	elsif( rising_edge(CLK25) )then
			if(videoOn = '1') then
			
			-- patrat
			
				if( SELECTIE = "000") then
					if((hPos > Y - 70) and (hpos < Y + 70) and (vPos > X - 70) and (vPos < X + 70))then
							Rosu <= Rosu_aux ;
							Verde <= Verde_aux ;
							Albastru <= Albastru_aux ;
							else 
							Rosu <= '0' ;
							Verde <= '0' ;
							Albastru <= '0' ;
					end if;
					
			 -- linie verticala	
			 	
				elsif (SELECTIE = "001") then
					if	((hPos > y - 10) and (hpos < y + 10) and (vPos > x - 70) and (vPos < x + 70)) then
							Rosu <= Rosu_aux ;
							Verde <= Verde_aux ;
							Albastru <= Albastru_aux ;
						else 
							Rosu <= '0' ;
							Verde <= '0' ;
							Albastru <= '0' ;
					end if;
					
				-- linie orizontala	
				
				elsif (SELECTIE = "010") then
					if	 ((hPos > y - 70) and (hpos < y + 70) and (vPos > x - 10) and (vPos < x + 10)) then
							Rosu <= Rosu_aux ;
							Verde <= Verde_aux ;
							Albastru <= Albastru_aux ;
						else 
							Rosu <= '0' ;
							Verde <= '0' ;
							Albastru <= '0' ;
				end if;
				
				-- cerc
				
				elsif (SELECTIE = "011") then
					if(((hpos-y)*(hpos-y)+(vpos-x)*(vpos-x))<=1500) then
						    Rosu <= Rosu_aux ;
							Verde <= Verde_aux ;
							Albastru <= Albastru_aux ;
						else 
							Rosu <= '0' ;
							Verde <= '0' ;
							Albastru <= '0' ;
				end if;
				
				-- triunghi
				
				elsif (SELECTIE = "100") then
					if	 ((hPos > y -  0) and (hpos < Y +  0) and (vPos > X - 30) and (vPos < x + 1)) or
			             ((hPos > Y -  1) and (hpos < y +  1) and (vPos > X - 29) and (vPos < x + 1)) or 
			             ((hPos > Y -  2) and (hpos < y +  2) and (vPos > x - 28) and (vPos < x + 1)) or
			             ((hPos > Y -  3) and (hpos < Y +  3) and (vPos > x - 27) and (vPos < X + 1)) or
			             ((hPos > Y -  4) and (hpos < Y +  4) and (vPos > x - 26) and (vPos < x + 1)) or
			             ((hPos > Y -  5) and (hpos < y +  5) and (vPos > x - 25) and (vPos < x + 1)) or
			             ((hPos > Y -  6) and (hpos < Y +  6) and (vPos > X - 24) and (vPos < X + 1)) or
			             ((hPos > Y -  7) and (hpos < Y +  7) and (vPos > X - 23) and (vPos < X + 1)) or
			             ((hPos > Y -  8) and (hpos < Y +  8) and (vPos > X - 22) and (vPos < X + 1)) or
			             ((hPos > Y -  9) and (hpos < Y +  9) and (vPos > X - 21) and (vPos < X + 1)) or
			             ((hPos > Y - 10) and (hpos < Y + 10) and (vPos > X - 20) and (vPos < X + 1)) or
			             ((hPos > y - 11) and (hpos < Y + 11) and (vPos > X - 19) and (vPos < x + 1)) or
			             ((hPos > Y - 12) and (hpos < y + 12) and (vPos > X - 18) and (vPos < x + 1)) or 
			             ((hPos > Y - 13) and (hpos < y + 13) and (vPos > x - 17) and (vPos < x + 1)) or
			             ((hPos > Y - 14) and (hpos < Y + 14) and (vPos > x - 16) and (vPos < X + 1)) or
			             ((hPos > Y - 15) and (hpos < Y + 15) and (vPos > x - 15) and (vPos < x + 1)) or
			             ((hPos > Y - 16) and (hpos < y + 16) and (vPos > x - 14) and (vPos < x + 1)) or
			             ((hPos > Y - 17) and (hpos < Y + 17) and (vPos > X - 13) and (vPos < X + 1)) or
			             ((hPos > Y - 18) and (hpos < Y + 18) and (vPos > X - 12) and (vPos < X + 1)) or
			             ((hPos > Y - 19) and (hpos < Y + 19) and (vPos > X - 11) and (vPos < X + 1)) or
			             ((hPos > Y - 20) and (hpos < Y + 20) and (vPos > X - 10) and (vPos < X + 1)) or
			             ((hPos > Y - 21) and (hpos < Y + 21) and (vPos > X -  9) and (vPos < X + 1)) or
			             ((hPos > Y - 22) and (hpos < Y + 22) and (vPos > X -  8) and (vPos < X + 1)) or
			             ((hPos > Y - 23) and (hpos < Y + 23) and (vPos > X -  7) and (vPos < X + 1)) or
			             ((hPos > Y - 24) and (hpos < Y + 24) and (vPos > X -  6) and (vPos < X + 1)) or
			             ((hPos > Y - 25) and (hpos < Y + 25) and (vPos > X -  5) and (vPos < X + 1)) or
			             ((hPos > Y - 26) and (hpos < Y + 26) and (vPos > X -  4) and (vPos < X + 1)) or
			             ((hPos > Y - 27) and (hpos < Y + 27) and (vPos > X -  3) and (vPos < X + 1)) or
			             ((hPos > Y - 28) and (hpos < Y + 28) and (vPos > X -  2) and (vPos < X + 1)) or
			             ((hPos > Y - 29) and (hpos < Y + 29) and (vPos > X -  1) and (vPos < X + 1)) or
			             ((hPos > Y - 30) and (hpos < Y + 30) and (vPos > X -  0) and (vPos < X + 1)) then
						    Rosu <= Rosu_aux ;
							Verde <= Verde_aux ;
							Albastru <= Albastru_aux ;
						else 
							Rosu <= '0' ;
							Verde <= '0' ;
							Albastru <= '0' ;   
				end if;
				
				-- trapez
				
				elsif (SELECTIE = "101") then
					if   ((hPos > Y - 10) and (hpos < Y + 10) and (vPos > X - 20) and (vPos < X + 1)) or
			             ((hPos > y - 11) and (hpos < Y + 11) and (vPos > X - 19) and (vPos < x + 1)) or
			             ((hPos > Y - 12) and (hpos < y + 12) and (vPos > X - 18) and (vPos < x + 1)) or 
			             ((hPos > Y - 13) and (hpos < y + 13) and (vPos > x - 17) and (vPos < x + 1)) or
			             ((hPos > Y - 14) and (hpos < Y + 14) and (vPos > x - 16) and (vPos < X + 1)) or
			             ((hPos > Y - 15) and (hpos < Y + 15) and (vPos > x - 15) and (vPos < x + 1)) or
			             ((hPos > Y - 16) and (hpos < y + 16) and (vPos > x - 14) and (vPos < x + 1)) or
			             ((hPos > Y - 17) and (hpos < Y + 17) and (vPos > X - 13) and (vPos < X + 1)) or
			             ((hPos > Y - 18) and (hpos < Y + 18) and (vPos > X - 12) and (vPos < X + 1)) or
			             ((hPos > Y - 19) and (hpos < Y + 19) and (vPos > X - 11) and (vPos < X + 1)) or
			             ((hPos > Y - 20) and (hpos < Y + 20) and (vPos > X - 10) and (vPos < X + 1)) or
			             ((hPos > Y - 21) and (hpos < Y + 21) and (vPos > X -  9) and (vPos < X + 1)) or
			             ((hPos > Y - 22) and (hpos < Y + 22) and (vPos > X -  8) and (vPos < X + 1)) or
			             ((hPos > Y - 23) and (hpos < Y + 23) and (vPos > X -  7) and (vPos < X + 1)) or
			             ((hPos > Y - 24) and (hpos < Y + 24) and (vPos > X -  6) and (vPos < X + 1)) or
			             ((hPos > Y - 25) and (hpos < Y + 25) and (vPos > X -  5) and (vPos < X + 1)) or
			             ((hPos > Y - 26) and (hpos < Y + 26) and (vPos > X -  4) and (vPos < X + 1)) or
			             ((hPos > Y - 27) and (hpos < Y + 27) and (vPos > X -  3) and (vPos < X + 1)) or
			             ((hPos > Y - 28) and (hpos < Y + 28) and (vPos > X -  2) and (vPos < X + 1)) or
			             ((hPos > Y - 29) and (hpos < Y + 29) and (vPos > X -  1) and (vPos < X + 1)) or
			             ((hPos > Y - 30) and (hpos < Y + 30) and (vPos > X -  0) and (vPos < X + 1)) then
							Rosu <= Rosu_aux ;
							Verde <= Verde_aux ;
							Albastru <= Albastru_aux ;
						else 
							Rosu <= '0' ;
							Verde <= '0' ;
							Albastru <= '0' ;
					end if;
					
					-- sageata
					
				elsif (SELECTIE = "110") then
			      if	 ((hPos > y -  0) and (hpos < Y +  0) and (vPos > X - 30) and (vPos < x + 1)) or
			             ((hPos > Y -  1) and (hpos < y +  1) and (vPos > X - 29) and (vPos < x + 1)) or 
			             ((hPos > Y -  2) and (hpos < y +  2) and (vPos > x - 28) and (vPos < x + 1)) or
			             ((hPos > Y -  3) and (hpos < Y +  3) and (vPos > x - 27) and (vPos < X + 1)) or
			             ((hPos > Y -  4) and (hpos < Y +  4) and (vPos > x - 26) and (vPos < x + 1)) or
			             ((hPos > Y -  5) and (hpos < y +  5) and (vPos > x - 25) and (vPos < x + 1)) or
			             ((hPos > Y -  6) and (hpos < Y +  6) and (vPos > X - 24) and (vPos < X + 1)) or
			             ((hPos > Y -  7) and (hpos < Y +  7) and (vPos > X - 23) and (vPos < X + 1)) or
			             ((hPos > Y -  8) and (hpos < Y +  8) and (vPos > X - 22) and (vPos < X + 1)) or
			             ((hPos > Y -  9) and (hpos < Y +  9) and (vPos > X - 21) and (vPos < X + 1)) or
			             ((hPos > Y - 10) and (hpos < Y + 10) and (vPos > X - 20) and (vPos < X + 1)) or
			             ((hPos > y - 11) and (hpos < Y + 11) and (vPos > X - 19) and (vPos < x + 1)) or
			             ((hPos > Y - 12) and (hpos < y + 12) and (vPos > X - 18) and (vPos < x + 1)) or 
			             ((hPos > Y - 13) and (hpos < y + 13) and (vPos > x - 17) and (vPos < x + 1)) or
			             ((hPos > Y - 14) and (hpos < Y + 14) and (vPos > x - 16) and (vPos < X + 1)) or
			             ((hPos > Y - 15) and (hpos < Y + 15) and (vPos > x - 15) and (vPos < x + 1)) or
			             ((hPos > Y - 16) and (hpos < y + 16) and (vPos > x - 14) and (vPos < x + 1)) or
			             ((hPos > Y - 17) and (hpos < Y + 17) and (vPos > X - 13) and (vPos < X + 1)) or
			             ((hPos > Y - 18) and (hpos < Y + 18) and (vPos > X - 12) and (vPos < X + 1)) or
			             ((hPos > Y - 19) and (hpos < Y + 19) and (vPos > X - 11) and (vPos < X + 1)) or
			             ((hPos > Y - 20) and (hpos < Y + 20) and (vPos > X - 10) and (vPos < X + 1)) or
			             ((hPos > Y - 21) and (hpos < Y + 21) and (vPos > X -  9) and (vPos < X + 1)) or
			             ((hPos > Y - 22) and (hpos < Y + 22) and (vPos > X -  8) and (vPos < X + 1)) or
			             ((hPos > Y - 23) and (hpos < Y + 23) and (vPos > X -  7) and (vPos < X + 1)) or
			             ((hPos > Y - 24) and (hpos < Y + 24) and (vPos > X -  6) and (vPos < X + 1)) or
			             ((hPos > Y - 25) and (hpos < Y + 25) and (vPos > X -  5) and (vPos < X + 1)) or
			             ((hPos > Y - 26) and (hpos < Y + 26) and (vPos > X -  4) and (vPos < X + 1)) or
			             ((hPos > Y - 27) and (hpos < Y + 27) and (vPos > X -  3) and (vPos < X + 1)) or
			             ((hPos > Y - 28) and (hpos < Y + 28) and (vPos > X -  2) and (vPos < X + 1)) or
			             ((hPos > Y - 29) and (hpos < Y + 29) and (vPos > X -  1) and (vPos < X + 1)) or
			             ((hPos > Y - 30) and (hpos < Y + 30) and (vPos > X -  0) and (vPos < X + 1)) or
			             ((hPos > Y - 15) and (hpos < Y + 15) and (vPos > X -  0) and (vPos < X +30)) then
							Rosu <= Rosu_aux ;
							Verde <= Verde_aux ;
							Albastru <= Albastru_aux ;
						else 
							Rosu <= '0' ;
							Verde <= '0' ;
							Albastru <= '0' ;
					end if;
					
					-- romb
					
					elsif (SELECTIE = "111") then
			      if	 ((hPos > y -  0) and (hpos < Y +  0) and (vPos > X - 30) and (vPos < x + 1)) or
			             ((hPos > Y -  1) and (hpos < y +  1) and (vPos > X - 29) and (vPos < x + 1)) or 
			             ((hPos > Y -  2) and (hpos < y +  2) and (vPos > x - 28) and (vPos < x + 1)) or
			             ((hPos > Y -  3) and (hpos < Y +  3) and (vPos > x - 27) and (vPos < X + 1)) or
			             ((hPos > Y -  4) and (hpos < Y +  4) and (vPos > x - 26) and (vPos < x + 1)) or
			             ((hPos > Y -  5) and (hpos < y +  5) and (vPos > x - 25) and (vPos < x + 1)) or
			             ((hPos > Y -  6) and (hpos < Y +  6) and (vPos > X - 24) and (vPos < X + 1)) or
			             ((hPos > Y -  7) and (hpos < Y +  7) and (vPos > X - 23) and (vPos < X + 1)) or
			             ((hPos > Y -  8) and (hpos < Y +  8) and (vPos > X - 22) and (vPos < X + 1)) or
			             ((hPos > Y -  9) and (hpos < Y +  9) and (vPos > X - 21) and (vPos < X + 1)) or
			             ((hPos > Y - 10) and (hpos < Y + 10) and (vPos > X - 20) and (vPos < X + 1)) or
			             ((hPos > y - 11) and (hpos < Y + 11) and (vPos > X - 19) and (vPos < x + 1)) or
			             ((hPos > Y - 12) and (hpos < y + 12) and (vPos > X - 18) and (vPos < x + 1)) or 
			             ((hPos > Y - 13) and (hpos < y + 13) and (vPos > x - 17) and (vPos < x + 1)) or
			             ((hPos > Y - 14) and (hpos < Y + 14) and (vPos > x - 16) and (vPos < X + 1)) or
			             ((hPos > Y - 15) and (hpos < Y + 15) and (vPos > x - 15) and (vPos < x + 1)) or
			             ((hPos > Y - 16) and (hpos < y + 16) and (vPos > x - 14) and (vPos < x + 1)) or
			             ((hPos > Y - 17) and (hpos < Y + 17) and (vPos > X - 13) and (vPos < X + 1)) or
			             ((hPos > Y - 18) and (hpos < Y + 18) and (vPos > X - 12) and (vPos < X + 1)) or
			             ((hPos > Y - 19) and (hpos < Y + 19) and (vPos > X - 11) and (vPos < X + 1)) or
			             ((hPos > Y - 20) and (hpos < Y + 20) and (vPos > X - 10) and (vPos < X + 1)) or
			             ((hPos > Y - 21) and (hpos < Y + 21) and (vPos > X -  9) and (vPos < X + 1)) or
			             ((hPos > Y - 22) and (hpos < Y + 22) and (vPos > X -  8) and (vPos < X + 1)) or
			             ((hPos > Y - 23) and (hpos < Y + 23) and (vPos > X -  7) and (vPos < X + 1)) or
			             ((hPos > Y - 24) and (hpos < Y + 24) and (vPos > X -  6) and (vPos < X + 1)) or
			             ((hPos > Y - 25) and (hpos < Y + 25) and (vPos > X -  5) and (vPos < X + 1)) or
			             ((hPos > Y - 26) and (hpos < Y + 26) and (vPos > X -  4) and (vPos < X + 1)) or
			             ((hPos > Y - 27) and (hpos < Y + 27) and (vPos > X -  3) and (vPos < X + 1)) or
			             ((hPos > Y - 28) and (hpos < Y + 28) and (vPos > X -  2) and (vPos < X + 1)) or
			             ((hPos > Y - 29) and (hpos < Y + 29) and (vPos > X -  1) and (vPos < X + 1)) or
			             ((hPos > Y - 30) and (hpos < Y + 30) and (vPos > X -  0) and (vPos < X + 1)) or
			             ((hPos > Y - 29) and (hpos < Y + 29) and (vPos > X -  0) and (vPos < X + 1)) or
			             ((hPos > Y - 28) and (hpos < Y + 28) and (vPos > X -  0) and (vPos < X + 2)) or
			             ((hPos > Y - 27) and (hpos < Y + 27) and (vPos > X -  0) and (vPos < X + 3)) or
			             ((hPos > Y - 26) and (hpos < Y + 26) and (vPos > X -  0) and (vPos < X + 4)) or
			             ((hPos > Y - 25) and (hpos < Y + 25) and (vPos > X -  0) and (vPos < X + 5)) or
			             ((hPos > Y - 24) and (hpos < Y + 24) and (vPos > X -  0) and (vPos < X + 6)) or
			             ((hPos > Y - 23) and (hpos < Y + 23) and (vPos > X -  0) and (vPos < X + 7)) or
			             ((hPos > Y - 22) and (hpos < Y + 22) and (vPos > X -  0) and (vPos < X + 8)) or
			             ((hPos > Y - 21) and (hpos < Y + 21) and (vPos > X -  0) and (vPos < X + 9)) or
			             ((hPos > Y - 20) and (hpos < Y + 20) and (vPos > X -  0) and (vPos < X + 10)) or
			             ((hPos > Y - 19) and (hpos < Y + 19) and (vPos > X -  0) and (vPos < X + 11)) or
			             ((hPos > Y - 18) and (hpos < Y + 18) and (vPos > X -  0) and (vPos < X + 12)) or
			             ((hPos > Y - 17) and (hpos < Y + 17) and (vPos > X -  0) and (vPos < X + 13)) or
			             ((hPos > Y - 16) and (hpos < Y + 16) and (vPos > X -  0) and (vPos < X + 14)) or
			             ((hPos > Y - 15) and (hpos < Y + 15) and (vPos > X -  0) and (vPos < X + 15)) or
			             ((hPos > Y - 14) and (hpos < Y + 14) and (vPos > X -  0) and (vPos < X + 16)) or
			             ((hPos > Y - 13) and (hpos < Y + 13) and (vPos > X -  0) and (vPos < X + 17)) or
			             ((hPos > Y - 12) and (hpos < Y + 12) and (vPos > X -  0) and (vPos < X + 18)) or
			             ((hPos > Y - 11) and (hpos < Y + 11) and (vPos > X -  0) and (vPos < X + 19)) or
			             ((hPos > Y - 10) and (hpos < Y + 10) and (vPos > X -  0) and (vPos < X + 20)) or
			             ((hPos > Y -  9) and (hpos < Y +  9) and (vPos > X -  0) and (vPos < X + 21)) or
			             ((hPos > Y -  8) and (hpos < Y +  8) and (vPos > X -  0) and (vPos < X + 22)) or
			             ((hPos > Y -  7) and (hpos < Y +  7) and (vPos > X -  0) and (vPos < X + 23)) or
			             ((hPos > Y -  6) and (hpos < Y +  6) and (vPos > X -  0) and (vPos < X + 24)) or
			             ((hPos > Y -  5) and (hpos < Y +  5) and (vPos > X -  0) and (vPos < X + 25)) or
			             ((hPos > Y -  4) and (hpos < Y +  4) and (vPos > X -  0) and (vPos < X + 26)) or
			             ((hPos > Y -  3) and (hpos < Y +  3) and (vPos > X -  0) and (vPos < X + 27)) or
			             ((hPos > Y -  2) and (hpos < Y +  2) and (vPos > X -  0) and (vPos < X + 28)) or
			             ((hPos > Y -  1) and (hpos < Y +  1) and (vPos > X -  0) and (vPos < X + 29)) or
			             ((hPos > Y -  0) and (hpos < Y +  0) and (vPos > X -  0) and (vPos < X + 30)) then
							Rosu <= Rosu_aux ;
							Verde <= Verde_aux ;
							Albastru <= Albastru_aux ;
						else 
							Rosu <= '0' ;
							Verde <= '0' ;
							Albastru <= '0' ;
					end if;	
				end if;
			end if;
		end if;
	end process; 
	
	
process(SELECTIE,RST) 
	begin
	if(RST='1') then
			ANOD  <= "1111";
			CATOD <= "1111111";
	else
		case (SELECTIE) is
							when "000" =>  ANOD <=  "1110"; 
							  				--	     abcdefg
										   CATOD <= "0000001";
							when "001" =>  ANOD <=  "1110";
										   CATOD <= "1001111";
							when "010" =>  ANOD <=  "1110";
										   CATOD <= "0010010";
							when "011" =>  ANOD <=  "1110";
										   CATOD <= "0000110";
							when "100" =>  ANOD <=  "1110";
										   CATOD <= "1001100";
							when "101" =>  ANOD <=  "1110";
										   CATOD <= "0100100";
							when "110" =>  ANOD <=  "1110";
										   CATOD <= "0100000";
							when others => ANOD <=  "1110";
										   CATOD <= "0001111";
		end case; 
	end if;				   
end process;

end ARH_VGA;

