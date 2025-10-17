#' Add orthogroup occurrence and genome completeness estimates
#'
#' This function jointly estimates the occurrence of all orthogroups and
#' completeness of all genomes and adds these estimates to the orthogoup and
#' genome table, respectively.
#'
#' @param tg A tidygenomes object
#' @param max_iterations The maximum number of interations in the likelihood
#'   optimization
#' 
#' @return An updated tidygenomes object
#' 
#' @export
add_pangenome_estimates <- function(tg, max_iterations = 1000) {
  
  # create a presence/absence matrix
  m <- pangenome_matrix(tg) %>% {. > 0}
  # m[1, sample(1:ncol(m), ncol(m) %/% 4)] <- FALSE
  
  # initial completenesses are all 1
  comps <- rep(1, nrow(m))
  
  # initial log likelihood is minus infinity
  ll <- - Inf
  
  # optimize log likelihood until no improvement or max_iterations reached
  for (i in 1:max_iterations) {
    
    # optimize the occurrences given the current completeness estimates
    occs_list <- 
      apply(
        m, 2, function(c) optimize(
          log_likelihood_occ, interval = c(0, 1), c, comps, maximum = T
        )
      )
    occs <- map_dbl(occs_list, "maximum")
    
    # optimize the completenesses given the current occurrence estimates
    comps_list <- 
      apply(
        m, 1, function(r) optimize(
          log_likelihood_comp, interval = c(0, 1), r, occs, maximum = T
        )
      )
    ll_next <- sum(map_dbl(comps_list, "objective"))
    comps <- map_dbl(comps_list, "maximum")
    message("log-likelihood: ", ll_next)
    
    # stop iterating if no improvement in the likelihood
    if (ll_next <= ll) break
    ll <- ll_next
    
  }
  
  # add estimated occurrences to the orthogroup table
  tg$orthogroups <-
    tg$orthogroups %>%
    left_join(
      tibble(orthogroup = colnames(m), occurrence_est = occs), 
      by = "orthogroup"
    )
  
  # add estimated completeness to the genome table
  tg$genomes <-
    tg$genomes %>%
    left_join(
      tibble(genome = rownames(m), completeness_est = comps),
      by = "genome"
    )
  
  tg
  
}

#' Return log-likelihood of an orthogroup occurrence value
#'
#' This function calculates the log-likelihood of an orthogroup occurrence
#' value, given presence/absence states of the orthogroup in a set of genomes
#' and completeness values of these genomes.
#'
#' @param occurrence An occurrence value of the orthogroup
#' @param states A vector with pres/abs (TRUE/FALSE) states of the orthogroup in
#'   a set of genomes
#' @param completenesses A vector with completeness values of a set of genomes,
#'   in the same order as `states`
#' 
#' @return A log-likelihood value
log_likelihood_occ <- function(occurrence, states, completenesses) {
  
  r <- occurrence 
  s <- states 
  c <- completenesses
  
  cr <- c * r
  sum(s * log(cr) + (1 - s) * log(1 - cr))
  
}

#' Return log-likelihood of a genome completeness value
#'
#' This function calculates the log-likelihood of a genome completeness value,
#' given presence/absence states of a set of orthogroups in the genome and
#' occurrence values of these orthogroups.
#'
#' @param completeness A completeness value of the genome
#' @param states A vector with pres/abs (TRUE/FALSE) states of a set of
#'   orthogroups in the genome
#' @param occurrences A vector with occurrence values of a set of orthogroups,
#'   in the same order as `states`
#' 
#' @return A log-likelihood value
log_likelihood_comp <- function(completeness, states, occurrences) {
  
  r <- occurrences
  s <- states 
  c <- completeness
  
  cr <- c * r
  sum(s * log(cr) + (1 - s) * log(1 - cr))
  
}

#' Add various genome measures to the genome table
#'
#' This function adds the variables gn_genes and gn_orthogroups to the genome
#' table of a tidygenomes object.
#'
#' @param tg A tidygenomes object
#' 
#' @return An updated tidygenomes object
#' 
#' @export
add_genome_measures <- function(tg) {
  
  genomes <-
    tg$genes %>%
    count(genome, orthogroup, name = "n_copies") %>%
    group_by(genome) %>%
    summarize(gn_genes = sum(n_copies), gn_orthogroups = n(), .groups = "drop")
  
  tg %>%
    modify_at("genomes", left_join, genomes, by = "genome")
  
}
