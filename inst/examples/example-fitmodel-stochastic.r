# Create a simple stochastic SIR model with constant population size
#
# This is based on the determinsitc SIR model, which can be created
# using data(SIR)

data(SIR)

SIR_stochastic_name <- "stochastic SIR with constant population size"

SIR_simulateStochastic <- function(theta,init.state,times) {

        ## transitions
        SIR_transitions <- list(
                c(S = -1, I = 1), # infection
                c(I = -1, R = 1) # recovery
        )

        ## rates
        SIR_rateFunc <- function(x, parameters, t) {

                beta <- parameters[["R0"]]/parameters[["D_inf"]]
                nu <- 1/parameters[["D_inf"]]

                S <- x[["S"]]
                I <- x[["I"]]
                R <- x[["R"]]

                N <- S + I + R

                return(c(
                        beta * S * I / N, # infection
                        nu * I # recovery
                ))
        }

        # make use of the function simulateModelStochastic that
        # returns trajectories in the correct format
	return(simulateModelStochastic(theta,init.state,times,SIR_transitions,SIR_rateFunc))

}

# create stochastic SIR fitmodel
SIR_stoch <- fitmodel(
        name=SIR_stochastic_name,
        state.names=SIR_state.names,
        theta.names=SIR_theta.names,
        simulate=SIR_simulateStochastic,
        dprior=SIR_prior,
        rPointObs=SIR_genObsPoint,
        dPointObs=SIR_pointLike)

# test it
theta <- c(R0=3, D_inf=4)
init.state <- c(S=99,I=1,R=0)

# SIR_stoch
# testFitmodel(fitmodel=SIR_stoch, theta=theta, init.state=init.state, data= data, verbose=TRUE)


