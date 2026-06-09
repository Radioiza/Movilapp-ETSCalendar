import '../../../features/catalogs/data/models/carrera_model.dart';
import '../../../features/catalogs/data/models/salon_model.dart';

/// Datos semilla reales de **ESCOM-IPN (Zacatenco)** usados por el modo
/// *demo offline*: carreras, edificios/salones y los planes de estudio 2020
/// completos (mapa curricular oficial) de las tres carreras de la escuela.
///
/// El [SembradorDatos] los inserta una sola vez en sqflite para que toda la
/// app sea demostrable sin un backend en línea.
abstract final class DatosSemillaEscom {
  // --- Coordenadas del campus (Unidad Profesional Adolfo López Mateos) ---
  static const String _mapaCampusEscom =
      'https://www.google.com/maps/search/?api=1&query=19.504697,-99.146589';

  /// Las tres carreras que imparte la ESCOM.
  static const List<CarreraModel> carreras = <CarreraModel>[
    CarreraModel(
      id: 'isc',
      clave: 'ISC',
      nombre: 'Ingeniería en Sistemas Computacionales',
    ),
    CarreraModel(
      id: 'iia',
      clave: 'IIA',
      nombre: 'Ingeniería en Inteligencia Artificial',
    ),
    CarreraModel(
      id: 'lcd',
      clave: 'LCD',
      nombre: 'Licenciatura en Ciencia de Datos',
    ),
  ];

  /// Edificios y salones representativos de la ESCOM.
  static const List<SalonModel> salones = <SalonModel>[
    SalonModel(id: 's-1101', nombre: '1101', edificio: 'Edificio 1', direccionMapa: _mapaCampusEscom),
    SalonModel(id: 's-1102', nombre: '1102', edificio: 'Edificio 1', direccionMapa: _mapaCampusEscom),
    SalonModel(id: 's-1201', nombre: '1201', edificio: 'Edificio 1', direccionMapa: _mapaCampusEscom),
    SalonModel(id: 's-2101', nombre: '2101', edificio: 'Edificio 2', direccionMapa: _mapaCampusEscom),
    SalonModel(id: 's-2102', nombre: '2102', edificio: 'Edificio 2', direccionMapa: _mapaCampusEscom),
    SalonModel(id: 's-2202', nombre: '2202', edificio: 'Edificio 2', direccionMapa: _mapaCampusEscom),
    SalonModel(id: 's-3101', nombre: '3101', edificio: 'Edificio 3', direccionMapa: _mapaCampusEscom),
    SalonModel(id: 's-3102', nombre: '3102', edificio: 'Edificio 3', direccionMapa: _mapaCampusEscom),
    SalonModel(id: 's-lab1', nombre: 'Laboratorio de Cómputo 1', edificio: 'Laboratorios', direccionMapa: _mapaCampusEscom),
    SalonModel(id: 's-lab2', nombre: 'Laboratorio de Cómputo 2', edificio: 'Laboratorios', direccionMapa: _mapaCampusEscom),
    SalonModel(id: 's-labr', nombre: 'Laboratorio de Redes', edificio: 'Laboratorios', direccionMapa: _mapaCampusEscom),
    SalonModel(id: 's-aud', nombre: 'Auditorio A', edificio: 'Unidad de Aprendizaje', direccionMapa: _mapaCampusEscom),
  ];

  /// Profesor evaluador asignado a una **materia específica** (nombres reales
  /// de la planta docente de ESCOM, tomados del SAES). Tiene prioridad sobre
  /// el pool [profesores]; las materias que no aparezcan aquí usan el pool.
  ///
  /// La clave debe coincidir EXACTAMENTE con el nombre de la unidad de
  /// aprendizaje usado en [planesEstudio]. Como muchas materias se comparten
  /// entre carreras (p. ej. "Cálculo" en ISC, IIA y LCD), un mismo registro
  /// aplica a las tres.
  static const Map<String, String> profesoresPorMateria = <String, String>{
    // --- Tronco común / ISC (SAES, Plan 2020 Matutino) ---
    'Fundamentos de Programación': 'Reséndiz Muñoz Rocío',
    'Matemáticas Discretas': 'Herrera Yáñez Crispín',
    'Cálculo': 'Dorantes Villa Claudia Jisela',
    'Análisis Vectorial': 'Guzmán Aguilar Florencio',
    'Comunicación Oral y Escrita': 'Sánchez Moreno Adriana de la P.',
    'Álgebra Lineal': 'Guzmán Aguilar Florencio',
    'Cálculo Aplicado': 'Viveros Vela Karina',
    'Mecánica y Electromagnetismo': 'Salinas Hernández Encarnación',
    'Ingeniería, Ética y Sociedad': 'Arredondo Sánchez Ana Laura',
    'Fundamentos Económicos': 'Castillo Marrufo Juan Antonio',
    'Algoritmos y Estructuras de Datos': 'Tecla Parra Roberto',
    'Análisis y Diseño de Algoritmos': 'Díaz Santiago Ricardo Felipe',
    'Paradigmas de Programación': 'Dávalos López José Carlos',
    'Ecuaciones Diferenciales': 'Silva Martínez Jorge Javier',
    'Fundamentos de Diseño Digital': 'Díaz Toala Iván',
    'Circuitos Eléctricos': 'Alcántara Méndez Alberto Jesús',
    'Bases de Datos': 'Chavarría Báez Lorena',
    'Finanzas Empresariales': 'Galiñanes Rodríguez María Gabriela',
    'Teoría de la Computación': 'Juárez Martínez Genaro',
    'Probabilidad y Estadística': 'Chávez Lima Eduardo',
    'Matemáticas Avanzadas para la Ingeniería': 'Cervantes Espinosa Luis Moctezuma',
    'Diseño de Sistemas Digitales': 'Testa Nava Alexis',
    'Electrónica Analógica': 'Durán Camarillo Edmundo René',
    'Tecnologías para el Desarrollo de Aplicaciones Web': 'Bautista Rosales Sandra Ivette',
    'Sistemas Operativos': 'Cortés Galicia Jorge',
    'Compiladores': 'Ortigoza Campos Andrés',
    'Procesamiento Digital de Señales': 'Mújica Ascencio César',
    'Arquitectura de Computadoras': 'Gómez Mayorga Margarita Elizabeth',
    'Instrumentación y Control': 'Ortega González Rubén',
    'Análisis y Diseño de Sistemas': 'Peredo Valderrama Rubén',
    'Formulación y Evaluación de Proyectos Informáticos': 'Rodríguez Flores Eduardo',
    'Redes de Computadoras': 'Alcaraz Torres Juan Jesús',
    'Inteligencia Artificial': 'Román Godínez Rodrigo Francisco',
    'Sistemas en Chip': 'Aguilar Sánchez Fernando',
    'Métodos Cuantitativos para la Toma de Decisiones': 'Márquez Arreguín Guillermo',
    'Seguridad Informática': 'García Cortés Rocío',
    'Minería de Datos': 'Ocampo Botello Fabiola',
    'Ingeniería de Software': 'Rojas Mexicano Ismael',
    'Aplicaciones para Comunicaciones en Red': 'Moreno Cervantes Axel Ernesto',
    'Desarrollo de Aplicaciones Móviles Nativas': 'Rivera de la Rosa Mónica',
    'Introducción a la Criptografía': 'Cortez Duarte Nidia Asunción',
    'Internet de las Cosas': 'Lerma Magaña Carlos',
    'Trabajo Terminal I': 'Aragón García Maribel',
    'Sistemas Distribuidos': 'Carreto Arellano Chadwick',
    'Administración de Servicios en Red': 'Martínez Rosales Ricardo',
    'Desarrollo de Habilidades Sociales para la Alta Dirección': 'Dorantes Cordero Martha Margarita',
    'Trabajo Terminal II': 'Cordero López Martha Rosa',
    'Gestión Empresarial': 'Maldonado Muñoz Miguel Ángel',
    'Liderazgo Personal': 'Centeno Arrazola María Soledad',

    // --- IIA (Inteligencia Artificial) ---
    'Cálculo Multivariable': 'Hernández Vásquez César',
    'Fundamentos de Inteligencia Artificial': 'Salazar Urbina Álvaro',
    'Procesamiento Digital de Imágenes': 'Cruz Meza María Elena',
    'Aprendizaje de Máquina': 'Martínez Hernández Guadalupe Ana Gabriela',
    'Visión Artificial': 'Serrano Talamantes J. Félix',
    'Procesamiento de Señales': 'Díaz Toala Iván',
    'Algoritmos Bioinspirados': 'Uriarte Arcia Abril Valeria',
    'Tecnologías de Lenguaje Natural': 'Moreno Galván Elizabeth',
    'Cómputo Paralelo': 'Gutiérrez Aldana Eduardo',
    'Redes Neuronales y Aprendizaje Profundo': 'García Salas Horacio Alberto',
    'Ingeniería de Software para Sistemas Inteligentes': 'Carreto Arellano Chadwick',
    'Metodología de la Investigación y Divulgación Científica': 'Celis Domínguez Adriana Berenice',
    'Cómputo en la Nube': 'Carreto Arellano Chadwick', // área afín: sistemas distribuidos
    'Sistemas Multiagentes': 'Ortiz Castillo Marco Antonio',
    'Reconocimiento de Voz': 'Carmona García Enrique Alfonso',
    'Interacción Humano-Máquina': 'Maldonado Castillo Idalia',
    'Programación de Dispositivos Móviles': 'Rivera de la Rosa Mónica', // área afín: apps móviles

    // --- LCD (Ciencia de Datos) ---
    'Introducción a la Ciencia de Datos': 'Rosas Carrillo Ary Shared',
    'Ética y Legalidad': 'Ramírez Guzmán Alicia Marcela',
    'Programación para Ciencia de Datos': 'Ramírez Morales Mario Augusto',
    'Probabilidad': 'Cruz Rojas Jorge Alberto',
    'Métodos Numéricos': 'Gutiérrez Aldana Eduardo',
    'Desarrollo de Aplicaciones Web': 'Bautista Rosales Sandra Ivette',
    'Cómputo de Alto Desempeño': 'Cruz Torres Benjamín',
    'Estadística': 'García Blanquel Claudia',
    'Bases de Datos Avanzadas': 'Portillo Cedillo Manuel',
    'Desarrollo de Aplicaciones para Análisis de Datos': 'López Gómez Alejandro',
    'Matemáticas Avanzadas para Ciencia de Datos': 'Díaz Sánchez Hugo',
    'Procesos Estocásticos': 'Rangel Nahum Carlos Alexis',
    'Aprendizaje de Máquina e Inteligencia Artificial': 'Reyes Vera Abdiel',
    'Analítica y Visualización de Datos': 'López Gómez Alejandro',
    'Modelado Predictivo': 'García Blanquel Claudia',
    'Procesamiento de Lenguaje Natural': 'Ortiz Castillo Marco Antonio',
    'Análisis de Series de Tiempo': 'García Blanquel Claudia',
    'Analítica Avanzada de Datos': 'Núñez Prado César Jesús',
    'Bioinformática Básica': 'García Blanquel Claudia', // área afín: análisis de datos
    'Sistemas de Información Geográfica': 'Torres Ruiz Miguel Jesús',
    'Big Data': 'Román Godínez Rodrigo Francisco',
    'Modelos Econométricos': 'Reyes Vera Abdiel',
    'Administración de Proyectos de TI': 'Guzmán Flores Jessie Paulina',
    'Temas Selectos de Aprendizaje Profundo': 'García Salas Horacio Alberto',
    'Temas Selectos de Inteligencia Artificial': 'Román Godínez Rodrigo Francisco', // área afín: IA
  };

  /// Pool de profesores evaluadores (nombres de ejemplo) repartidos entre las
  /// materias que aún no tienen un docente asignado en [profesoresPorMateria].
  static const List<String> profesores = <String>[
    'Ing. José Antonio Ortiz Ramírez',
    'Dra. Laura Méndez Castillo',
    'M. en C. Roberto Sánchez Pérez',
    'Dr. Miguel Ángel Rivera López',
    'M. en C. Ana Karen Torres Díaz',
    'Ing. Fernando Gutiérrez Rangel',
    'Dra. Patricia Hernández Soto',
    'M. en C. Luis Enrique Vargas Cruz',
    'Dr. Carlos Eduardo Núñez Mora',
    'Ing. Gabriela Ramírez Flores',
  ];

  /// Plan de estudios 2020 por carrera → semestre → unidades de aprendizaje.
  /// Fuente: mapas curriculares oficiales de la ESCOM (vigencia 2020).
  static const Map<String, Map<int, List<String>>> planesEstudio =
      <String, Map<int, List<String>>>{
    'isc': <int, List<String>>{
      1: <String>[
        'Cálculo',
        'Análisis Vectorial',
        'Matemáticas Discretas',
        'Comunicación Oral y Escrita',
        'Fundamentos de Programación',
      ],
      2: <String>[
        'Álgebra Lineal',
        'Cálculo Aplicado',
        'Mecánica y Electromagnetismo',
        'Ingeniería, Ética y Sociedad',
        'Fundamentos Económicos',
        'Algoritmos y Estructuras de Datos',
      ],
      3: <String>[
        'Ecuaciones Diferenciales',
        'Circuitos Eléctricos',
        'Fundamentos de Diseño Digital',
        'Bases de Datos',
        'Finanzas Empresariales',
        'Paradigmas de Programación',
        'Análisis y Diseño de Algoritmos',
      ],
      4: <String>[
        'Probabilidad y Estadística',
        'Matemáticas Avanzadas para la Ingeniería',
        'Electrónica Analógica',
        'Diseño de Sistemas Digitales',
        'Tecnologías para el Desarrollo de Aplicaciones Web',
        'Sistemas Operativos',
        'Teoría de la Computación',
      ],
      5: <String>[
        'Procesamiento Digital de Señales',
        'Instrumentación y Control',
        'Arquitectura de Computadoras',
        'Análisis y Diseño de Sistemas',
        'Formulación y Evaluación de Proyectos Informáticos',
        'Compiladores',
        'Redes de Computadoras',
      ],
      6: <String>[
        'Sistemas en Chip',
        'Seguridad Informática',
        'Minería de Datos',
        'Métodos Cuantitativos para la Toma de Decisiones',
        'Ingeniería de Software',
        'Inteligencia Artificial',
        'Aplicaciones para Comunicaciones en Red',
      ],
      7: <String>[
        'Desarrollo de Aplicaciones Móviles Nativas',
        'Introducción a la Criptografía',
        'Internet de las Cosas',
        'Trabajo Terminal I',
        'Sistemas Distribuidos',
        'Administración de Servicios en Red',
      ],
      8: <String>[
        'Estancia Profesional',
        'Desarrollo de Habilidades Sociales para la Alta Dirección',
        'Trabajo Terminal II',
        'Gestión Empresarial',
        'Liderazgo Personal',
      ],
    },
    'iia': <int, List<String>>{
      1: <String>[
        'Fundamentos de Programación',
        'Matemáticas Discretas',
        'Cálculo',
        'Mecánica y Electromagnetismo',
        'Fundamentos Económicos',
        'Comunicación Oral y Escrita',
      ],
      2: <String>[
        'Algoritmos y Estructuras de Datos',
        'Álgebra Lineal',
        'Cálculo Multivariable',
        'Fundamentos de Diseño Digital',
        'Ingeniería, Ética y Sociedad',
        'Finanzas Empresariales',
      ],
      3: <String>[
        'Análisis y Diseño de Algoritmos',
        'Paradigmas de Programación',
        'Ecuaciones Diferenciales',
        'Bases de Datos',
        'Diseño de Sistemas Digitales',
        'Liderazgo Personal',
      ],
      4: <String>[
        'Fundamentos de Inteligencia Artificial',
        'Probabilidad y Estadística',
        'Matemáticas Avanzadas para la Ingeniería',
        'Tecnologías para el Desarrollo de Aplicaciones Web',
        'Análisis y Diseño de Sistemas',
        'Procesamiento Digital de Imágenes',
      ],
      5: <String>[
        'Aprendizaje de Máquina',
        'Visión Artificial',
        'Teoría de la Computación',
        'Procesamiento de Señales',
        'Algoritmos Bioinspirados',
        'Tecnologías de Lenguaje Natural',
      ],
      6: <String>[
        'Cómputo Paralelo',
        'Redes Neuronales y Aprendizaje Profundo',
        'Ingeniería de Software para Sistemas Inteligentes',
        'Metodología de la Investigación y Divulgación Científica',
        'Cómputo en la Nube',
        'Sistemas Multiagentes',
      ],
      7: <String>[
        'Trabajo Terminal I',
        'Reconocimiento de Voz',
        'Formulación y Evaluación de Proyectos Informáticos',
        'Interacción Humano-Máquina',
        'Programación de Dispositivos Móviles',
      ],
      8: <String>[
        'Trabajo Terminal II',
        'Gestión Empresarial',
        'Estancia Profesional',
        'Desarrollo de Habilidades Sociales para la Alta Dirección',
      ],
    },
    'lcd': <int, List<String>>{
      1: <String>[
        'Fundamentos de Programación',
        'Matemáticas Discretas',
        'Cálculo',
        'Comunicación Oral y Escrita',
        'Introducción a la Ciencia de Datos',
      ],
      2: <String>[
        'Algoritmos y Estructuras de Datos',
        'Álgebra Lineal',
        'Cálculo Multivariable',
        'Ética y Legalidad',
        'Fundamentos Económicos',
      ],
      3: <String>[
        'Análisis y Diseño de Algoritmos',
        'Programación para Ciencia de Datos',
        'Probabilidad',
        'Bases de Datos',
        'Métodos Numéricos',
        'Finanzas Empresariales',
      ],
      4: <String>[
        'Desarrollo de Aplicaciones Web',
        'Cómputo de Alto Desempeño',
        'Estadística',
        'Bases de Datos Avanzadas',
        'Desarrollo de Aplicaciones para Análisis de Datos',
        'Liderazgo Personal',
      ],
      5: <String>[
        'Minería de Datos',
        'Matemáticas Avanzadas para Ciencia de Datos',
        'Procesos Estocásticos',
        'Aprendizaje de Máquina e Inteligencia Artificial',
        'Analítica y Visualización de Datos',
        'Metodología de la Investigación y Divulgación Científica',
      ],
      6: <String>[
        'Modelado Predictivo',
        'Procesamiento de Lenguaje Natural',
        'Análisis de Series de Tiempo',
        'Analítica Avanzada de Datos',
        'Bioinformática Básica',
        'Sistemas de Información Geográfica',
      ],
      7: <String>[
        'Big Data',
        'Modelos Econométricos',
        'Trabajo Terminal I',
        'Administración de Proyectos de TI',
        'Temas Selectos de Aprendizaje Profundo',
        'Temas Selectos de Inteligencia Artificial',
      ],
      8: <String>[
        'Desarrollo de Habilidades Sociales para la Alta Dirección',
        'Gestión Empresarial',
        'Trabajo Terminal II',
        'Estancia Profesional',
      ],
    },
  };
}
