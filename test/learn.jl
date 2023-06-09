#=
Test the solve opf function in PowerModels
    - There is a battery storage in power grid
    - Run just for one time step
=#
using PowerModels
using Ipopt

# import case5 with storage
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

# how will _solve_opf_strg run a opf with storag
nlp_solver = optimizer_with_attributes(Ipopt.Optimizer, "tol"=>1e-6)
@enter result = PowerModels._solve_opf_strg(case_5, PowerModels.ACPPowerModel, nlp_solver)
