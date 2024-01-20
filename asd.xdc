## Clock signal
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports CLK]

## Switches
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {SELECTIE[0]}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {SELECTIE[1]}]
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports {SELECTIE[2]}]
set_property -dict { PACKAGE_PIN U1   IOSTANDARD LVCMOS33 } [get_ports {CULOARE[0]}]
set_property -dict { PACKAGE_PIN T1   IOSTANDARD LVCMOS33 } [get_ports {CULOARE[1]}]
set_property -dict { PACKAGE_PIN R2   IOSTANDARD LVCMOS33 } [get_ports {CULOARE[2]}]
set_property -dict { PACKAGE_PIN V2   IOSTANDARD LVCMOS33 } [get_ports RST]


##7 Segment Display
set_property -dict { PACKAGE_PIN W7   IOSTANDARD LVCMOS33 } [get_ports {CATOD[6]}]
set_property -dict { PACKAGE_PIN W6   IOSTANDARD LVCMOS33 } [get_ports {CATOD[5]}]
set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVCMOS33 } [get_ports {CATOD[4]}]
set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS33 } [get_ports {CATOD[3]}]
set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS33 } [get_ports {CATOD[2]}]
set_property -dict { PACKAGE_PIN V5   IOSTANDARD LVCMOS33 } [get_ports {CATOD[1]}]
set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS33 } [get_ports {CATOD[0]}]
set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 } [get_ports {ANOD[0]}]
set_property -dict { PACKAGE_PIN U4   IOSTANDARD LVCMOS33 } [get_ports {ANOD[1]}]
set_property -dict { PACKAGE_PIN V4   IOSTANDARD LVCMOS33 } [get_ports {ANOD[2]}]
set_property -dict { PACKAGE_PIN W4   IOSTANDARD LVCMOS33 } [get_ports {ANOD[3]}]


##Buttons
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports SUS]
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports STANGA]
set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports DREAPTA]
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports JOS]

##VGA Connector
set_property -dict { PACKAGE_PIN N19   IOSTANDARD LVCMOS33 } [get_ports ROSU]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports ALBASTRU]
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports VERDE]
set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS33 } [get_ports HSYNC]
set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports VSYNC]



