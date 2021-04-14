server <- function(input, output, session) {
  
  # ---------------------------------------------------------------------- #          
  # 1: botón 01:
  # ---------------------------------------------------------------------- #
  observeEvent(input$btn01, {
    
    if (input$i_gen == " "){
      showNotification("Debe seleccionar opción a descargar", type = "warning")
      
    } else {
      withProgress(message = 'Obteniendo datos...', value = 1, {
        lst_opciones <- listar_opciones(input$i_gen, nmax = input$i_cant_result)
        
        df_opciones <- leer_opciones(lst_opciones)
        # Genero listado de expresiones:
        lst_expresiones <- c(" ", df_opciones %>% 
                               mutate(ids = paste(id, " - " ,title)) %>%  
                               select(ids) %>%
                               as.list())
        updateSelectInput(session, "i_expresion", choices = lst_expresiones)
    
        if (nrow(df_opciones) > 0){
          output$expr <- renderDataTable(df_opciones)
        }
      })
    }
  })

  # ---------------------------------------------------------------------- #          
  # 2: botón 02:
  # ---------------------------------------------------------------------- #
  observeEvent(input$btn02, {
    
    withProgress(message = 'Obteniendo datos...', value = 1, {
      # Obtengo el ID seleccionado:
      id <- unlist(strsplit(input$i_expresion, " " ))[1]
      print(id) #Log
      
      genes <<- db_genes_01(paste0('GDS',id))
      # colnames(genes)[1] <- 'gen'
      print(nrow(genes)) #Log
      
      base_datos_genes <<- db_genes(paste0('GDS', id), genes)
    
    })
  
    # Muestro datos en dataTableOutput("gen")
    output$gen <- renderDataTable(genes)
    
    output$gen_box1 <- renderValueBox({
      valueBox(
        prettyNum(nrow(genes), big.mark = ","),
        "Cantidad de genes",
        icon = icon("dna"),
        color = "red"
      )
    })
    output$gen_box2 <- renderValueBox({
      valueBox(
        prettyNum(ncol(genes) , big.mark = ","),
        "Cantidad de muestras",
        icon = icon("list"),
        color = "yellow"
      )
    })
  })
  
  # ---------------------------------------------------------------------- #          
  # 2: botón 03:
  # ---------------------------------------------------------------------- #
  observeEvent(input$btn03, {
    
    if (nrow(genes)==0){
      showNotification("Debe descargar microarray", type = "warning")
    } else {
      withProgress(message = 'Agrupando genes similares...', value = 1, {
        # Genero dataframe con los datos de los genes:
        df_tmp <- cbind(gen=rownames(genes), data.frame(genes, row.names=NULL))
        df_cubetas <<- lsh_gene(df_tmp) %>% arrange(n_elementos)
      
        if (nrow(df_cubetas) > 0){
          # Genero listado de cubetas:
          lst_cubetas <- c(" ", df_cubetas %>% 
                             mutate(ids = paste(row_number(), 
                                                " - ", 
                                                n_elementos, 
                                                " - ",  
                                                unlist(lapply(candidatos, "[[", 1)))) %>%
                             select(ids))
          
          updateSelectInput(session, "i_cubetas", choices = lst_cubetas)
        }
      })  
    }
  })
  # -------------------------------------------------------------------------- #   
  
  # -------------------------------------------------------------------------- #     
  # 1: Browser
  # -------------------------------------------------------------------------- #
  output$expr <- renderDataTable({
    
    if (nrow(df_opciones) > 0){
      DT::datatable(df_opciones, selection = "single", 
                    options = list(ordering=FALSE))
    }
  })
  
  output$expr_txt <- renderPrint({
      cat("Seleccione una categoría para descargar un listado de expresiones...")
  })
  # -------------------------------------------------------------------------- #   
  
  # -------------------------------------------------------------------------- #     
  # 2: Gen
  # -------------------------------------------------------------------------- #
  output$gen <- renderDataTable({
   
    #----------[ Muestro ValueBox:
    output$gen_box1 <- renderValueBox({
      valueBox(
        prettyNum(0, big.mark = ","),
        "Cantidad de genes",
        icon = icon("dna"),
        color = "red"
      )
    })
    output$gen_box2 <- renderValueBox({
      valueBox(
        prettyNum(0 , big.mark = ","),
        "Cantidad de muestras",
        icon = icon("list"),
        color = "yellow"
      )
    })
    #---------- Muestro ValueBox ].
    
    #----------[ Muestro Gen:  
    if (nrow(genes) > 0){
      DT::datatable(genes, selection="single", 
                    options = list(ordering=FALSE))
    }
    #---------- Muestro Gen ].
  })
  # -------------------------------------------------------------------------- #
  
  # -------------------------------------------------------------------------- #     
  # 3: Genes similares:
  # -------------------------------------------------------------------------- #
  output$grupos <- renderPlotly({
    
    s <- event_data("plotly_click", source = "cubeta")
    
    print(paste('input$i_cubetas', input$i_cubetas))
    if (input$i_cubetas != " "){
      # Obtengo el ID de la cubeta seleccionada:
      id <- unlist(strsplit(input$i_cubetas, " " ))[1]
      
      cubeta_tmp <- unlist(df_cubetas[id,]$candidatos)

      # Calculo las distancias para los genes de la cubeta seleccionada:
      cubeta_dist <<- as.matrix(dist(genes[cubeta_tmp,])) # habia una coma extra 
      cubeta_dist_m <<- as.matrix(cubeta_dist[,-1])
      max_dist <<- round(max(cubeta_dist_m),0) + 1
      
      cubeta_rs <<- cubeta_dist
      cubeta_rs[upper.tri(cubeta_rs)] <<- NA
      cubeta_rs <<- melt(cubeta_rs, na.rm = TRUE)
      colnames(cubeta_rs) <<- c('from', 'to', 'weight')
      
      cubeta_rs <<- cubeta_rs %>%
        mutate(distancia = weight, weight = weight * -1 )
      
      updateSliderInput(session, 'i_distance',  
                        min = 0,
                        max = max_dist,
                        value=c(0,max_dist / 4),
                        step = 0.1)
    }
    #----------[ Muestro ValueBox:
    output$grp_box1 <- renderValueBox({
      valueBox(
        prettyNum(nrow(genes), big.mark = ","),
        "Cantidad de genes",
        icon = icon("dna"),
        color = "red"
    )
  })
    output$grp_box2 <- renderValueBox({
      valueBox(
        prettyNum(nrow(df_cubetas), big.mark = ","),
        "Cantidad de grupos",
        icon = icon("spinner"),
        color = "yellow"
      )
    })
    output$grp_box3 <- renderValueBox({
      valueBox(
        prettyNum(nrow(cubeta_dist_m) , big.mark = ","),
        "Tamaño del grupo",
        icon = icon("project-diagram"),
        color = "green"
      )
    })
    #---------- Muestro ValueBox ].
    
    #----------[ Muestro cubeta:
    if (nrow(cubeta_dist_m) > 0) {
      plot_ly(z = cubeta_dist_m, type = "heatmap", x=colnames(cubeta_dist_m), y=rownames(cubeta_dist_m))
    }
    #----------Muestro cubeta ].
  })
  
  output$selection <- renderPrint({
    s <- event_data("plotly_click")
    infox <- info_gen(s$x[1], base_datos_genes)
    infoy <- info_gen(s$y[1], base_datos_genes)
    info <- concatenar_info(infox, infoy)
    if (length(s) == 0) {
      cat("Haz click en una celda del heatmap para ver los genes comparados.")
    } else {
      cat(info)
    }
  })
  # -------------------------------------------------------------------------- #

  # -------------------------------------------------------------------------- #
  # 4: Red:
  # -------------------------------------------------------------------------- #
  output$network <- renderVisNetwork({
    
    df_red <- cubeta_rs %>% filter(distancia >= input$i_distance[1] & distancia <= input$i_distance[2])
    
    # #----------[ Muestro ValueBox:
    output$network_box1 <- renderValueBox({
      valueBox(
        prettyNum(nrow(genes), big.mark = ","),
        "Total de genes",
        icon = icon("dna"),
        color = "red"
      )
    })
    
    output$network_box2 <- renderValueBox({
      valueBox(
        prettyNum(nrow(df_cubetas) , big.mark = ","),
        "Grupos", 
        icon = icon("list"),
        color = "yellow"
      )
    })
    
    output$network_box3 <- renderValueBox({
      valueBox(
        prettyNum(nrow(cubeta_dist_m), big.mark = ","),
        "Tamaño de grupo", 
        icon = icon("project-diagram"),
        color = "green"
      )
    })
    #---------- Muestro ValueBox ].
    withProgress(message = 'Making plot', value = 10, {
      
      if (nrow(df_red) > 0) { 
        nodos <- as.character(df_red$from)
        nodos <- unique(c(nodos, as.character(df_red$to)))
        
        nodes <- data.frame(id = nodos, label = nodos,
                            group = nodos)
        
        edges <- data.frame(from = df_red[,1],
                            to = df_red[,2]) 
        
        visNetwork(nodes, edges, width = "100%") %>%
          visPhysics(solver ='forceAtlas2Based', 
                     forceAtlas2Based = list(gravitationalConstant = - 100, 
                                             centralGravity = 0.001, 
                                             springLength = 100,
                                             springConstant = 0.05,
                                             avoidOverlap = 0
                     )) %>% 
          visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE)
        }
    })
  })
  # -------------------------------------------------------------------------- # 
}