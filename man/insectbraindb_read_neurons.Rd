% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_neurons.R
\name{insectbraindb_read_neurons}
\alias{insectbraindb_read_neurons}
\title{Read insect neurons from insectbraindb.org}
\usage{
insectbraindb_read_neurons(ids = NULL, progress = TRUE)
}
\arguments{
\item{ids}{a neuron ID, or vector of neuron IDs, as recorded in the
insectbraindb.org. If set to \code{NULL} (default) then all neurons in the
database are read. As of May 2018, this is only 100 readable neurons. A
helpful information page on each neuron can be seen by visiting
"https://insectbraindb.org/app/neuron/id", where id is a number, e.g. for
Bogon moth neuron \code{219}, this is your
\href{https://insectbraindb.org/app/neuron/219}{ticket}.}

\item{progress}{if \code{TRUE} or a numeric value, a progress bar is shown to
track the state of your download}
}
\value{
a \code{nat} package \code{\link[nat]{neuronlist}} object, replete
  with metadata, is returned
}
\description{
Read templatebrain-registered neurons from insectbraindb.org
  (2018 version), given a single ID or vector of neuron IDs. Alternatively,
  if \code{ids} is set to \code{NULL}, all neurons in the database that can
  be read, are read (~100). Metadata for available neurons can be seen, and
  IDs chosen, by calling \code{\link{insectbraindb_neuron_info}}. Neurons are
  returned as a \code{nat} package \code{\link[nat]{neuronlist}} object, that
  can be be plotted in 3D using \code{rgl} and analysed with tools from the
  \code{nat} ecosystem. Each neuron in the insectbraindb is represented by a
  unique numeric ID, a name and is associated with an insect species and a
  publication, by DOI. Some neurons cannot be read because a SWC file is not
  available from insectbraindb.org. You can examine the available neurons
  here \href{https://insectbraindb.org/app/neurons}{here}), while the
  available species may be examined
  \href{https://insectbraindb.org/app/species}{here}). Critically, these
  neurons are registered to standard templates that may be obtained as
  \code{hxsurf} objects in R by using \code{\link{insectbraindb_read_brain}}.
}
\details{
Multiple neurons are read, their SWC files as hosted at
  https://ibdb-file-storage.s3.amazonaws.com/ are downloaded to a temporary
  directory, and read using \code{\link[nat]{read.neurons}} into a
  \code{\link[nat]{neuronlist}} object in R. This format and its manipulation
  is described in detail \href{https://jefferis.github.io/nat/}{here}. When
  using \code{insectbraindb_read_neurons}, meta data for the neuron is also
  returned that gives a neuron's ID, short name, long name, associated
  laboratory and publication, if available, and the associated insect
  species. As of May 2019, data from the following
  \href{https://insectbraindb.org/app/species}{species} is hosted on
  insectbraindb.org : \itemize{

  \item \emph{Agrotis infusa} Bogong moth

  \item \emph{Agrotis segetum} Turnip moth

  \item \emph{Apis mellifera} Honeybee

  \item \emph{Apis mellifera} Honeybee

  \item \emph{Danaus plexippus} Monarch Butterfly

  \item \emph{Helicoverpa armigera} Cotton Bollworm,

  \item \emph{Helicoverpa assulta} Oriental tobacco budworm

  \item \emph{Heliothis virescens} Tobacco budworm

  \item \emph{Macroglossum stellatarum} Hummingbird hawk moth

  \item \emph{Manduca sexta} Tobacco hornworm

  \item \emph{Megalopta genalis} Sweat bee

  \item \emph{Nasonia vitripennis} Jewel wasp

  \item \emph{Scarabaeus lamarcki} Diurnal dung beetle

  \item \emph{Schistocerca gregaria} Desert Locust

  }

  Note that since neurons are reconstructed from many different neural
  species, there is no 'standard' orientation between species, but within a
  species these neurons are registered to a template brain, usually using
  elastix. To visualise the templatebrain, use \code{plot3d} on class
  \code{hxsurf} objects downloaded using
  \code{\link{insectbraindb_read_brain}}.
}
\seealso{
\code{\link{insectbraindb_neuron_info}},
  \code{\link{insectbraindb_read_brain}},
  \code{\link{insectbraindb_species_info}}
}
