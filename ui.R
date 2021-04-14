ui <- dashboardPage(  
dashboardHeader(title = "Gene Expression Explorer "),
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      
      # ---------------------------------------------------------------------- #          
      # 1: Buscador
      # ---------------------------------------------------------------------- #
      menuItem("Browser", tabName = "browser", icon = icon("search")),
      # ---------------------------------------------------------------------- #          
      # 2: Gen
      # ---------------------------------------------------------------------- #
      menuItem("Genes", tabName = "gen", icon = icon("dna")),
      # ---------------------------------------------------------------------- #
      # 3: Grupos
      # ---------------------------------------------------------------------- #
      menuItem("Genes similares", tabName = "grupos", icon = icon("spinner")),
      # ---------------------------------------------------------------------- #
      # 4: Red
      # ---------------------------------------------------------------------- #
      menuItem("Red", tabName = "network", icon = icon("project-diagram"))      
    )
  ),

# ---------------------------------------------------------------------------- #            

  ## Body content
  dashboardBody(
    tabItems(
      # ---------------------------------------------------------------------- #
      # 1: Browser
      # ---------------------------------------------------------------------- #
      tabItem(tabName = "browser",
              fluidRow(
                  box(
                    title = "Busqueda de estudios:",
                    solidHeader = TRUE,
                    status = "primary",
                    textInput("i_gen", "Selección:", 
                                placeholder = 'Elija el termino que quiera buscar'),
                    width = 8
                  ),
                box(
                  title = "Cantidad a descargar:",
                  solidHeader = TRUE,
                  status = "primary",
                  numericInput("i_cant_result", "Cant.Resultados:", 10,
                               min = 1, max = 100),
                  width = 4
                  # background = "light-blue"
                ),
                column(12, align="left",
                  actionButton("btn01", 
                               label=" Listar resultados ", 
                               icon = icon("download"),
                               style="color: #fff; background-color: coral; border-color: light-gray")
                )
              ),
            
              box(
                solidHeader = TRUE,
                status = "primary",
                DT::dataTableOutput("expr"),
                width = 14,
                title = "Expresiones"
              ),
              verbatimTextOutput("expr_txt")
      ),
      # ---------------------------------------------------------------------- #
      
      # ---------------------------------------------------------------------- #          
      # 2: Gen
      # ---------------------------------------------------------------------- #
      tabItem(tabName = "gen",
              fluidRow(
                box(
                  title = "Expresión",
                  selectInput("i_expresion", "Selección:",
                              choices = lst_expresiones),
                  width = 6,
                  background = "light-blue"
                ),
                valueBoxOutput("gen_box1", width = 3),
                
                valueBoxOutput("gen_box2", width = 3),
            
                column(12, align="left", 
                  actionButton("btn02", label=" Buscar microarray ", icon = icon("download"),
                               style="color: #fff; background-color: coral; border-color: light-gray")
                ),
                box(
                    DT::dataTableOutput("gen"),
                    width = 12,
                    # background = "light-blue",
                    title = "Genes"
                )
              )
      ),
      # ---------------------------------------------------------------------- #
      
      # ---------------------------------------------------------------------- #          
      # 3: Grupos
      # ---------------------------------------------------------------------- #
      tabItem(tabName = "grupos",
              fluidRow(
                valueBoxOutput("grp_box1", width = 4),
                valueBoxOutput("grp_box2", width = 4),
                valueBoxOutput("grp_box3", width = 4),
                
                column(12, align="left", 
                       actionButton("btn03", label=" Generar similitudes ", icon = icon("layer-group"),
                                    style="color: #fff; background-color: coral; border-color: light-gray")
                ),
                box(
                  title = "Grupos de genes:",
                  solidHeader = TRUE,
                  status = "primary",
                  selectInput("i_cubetas", "Selección:", 
                              choices = lst_cubetas),
                  width = 8
                  
                ),
                box(
                  plotlyOutput("grupos"),
                  width = 12,
                  title = "Grupo de genes similares (cercanos)"
                ),
                verbatimTextOutput("selection")
                
              )
      ),
      # ---------------------------------------------------------------------- #

      # ---------------------------------------------------------------------- #
      # 5: Red
      # ---------------------------------------------------------------------- #
      tabItem(tabName = "network",
              fluidRow(
                valueBoxOutput("network_box1"),
                valueBoxOutput("network_box2"),
                valueBoxOutput("network_box3"),
                
                box(
                  visNetworkOutput("network"),
                  width = 12,
                  title = "Red de genes similares (cercanos)"
                ),
                
                box(
                  sliderInput("i_distance",
                              "Distancias:",
                              min = 0,
                              max = max_dist,
                              value=c(0,max_dist / 4),
                              step = 0.1),
                  width = 6
                )
              )
      )
      # ---------------------------------------------------------------------- #      
    )
  )
)

