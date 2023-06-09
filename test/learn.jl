#=
Test the solve opf function in PowerModels
    - There is a battery storage in power grid
    - Run just for one time step
=#
using PowerModels
using Ipopt

# Import case5 with storage
case_5 = PowerModels.parse_file("test/data/matpower/case5_strg.m")

#=
Definition of stroge model
  "index":<int>,
  "storage_bus":<int>,
  "ps":<float, MW>,
  "qs":<float, MVAr>,
  "energy":<float, MWh>,
  "energy_rating":<float, MWh>,
  "charge_rating":<float, MW>,
  "discharge_rating":<float, MW>,
  "charge_efficiency":<float>,
  "discharge_efficiency":<float>,
  ("thermal_rating":<float, MVA>,)
  ("current_rating":<float, MA>,)
  "qmin":<float, MVar>,
  "qmax":<float, MVar>,
  "r":<float, p.u.>,
  "x":<float, p.u.>,
  "p_loss":<float, MW>,
  "q_loss":<float, MVar>,
  "status":<int>,
=#

# How will _solve_opf_strg run a opf with storag
nlp_solver = optimizer_with_attributes(Ipopt.Optimizer, "tol"=>1e-6)
@enter result = PowerModels._solve_opf_strg(case_5, PowerModels.ACPPowerModel, nlp_solver)

#=
Variables in ACPP model
  - va, vm of each bus
  - pg, qg of each generator
  - ps, qs (qsc, se, charge_rating, discharge_rating) of each storage
  - how deal with load?

Branch Flow model
  - variable representing real power flow in a branch p[l, i, j]
    - l is branch index, i and j are from_bus and to_bus
    - each branch has two real power flow directions like p[3, 1, 10] and p[3, 10, 1]
  - it is necessary to know how to calculate the branch_flow_bounds
    - at the m.file, parameter rateA of each branch is used to represent the branch flow bound MVA
    - however, real power flow bounds p[l, i, j] and real power flow q[l, i, j] are the same 
=#

#=
Follwing constraints for storage are considered:
  - storage_power_real
  - storage_power_imaginary
  - storage_power_control_imaginary
  - storage_energy
  - variable_storage_charge
  - variable_storage_discharge
Some relationships are not clear
  - qs range is the same as q_min and q_max
  - ps, qs and charging rate, discharge_rating
  - how to decide the se_0 at initial?
=#

#=
The way to set objective function when power grid has storage
  - usually the objective is to minimize gen constraint
    - generator cost has two types: 1 (piecewise), 2 (polynomial)
    - ncost give us how many coefficients is there
    - then follow the coefficients like c2, c1, c0 / PowerModels show it like [0, 400, 50]
  - Has storage also a operation cost?
    - answer is, there is no operation cost of storage
    - if would be interesting to see what happend with and without storage
  - maximize load can be seen in test file, that would be interesting
=# 