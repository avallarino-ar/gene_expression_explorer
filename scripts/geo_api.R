library(XML)
library(purrr)
library(glue)
library(GEOquery)

# Función interna. Ignorar
mensaje_error <- function(nombre) {
  print('Hubo un error inesperado. Ver informaci?n pertinente abajo.')
  print(nombre)
}


# Función interna, no se usa directamente.
generar_url <- function(t, nmax) {
  base <-
    'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?'
  db <- 'db=gds'
  t <- gsub(' ', '+', t)
  # term <- glue('&term={t}+AND+gds[Entry%20Type]')
  term <- glue('&term={t}+AND+gds[Entry%20Type]')
  retmax = glue('&retmax={nmax}') # numero de resultados
  paste0(base, db, term, retmax)
}

# esta función permite realizar búsquedas en la base de datos de expresión
# de genes.
# Toma dos parámetros: una string con los términos que se quieren buscar
# y el número de resultados que se quieren buscar. El default es 10
# Regresa un vector con todos los IDs de los resultados
listar_opciones <- function(t, nmax = 10) {
  url <- generar_url(t, nmax)
  download.file(url, 'busqueda.xml', quiet = TRUE)
  results <- xmlParse('busqueda.xml')
  ids <- xmlToList(results)$IdList %>% flatten_chr()
  ids
}


# Función interna, no se usa directamente.
ver_sumario <- function(uid) {
  base <-
    'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?'
  db <- 'db=gds'
  id <- glue('&id={uid}')
  url <- paste0(base, db, id)
  download.file(url, 'q.xml', quiet = TRUE)
  results <- xmlToList(xmlParse('q.xml'))
  titulo <- results$DocSum[4]$Item$text
  descripcion <- results$DocSum[5]$Item$text
  c(titulo, descripcion)
}


# esta función toma un vector con IDs numéricos de la base de datos de 
# expresión de genes y te regresa un dataframe con los títulos de los estudios 
# y sus descripciones
leer_opciones <- function(uids) {
  df <- data.frame(id = rep(' ', length(uids)),
                   title = rep(' ', length(uids)), 
                   desc = rep(' ', length(uids)),
                   stringsAsFactors = FALSE)
  for (i in seq(uids)) {
    b <- ver_sumario(uids[i])
    df$id[i] <- uids[i]
    df$title[i] <- b[1]
    df$desc[i] <- b[2]
    Sys.sleep(0.5)
  }
  df
}

# plataforma <- 

# esta función toma la plataforma del estudio que descargamos y la matriz de 
# expresión de genes y descarga la información de todos los genes encontrados
db_genes <- function(gid, matriz) {
  gds <- getGEO(gid, destdir=".")
  plataforma <- Meta(gds)$platform
  glp <- getGEO(plataforma, destdir=".")
  # sacamos los nombres de los genes de la matriz de expresion original
  genes <- rownames(matriz)
  gen_db <- Table(glp)[Table(glp)$ID %in% genes,]
  gen_db
}

db_genes_01 <- function(plataforma) {
  gds <- getGEO(plataforma, destdir=".")
  
  m <- as.matrix(Table(gds)[,3:as.numeric((Meta(gds)$sample_count)) + 2])
  rownames(m) <- Table(gds)$ID_REF
  
  m <- m[rowSums(is.na(m)) != ncol(m), ]
}


# Esta función toma el ID de un gen y la base de datos correspondiente
# y regresa la secuencia de ADN del gen, su nombre, sus funciones, los 
# componentes celulares en que se encuentra y los procesos en que participa
info_gen <- function(id, db) {
  g <- db[db$ID == id, ]
  sec <- g$SEQUENCE
  nom <- g$Definition
  co <- g$Ontology_Component
  pro <- g$Ontology_Process
  fu <- g$Ontology_Function
  list(Nombre=nom, Secuencia=sec, Funcion=fu, Componente=co, Proceso=pro)
}

concatenar_info <- function(gen1, gen2) {
    paste0('FIRST GEN ================================', '\n\n',
           'Name', '\n', gen1$Nombre, '\n\n',
           'Sequence', '\n', gen1$Secuencia, '\n\n',
           'Molecular function', '\n', gen1$Funcion, '\n\n',
           'Cellular component', '\n', gen1$Componente, '\n\n',
           'Biological process', '\n', gen1$Proceso, '\n\n',
           'SECOND GEN ================================', '\n\n',
           'Name', '\n', gen2$Nombre, '\n\n',
           'Sequence', '\n', gen2$Secuencia, '\n\n',
           'Molecular function', '\n', gen2$Funcion, '\n\n',
           'Cellular component', '\n', gen2$Componente, '\n\n',
           'Biological process', '\n', gen2$Proceso, '\n\n')
}
