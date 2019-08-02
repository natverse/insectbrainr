#' @title Get information on species/neurons from insectbraindb.org
#'
#' @description Get information on the neurons and brain templates hosted by insectbraindb.org, including neuron names, species names, associated publications, etc.
#' @details
#'  As of May 2019, data from the following \href{https://insectbraindb.org/app/species}{species} is hosted on insectbraindb.org :
#'\itemize{
#'  \item 	\emph{Agrotis infusa}	 Bogong moth
#'  \item 	\emph{Agrotis segetum}	 Turnip moth
#'  \item 	\emph{Apis mellifera}	 Honeybee
#'  \item 	\emph{Apis mellifera}	 Honeybee
#'  \item 	\emph{Danaus plexippus}	 Monarch Butterfly
#'  \item 	\emph{Helicoverpa armigera}	 Cotton Bollworm,
#'  \item 	\emph{Helicoverpa assulta}	 Oriental tobacco budworm
#'  \item 	\emph{Heliothis virescens}	 Tobacco budworm
#'  \item 	\emph{Macroglossum stellatarum}	 Hummingbird hawk moth
#'  \item 	\emph{Manduca sexta}	 Tobacco hornworm
#'  \item 	\emph{Megalopta genalis}	 Sweat bee
#'  \item 	\emph{Nasonia vitripennis}	 Jewel wasp
#'  \item 	\emph{Scarabaeus lamarcki}	 Diurnal dung beetle
#'  \item 	\emph{Schistocerca gregaria}	 Desert Locust
#'  }
#' @return a \code{data.frame} that most importantly gives the user the latin scientific name, common name or neuron names and insectbraindb.org-specific ID number
#' for each insect species / neuron on which data is held on the site
#' @seealso \code{\link{insectbraindb_read_brain}}, \code{\link{insectbraindb_read_neurons}}
#' @inherit insectbraindb_read_neurons examples
#' @export
#' @rdname insectbraindb_info
insectbraindb_species_info <- function(){
  species_info = insectbraindb_fetch(path = "api/species/min/",
                                  body = NULL,
                                  parse.json = TRUE,
                                  simplifyVector=FALSE,
                                  include_headers = FALSE,
                                  insectbraindb_url = "https://insectbraindb.org")
  df = data.frame()
  for(s in species_info){
    s = nullToNA(s)
    df  = rbind(df, unlist(s))
  }
  colnames(df) = names(species_info[[1]])
  rownames(df) = df[,"id"]
  df
}

#' @export
#' @rdname insectbraindb_info
insectbraindb_neuron_info <- function(){
  neurons_info = insectbraindb_fetch(path = "api/neurons/base/?format=json",
                                   body = NULL,
                                   parse.json = TRUE,
                                   simplifyVector=FALSE,
                                   include_headers = FALSE,
                                   insectbraindb_url = "https://insectbraindb.org")
  df = data.frame()
  for(n in neurons_info){
    n = nullToNA(n)
    meta = names(n)[!sapply(n,is.list)]
    meta = unlist(n[meta])
    meta["scientific_name"] = n$species$scientific_name
    meta["common_name"] = n$species$common_name
    df  = rbind(df, meta)
  }
  colnames(df) = names(meta)
  df
}
