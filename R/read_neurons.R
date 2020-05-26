#' @title Read insect neurons from insectbraindb.org
#'
#' @description Read templatebrain-registered neurons from insectbraindb.org
#'   (2018 version), given a single ID or vector of neuron IDs. Alternatively,
#'   if \code{ids} is set to \code{NULL}, all neurons in the database that can
#'   be read, are read (~100). Metadata for available neurons can be seen, and
#'   IDs chosen, by calling \code{\link{insectbraindb_neuron_info}}. Neurons are
#'   returned as a \code{nat} package \code{\link[nat]{neuronlist}} object, that
#'   can be be plotted in 3D using \code{rgl} and analysed with tools from the
#'   \code{nat} ecosystem. Each neuron in the insectbraindb is represented by a
#'   unique numeric ID, a name and is associated with an insect species and a
#'   publication, by DOI. Some neurons cannot be read because a SWC file is not
#'   available from insectbraindb.org. You can examine the available neurons
#'   here \href{https://insectbraindb.org/app/neurons}{here}), while the
#'   available species may be examined
#'   \href{https://insectbraindb.org/app/species}{here}). Critically, these
#'   neurons are registered to standard templates that may be obtained as
#'   \code{hxsurf} objects in R by using \code{\link{insectbraindb_read_brain}}.
#' @param ids a neuron ID, or vector of neuron IDs, as recorded in the
#'   insectbraindb.org. If set to \code{NULL} (default) then all neurons in the
#'   database are read. As of May 2018, this is only 100 readable neurons. A
#'   helpful information page on each neuron can be seen by visiting
#'   "https://insectbraindb.org/app/neuron/id", where id is a number, e.g. for
#'   Bogon moth neuron \code{219}, this is yuor
#'   \href{https://insectbraindb.org/app/neuron/219}{ticket}.
#' @param progress if \code{TRUE} or a numeric value, a progress bar is shown to
#'   track the state of your download
#' @details Multiple neurons are read, their SWC files as hosted at
#'   https://ibdb-file-storage.s3.amazonaws.com/ are downloaded to a temporary
#'   directory, and read using \code{\link[nat]{read.neurons}} into a
#'   \code{\link[nat]{neuronlist}} object in R. This format and its manipulation
#'   is described in detail \href{https://jefferis.github.io/nat/}{here}. When
#'   using \code{insectbraindb_read_neurons}, meta data for the neuron is also
#'   returned that gives a neuron's ID, short name, long name, associated
#'   laboratory and publication, if available, and the associated insect
#'   species. As of May 2019, data from the following
#'   \href{https://insectbraindb.org/app/species}{species} is hosted on
#'   insectbraindb.org : \itemize{
#'
#'   \item \emph{Agrotis infusa} Bogong moth
#'
#'   \item \emph{Agrotis segetum} Turnip moth
#'
#'   \item \emph{Apis mellifera} Honeybee
#'
#'   \item \emph{Apis mellifera} Honeybee
#'
#'   \item \emph{Danaus plexippus} Monarch Butterfly
#'
#'   \item \emph{Helicoverpa armigera} Cotton Bollworm,
#'
#'   \item \emph{Helicoverpa assulta} Oriental tobacco budworm
#'
#'   \item \emph{Heliothis virescens} Tobacco budworm
#'
#'   \item \emph{Macroglossum stellatarum} Hummingbird hawk moth
#'
#'   \item \emph{Manduca sexta} Tobacco hornworm
#'
#'   \item \emph{Megalopta genalis} Sweat bee
#'
#'   \item \emph{Nasonia vitripennis} Jewel wasp
#'
#'   \item \emph{Scarabaeus lamarcki} Diurnal dung beetle
#'
#'   \item \emph{Schistocerca gregaria} Desert Locust
#'
#'   }
#'
#'   Note that since neurons are reconstructed from many different neural
#'   species, there is no 'standard' orientation between species, but within a
#'   species these neurons are registered to a template brain, usually using
#'   elastix. To visualise the templatebrain, use \code{plot3d} on class
#'   \code{hxsurf} objects downloaded using
#'   \code{\link{insectbraindb_read_brain}}.
#' @return a \code{nat} package \code{\link[nat]{neuronlist}} object, replete
#'   with metadata, is returned
#' @seealso \code{\link{insectbraindb_neuron_info}},
#'   \code{\link{insectbraindb_read_brain}},
#'   \code{\link{insectbraindb_species_info}}
#' @export
#' @rdname insectbraindb_read_neurons
insectbraindb_read_neurons <- function(ids = NULL, progress = TRUE){
  if(is.null(ids)){
    ids = insectbraindb_neuron_info()$id
  }
  temp = tempdir()
  urls = success = c()
  df = data.frame()
  for(i in 1:length(ids)){
    id = ids[i]
    neuron_info = insectbraindb_fetch(path = paste0("archive/neuron/?format=json&id=",id),
                                    body = NULL,
                                    parse.json = TRUE,
                                    simplifyVector=FALSE,
                                    include_headers = FALSE,
                                    insectbraindb_url = "https://insectbraindb.org")
    if(is.na(neuron_info)){
      warning("warning: information on ", id, " could not be found")
      next
    }
    if(!length(neuron_info[[1]]$data$reconstructions)){
      warning("neuron with id ", id," could not be read")
      next
    } else if (!length(neuron_info[[1]]$data$reconstructions[[1]]$viewer_files)){
      warning("neuron with id ", id," could not be read")
      next
    }
    uuid = neuron_info[[1]]$data$reconstructions[[1]]$viewer_files[[1]]$uuid
    pub = unlist(neuron_info[[1]]$data$publications)
    ndf = data.frame(id = id,
                     short_name = changenull(neuron_info[[1]]$data$short_name),
                     neuropil_full_name = changenull(neuron_info[[1]]$data$full_name),
                     scientific_name = changenull(neuron_info[[1]]$data$species$scientific_name),
                     common_name = changenull(neuron_info[[1]]$data$species$common_name),
                     sex = changenull(neuron_info[[1]]$data$sex),
                     hemisphere = changenull(neuron_info[[1]]$data$hemisphere),
                     laboratory = changenull(neuron_info[[1]]$data$group_head),
                     publication = changenull(pub["doi"]),
                     year = changenull(pub["date"]))
    df = rbind(df, ndf)
    df = df[!duplicated(df$id),]
    rownames(df) = df[,"id"]
    swc.path = insectbraindb_fetch(path = paste0("filestore/download_url/?uuid=", uuid),
                                 body = NULL,
                                 parse.json = TRUE,
                                 simplifyVector=FALSE,
                                 include_headers = FALSE,
                                 insectbraindb_url = "https://insectbraindb.org")$url
    success = c(success, i)
    urls = c(urls, swc.path)
    if(progress) insectbraindb_progress(i/length(ids)*100, max = 100, message = "downloading neuron information")
  }
  temp.files = success = c()
  for (url in 1:length(urls)){
    localfile= paste0(temp,"/", url, ".swc")
    if(!file.exists(localfile)){
      t=try(utils::download.file(urls[url], localfile, mode='wb', quiet = TRUE))
      if(inherits(t,'try-error')) {
        message("unable to download ", urls[url])
        next
      }
    }
    success = c(success, url)
    temp.files = c(temp.files, localfile)
    if(progress) insectbraindb_progress(url/length(urls)*100, max = 100, message = "downloading SWC files")
  }
  neurons = read.neurons(temp.files)
  names(neurons) = df[success,"id"]
  neurons[,] = df[success,]
  neurons
}
