data(SEITL_deter)


SEIT2L_sto_name <- "stochastic SEIT2L model with daily incidence and constant population size"
SEIT2L_state.names <- c("S","E","I","T1", "T2","L","Inc")

# Simulate realisation of the stochastic version of the SEIT2L model.
SEIT2L_simulateStochastic <- function(theta,init.state,times) {

	
	SEIT2L_transitions <- list(
		c(S=-1,E=1),# infection
		c(E=-1,I=1,Inc=1),# infectiousness + incidence
		c(I=-1,T1=1),# recovery + temporary protection
		c(T1=-1,T2=1),# progression of temporary protection
		c(T2=-1,L=1),# efficient long term protection
		c(T2=-1,S=1)# deficient long term protection
		)

	SEIT2L_rateFunc <- function(state,theta,t) {

		# param
		beta <- theta[["R0"]]/theta[["D_inf"]]
		epsilon <- 1/theta[["D_lat"]]
		nu <- 1/theta[["D_inf"]]
		alpha <- theta[["alpha"]]
		tau <- 1/theta[["D_imm"]]

		# states
		S <- state[["S"]]
		E <- state[["E"]]
		I <- state[["I"]]
		T1 <- state[["T1"]]
		T2 <- state[["T2"]]
		L <- state[["L"]]
		Inc <- state[["Inc"]]

		N <- S + E +I + T1 + T2 + L

		return(c(
			beta*S*I/N, # infection (S -> E)
			epsilon*E, # infectiousness + incidence (E -> I)
			nu*I, # recovery + short term protection (I -> T1)
			2*tau*T1, # progression of temporary protection (T1 -> T2)
			alpha*2*tau*T2, # efficient long term protection (T2 -> L)
			(1-alpha)*2*tau*T2 # deficient long term protection (T2 -> S)
			)
		)
	}

	# put incidence at 0 in init.state
	init.state["Inc"] <- 0

	traj <- simulateModelStochastic(theta,init.state,times,SEIT2L_transitions,SEIT2L_rateFunc) 
	
	# compute incidence of each time interval
	traj$Inc <- c(0, diff(traj$Inc))

	return(traj)

}


SEIT2L_stoch <- fitmodel(
	name=SEIT2L_sto_name,
	state.names=SEIT2L_state.names,
	theta.names=SEITL_theta.names,
	simulate=SEIT2L_simulateStochastic,
	dprior=SEITL_prior,
	rPointObs=SEITL_genObsPoint,
	dPointObs=SEITL_pointLike)
