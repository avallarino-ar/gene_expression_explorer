
<img src="/resources/logo.png" alt="alt text" width=80 height=100>

# Gene Expression Explorer

Shiny app para explorar los patrones de expresión de genes con base en resultados de experimentos de de microarreglos. Desarrollada para el curso de Métodos Análiticos 2019, impartido en el ITAM por el profesor Felipe González.

### Autores

* Ariel Vallarino. [GitHub](https://github.com/avallarino-ar)
* Francisco Álvarez. [GitHub](https://github.com/fralvro/)
* Francisco Acosta. [GitHub](https://github.com/facosta8)

#### Funcionamiento

Esta herramienta nos permite buscar y explorar las bases de datos disponibles en línea en la plataforma de GEO y tiene los siguiente componentes:

* **Browser**. Permite buscar los estudio disponibles en la plataforma GEO y ver el resumen del estudio.

* **Genes**. Permite seleccionar un estudio y descargar los datos de expresión correspondientes a él. Tras la operación, puede verse el número de genes que se analizaron y el número de muestras.

* **Genes similares**. En esta sección se realiza el análisis de LSH con distancias euclidianas, con el fin de generar un cierto número de cubetas con genes cercanos entre sí. Una vez que el análisis concluye, el usuario puede seleccionar cualquier de las cubetas y el programa calcula la distancia real entre los genes, que se representa mediante un heatmap. Al hacer clic en cualquier celda del heatmap, es posible consultar las características de los genes que se comparan; esto incluye su nombre, secuencia, función, componentes celulares en los que se localiza y los procesos en que participa. Esto no está disponible para todos los estudios, ya que la información de a qué gen corresponde cada punto del microarreglo es algo que el fabricante pone en línea.

* **Red**. En esta sección puede verse la red de los genes de cualquiera de las cubetas detectadas. Es posible seleccionar a genes específicos (para ver cuáles son sus conexiones directas), así como modificar la distancia mínima para que se formen enlaces entre los diferentes nodos de la red.


