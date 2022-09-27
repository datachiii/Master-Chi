###################################################################

# Created by write_sdc on Thu Nov  4 18:42:34 2021

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_operating_conditions -max slow -max_library slow\
                         -min fast -min_library fast
set_wire_load_model -name tsmc090_wl10 -library slow
set_max_area 0
set_max_delay 20  -from [list [get_ports {A[31]}] [get_ports {A[30]}] [get_ports {A[29]}]       \
[get_ports {A[28]}] [get_ports {A[27]}] [get_ports {A[26]}] [get_ports         \
{A[25]}] [get_ports {A[24]}] [get_ports {A[23]}] [get_ports {A[22]}]           \
[get_ports {A[21]}] [get_ports {A[20]}] [get_ports {A[19]}] [get_ports         \
{A[18]}] [get_ports {A[17]}] [get_ports {A[16]}] [get_ports {A[15]}]           \
[get_ports {A[14]}] [get_ports {A[13]}] [get_ports {A[12]}] [get_ports         \
{A[11]}] [get_ports {A[10]}] [get_ports {A[9]}] [get_ports {A[8]}] [get_ports  \
{A[7]}] [get_ports {A[6]}] [get_ports {A[5]}] [get_ports {A[4]}] [get_ports    \
{A[3]}] [get_ports {A[2]}] [get_ports {A[1]}] [get_ports {A[0]}] [get_ports    \
{B[31]}] [get_ports {B[30]}] [get_ports {B[29]}] [get_ports {B[28]}]           \
[get_ports {B[27]}] [get_ports {B[26]}] [get_ports {B[25]}] [get_ports         \
{B[24]}] [get_ports {B[23]}] [get_ports {B[22]}] [get_ports {B[21]}]           \
[get_ports {B[20]}] [get_ports {B[19]}] [get_ports {B[18]}] [get_ports         \
{B[17]}] [get_ports {B[16]}] [get_ports {B[15]}] [get_ports {B[14]}]           \
[get_ports {B[13]}] [get_ports {B[12]}] [get_ports {B[11]}] [get_ports         \
{B[10]}] [get_ports {B[9]}] [get_ports {B[8]}] [get_ports {B[7]}] [get_ports   \
{B[6]}] [get_ports {B[5]}] [get_ports {B[4]}] [get_ports {B[3]}] [get_ports    \
{B[2]}] [get_ports {B[1]}] [get_ports {B[0]}] [get_ports {C[31]}] [get_ports   \
{C[30]}] [get_ports {C[29]}] [get_ports {C[28]}] [get_ports {C[27]}]           \
[get_ports {C[26]}] [get_ports {C[25]}] [get_ports {C[24]}] [get_ports         \
{C[23]}] [get_ports {C[22]}] [get_ports {C[21]}] [get_ports {C[20]}]           \
[get_ports {C[19]}] [get_ports {C[18]}] [get_ports {C[17]}] [get_ports         \
{C[16]}] [get_ports {C[15]}] [get_ports {C[14]}] [get_ports {C[13]}]           \
[get_ports {C[12]}] [get_ports {C[11]}] [get_ports {C[10]}] [get_ports {C[9]}] \
[get_ports {C[8]}] [get_ports {C[7]}] [get_ports {C[6]}] [get_ports {C[5]}]    \
[get_ports {C[4]}] [get_ports {C[3]}] [get_ports {C[2]}] [get_ports {C[1]}]    \
[get_ports {C[0]}]]  -to [list [get_ports {D[31]}] [get_ports {D[30]}] [get_ports {D[29]}]         \
[get_ports {D[28]}] [get_ports {D[27]}] [get_ports {D[26]}] [get_ports         \
{D[25]}] [get_ports {D[24]}] [get_ports {D[23]}] [get_ports {D[22]}]           \
[get_ports {D[21]}] [get_ports {D[20]}] [get_ports {D[19]}] [get_ports         \
{D[18]}] [get_ports {D[17]}] [get_ports {D[16]}] [get_ports {D[15]}]           \
[get_ports {D[14]}] [get_ports {D[13]}] [get_ports {D[12]}] [get_ports         \
{D[11]}] [get_ports {D[10]}] [get_ports {D[9]}] [get_ports {D[8]}] [get_ports  \
{D[7]}] [get_ports {D[6]}] [get_ports {D[5]}] [get_ports {D[4]}] [get_ports    \
{D[3]}] [get_ports {D[2]}] [get_ports {D[1]}] [get_ports {D[0]}]]
