
lsh_gene <- function(df_genes){
  # quito las columnas con valores NA. Son pocas  , pero igual debemos 
  # decidir si queremos quitarlas o cambiar los NA por 0.
  df_genes <- drop_na(df_genes)
  m <- as.matrix(df_genes[,-1])
  rownames(m) <- df_genes[,1]
  
  ##########################################
  ## Funciones
  # Funcion para crear un vector unitario de longitud n
  crear_vector <- function(n) {
    x <- runif(n, 0, 1)
    x / sqrt(sum(x^2))
  }
  
  # funci�n para crear una funci�n hash con un vector aleatorio y 
  # determinar en qu� segmento cae el hash.
  crear_hash <- function(n, d) {
    v <- crear_vector(n)
    f <- function(x) {
      as.integer(round((v %*% x)/d, 0))
    }
    f
  }
  
  # funcion para, ya tiendo un vectorsote, lo dividas en las cubetas
  # que quieres. Para distinguirlas, antepone una letra; lo cual significa
  # que tendremos que modificarla si queremos m�s de 26 cubetas
  crear_cubetas <- function(vector, n_cubetas) {
    ifelse(length(vector)%%n_cubetas == 0, 
           t <- length(vector)/n_cubetas,
           stop())
    cubetas <- split(vector, ceiling(seq_along(vector)/t)) %>% 
      lapply(paste0, collapse = '-') %>% 
      flatten_chr()
    paste0(letters[1:n_cubetas], '||', cubetas)
  }
  
  # le das dos nombres de genes y los busca en el documento con 
  # candidatos. Si est�n, cuenta en cu�ntas cubetas aparecen
  # juntos
  buscar_cubetas <- function(v1,v2, dd) {
    conteo = 0
    for (i in 1:nrow(dd)) {
      exito <- 
        v1 %in% dd$candidatos[[i]] &
        v2 %in% dd$candidatos[[i]]
      conteo = conteo + as.integer(exito)
    }
    conteo
  }
  
  #######################################
  ### Aplicacion
  
  # si quieren hacer una prueba chica, pueden hacer un muestreo
  #mm <- head(m, 2000)
  mm <- m
  
  t <- 200  # numero de funciones hash
  # tama�o de cada segmento en mi hiperplano. Determina las distancias
  # en mi familia
  delta <- 10
  b <- 25   # numero de cubetas
  v <- ncol(mm)  # tama�o de cada vector
  r <- t/b  # elementos por cubeta
  
  # creamos la lista con todas las funciones hash
  lista <- replicate(t, crear_hash(v, delta))
  
  # la aplicamos a todos los elementos
  c <- sapply(lista, function(x) apply(mm, MARGIN=1, x))
  # creamos las cubetas
  cc <- t(apply(c, MARGIN=1, crear_cubetas, n_cubetas=b))
  # agrupamos por cubetas
  df_cubetas <- as_tibble(cc, rownames='gen') %>% 
    gather('v', 'cubeta', -gen) %>% 
    select(-v) %>% 
    group_by(cubeta) %>% 
    summarise(n_elementos = n(),
              candidatos = list(gen)) %>% 
    filter(n_elementos >= 8) %>%   
    arrange(desc(n_elementos)) 
  
  # eliminamos las cubetas de un elemento
  df_cubetas <- filter(df_cubetas, n_elementos > 1)
  
  return(df_cubetas)
}  