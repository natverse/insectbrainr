#' @title Read 3D insect brain meshes from insectbraindb.org
#'
#' @description Read templatebrains, comprised of their different neuropils, for various insect species from from insectbraindb.org (2018 version),
#' given a single latin names for the species desired. Metadata for available neurons can be seen, and IDs chosen,
#' by calling \code{\link{insectbraindb_species_info}}. 3D triangular brain meshes are returned as a \code{nat} package \code{\link[nat]{hxsurf}}
#' object, which mimics the Amira surface format. These can be be plotted in 3D using \code{rgl} and analysed with tools from the \code{nat} ecosystem.
#' This incldue subseting by neuropil, i.e.. if you only want to visualise or analyse the antennal lobe.
#' @param species the full scientific name for a species. The available options can be seen \href{https://insectbraindb.org/app/species}{here}
#' @param brain.sex the sex of the species' brain. The available options can be seen \href{https://insectbraindb.org/app/species}{here}
#' @param progress if \code{TRUE} or a numeric value, a progress bar is shown to track the state of your download
#' @details A single 3D brain object is read, a .obj file for each of its neuropils is downloaded from https://ibdb-file-storage.s3.amazonaws.com/
#'  to a temporary directory, and read using \code{\link[readobj]{read.obj}} into a
#'  \code{\link[nat]{hxsurf}} object in R, which mimics the Amira surface format.
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
#'  Note that since neurons are reconstructed from many different neural species,
#'  there is no 'standard' orientation between species, but within a species these neurons are registered to a
#'  template brain, usually using elastix.
#' @return a \code{nat} package \code{\link[nat]{hxsurf}} object, which mimics the Amira surface format, replete with metadata that can be
#' accessed using \code{$}
#' @seealso \code{\link{insectbraindb_neuron_info}}, \code{\link{insectbraindb_read_neurons}}, \code{\link{insectbraindb_species_info}}
#' @inherit insectbraindb_read_neurons examples
#' @export
#' @rdname insectbraindb_read_brain
insectbraindb_read_brain <- function(species = insectbraindb_species_info()$scientific_name,
                                     brain.sex = c("UNKNOWN", "MALE", "FEMALE"),
                                     progress = TRUE){
  species = match.arg(species)
  brain.sex = match.arg(brain.sex)
  db = insectbraindb_species_info()
  id = db[db$scientific_name==species,"id"]
  if(!length(id)){
    stop("This the species ", species ,"is not available for public download")
  }
  brain_info = insectbraindb_fetch(path = paste0("archive/species/most_current_permitted/?species_id=", id),
                                 body = NULL,
                                 parse.json = TRUE,
                                 simplifyVector=FALSE,
                                 include_headers = FALSE,
                                 insectbraindb_url = "https://insectbraindb.org")
  meta = names(brain_info)[!sapply(brain_info,is.list)]
  meta = unlist(brain_info[meta])
  sexes  = c(tryCatch(brain_info$reconstructions[[1]]$sex, error = function(e) NA),
             tryCatch(brain_info$reconstructions[[2]]$sex, error = function(e) NA),
             tryCatch(brain_info$reconstructions[[3]]$sex, error = function(e) NA))
  sex.index = match(brain.sex, sexes)
  if(is.na(sex.index)){
    warning("No reconstruction for species ", species, " returning NULL")
    return(NULL)
  }
  data = tryCatch(brain_info$reconstructions[[sex.index]]$viewer_files,
                  error = function(e){
                    warning("No reconstruction for species ", species, " returning NULL")
                    return(NULL)
                  }
  )
  if(!length(data)){
    warning("No reconstruction for species ", species, " of sex ", brain.sex, " returning NULL")
    return(NULL)
  }
  paths = hemispheres = structure.names = structure.shorts = structure.colors = sex = c()
  for(d in data){
    sex = c(sex, d$sex)
    paths = c(paths, d$p_file$path)
    hemispheres = c(hemispheres, changenull(d$structures[[1]]$hemisphere, to = "noside"))
    structure.names = c(structure.names, changenull(d$structures[[1]]$structure$name, to = "ambiguous"))
    structure.shorts = c(structure.shorts, changenull(d$structures[[1]]$structure$abbreviation, to = "AMBIG"))
    structure.colors = c(structure.colors, changenull(d$structures[[1]]$structure$color, to = "grey"))
  }
  obj.name = paste(structure.shorts, hemispheres, 1:length(structure.shorts), sep = "_")
  obj.name = gsub("_$","",obj.name)
  urls = paste0("https://s3.eu-central-1.amazonaws.com/ibdb-file-storage/",paths)
  temp.files = success = c()
  temp = tempdir()
  for (url in 1:length(urls)){
    localfile = paste0(temp,"/", paste0(paste(unlist(strsplit(species," ")),collapse="_"), "_", sex[1], "_", basename(urls[url]) ))
    if(!file.exists(localfile)){
      t=try(utils::download.file(urls[url], localfile, mode='wb', quiet = TRUE))
      if(inherits(t,'try-error')) {
        warning("unable to download ", urls[url], " and save as ", localfile)
        next
      }
    }
    success = c(success, url)
    temp.files = c(temp.files, localfile)
    if(progress) insectbraindb_progress(url/length(urls)*100, max = 100, message = "downloading .obj files")
  }
  objs = lapply(temp.files, function(x)
    tryCatch(readobj::read.obj(x, convert.rgl = T), error = function(e) NULL)[[1]])
  success = success[!sapply(objs, is.null)]
  objs = objs[!sapply(objs, is.null)]
  objs = lapply(objs, nat::as.hxsurf)
  brain = list()
  brain$Vertices = data.frame()
  brain$Regions = list()
  brain$RegionList = brain$RegionColourList = c()
  class(brain) = c("hxsurf","list")
  count = 0
  for(i in 1:length(objs)){
    o = objs[[i]]
    v = o$Vertices
    v$PointNo = v$PointNo + count
    brain$Vertices = rbind(brain$Vertices, v)
    region.name = obj.name[success][i]
    regions = o$Regions$Interior+count
    brain$Regions[[region.name]] = regions
    brain$RegionList = c(brain$RegionList, region.name)
    brain$RegionColourList = c(brain$RegionColourList, structure.colors[success][i])
    count = count + nrow(o$Vertices)
    if(progress) insectbraindb_progress(i/length(objs)*100, max = 100, message = "assembling hxsurf object")
  }
  brain$neuropil_full_names = structure.names[success]
  brain$hemispheres = hemispheres[success]
  brain$scientific_name = meta["scientific_name"]
  brain$common_name = meta["common_name"]
  brain$sex = brain.sex
  brain$id = meta["id"]
  brain$host_lab = meta["host_lab"]
  brain$description = meta["description"]
  brain
}
