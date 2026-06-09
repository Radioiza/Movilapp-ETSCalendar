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
    'Fundamentos de Programación': 'Rocío Reséndiz Muñoz',
    'Matemáticas Discretas': 'Crispín Herrera Yáñez',
    'Cálculo': 'Claudia Jisela Dorantes Villa',
    'Análisis Vectorial': 'Florencio Guzmán Aguilar',
    'Comunicación Oral y Escrita': 'Adriana de la P. Sánchez Moreno',
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
