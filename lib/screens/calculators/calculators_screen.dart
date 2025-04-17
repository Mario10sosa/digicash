import 'package:digicash/screens/calculators/annuity_screen.dart';
import 'package:digicash/screens/calculators/capitalizacion_screen.dart';
import 'package:digicash/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:digicash/screens/calculators/simple_interest_screen.dart';
import 'package:digicash/screens/calculators/compound_intereset_screen.dart';
import 'package:digicash/screens/calculators/arithmetic_gradient_screen.dart';
import 'package:digicash/screens/calculators/geometric_gradient_screen.dart';
import 'package:digicash/screens/calculators/amortization_screen.dart';
import 'package:digicash/screens/calculators/tir_screen.dart';

class CalculatorsScreen extends StatefulWidget {
  const CalculatorsScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorsScreen> createState() => _CalculatorsScreenState();
}

class _CalculatorsScreenState extends State<CalculatorsScreen> {
  // Lista de calculadoras
  final List<Map<String, dynamic>> _calculators = [
    {
      'title': 'Interés Simple',
      'icon': Icons.calculate_outlined,
      'color': const Color(0xFF6C63FF),
      'screen': const SimpleInterestScreen(),
      'description': 'Calcula interés simple para préstamos o inversiones',
    },
    {
      'title': 'Interés Compuesto',
      'icon': Icons.auto_graph,
      'color': const Color(0xFF4CAF50),
      'screen': const CompoundInterestScreen(),
      'description': 'Calcula el crecimiento con interés que se reinvierte',
    },
    {
      'title': 'Anualidades',
      'icon': Icons.payments,
      'color': const Color(0xFF9C27B0),
      'screen': const AnnuityScreen(),
      'description': 'Calcula pagos periódicos iguales a lo largo del tiempo',
    },
    {
      'title': 'Gradiente Aritmético',
      'icon': Icons.trending_up,
      'color': const Color(0xFFFF9800),
      'screen': const GradienteAritmeticoScreen(),
      'description': 'Calcula series de pagos con incremento constante',
    },
    {
      'title': 'Gradiente Geométrico',
      'icon': Icons.show_chart,
      'color': const Color(0xFF3F51B5),
      'screen': const GradienteGeometricoScreen(),
      'description': 'Calcula series con tasa de crecimiento constante',
    },
    {
      'title': 'Amortización',
      'icon': Icons.account_balance_outlined,
      'color': const Color(0xFF009688),
      'screen': const AmortizacionScreen(),
      'description': 'Genera tabla de amortización para préstamos',
    },
    {
      'title': 'TIR',
      'icon': Icons.assessment_outlined,
      'color': const Color(0xFFE91E63),
      'screen': const TirScreen(),
      'description': 'Calcula la Tasa Interna de Retorno de inversiones',
    },
    {
      'title': 'Capitalización',
      'icon': Icons.text_fields,
      'color': const Color(0xFF00BCD4),
      'screen': const CapitalizacionScreen(),
      'description': 'Calcula el valor futuro con diferentes períodos',
    },
    {
      'title': 'UVR',
      'icon': Icons.home_outlined,
      'color': const Color(0xFFFFEB3B),
      'screen': null,
      'description': 'Calcula préstamos ajustados por inflación',
    },
    {
      'title': 'Inversiones',
      'icon': Icons.attach_money,
      'color': const Color(0xFF673AB7),
      'screen': null,
      'description': 'Compara diferentes opciones de inversión',
    },
    {
      'title': 'Bonos',
      'icon': Icons.description_outlined,
      'color': const Color(0xFFFF5722),
      'screen': null,
      'description': 'Calcula rendimiento y valoración de bonos',
    },
    {
      'title': 'Inflación',
      'icon': Icons.trending_down,
      'color': const Color(0xFF795548),
      'screen': null,
      'description': 'Calcula el impacto de la inflación en el tiempo',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Define app colors - usando el mismo color de fondo que en home_screen.dart
    final primaryColor = const Color(0xFF3F51B5); // Indigo
    final secondaryColor = const Color(0xFF303F9F); // Dark Indigo
    final backgroundColor = const Color(0xFFF5F7FA); // Mismo color que en home

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Encabezado con borde integrado
          _buildHeader(primaryColor, secondaryColor),

          // Contenido principal
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Espacio superior
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Grid de calculadoras
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildCalculatorItem(_calculators[index]);
                    }, childCount: _calculators.length),
                  ),
                ),

                // Espacio inferior
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primaryColor, Color secondaryColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Barra de título
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botón de retroceso
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                  ),
                  // Título centrado
                  Text(
                    'Calculadoras Financieras',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorItem(Map<String, dynamic> calculator) {
    return GestureDetector(
      onTap: () {
        if (calculator['screen'] != null) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      calculator['screen'],
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutCubic;
                var tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        } else {
          _showComingSoonDialog(context, calculator['title']);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con fondo de color
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: calculator['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                calculator['icon'],
                color: calculator['color'],
                size: 35,
              ),
            ),
            const SizedBox(height: 15),

            // Título
            Text(
              calculator['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                calculator['description'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 15),

            // Botón
            Container(
              width: 100,
              height: 30,
              decoration: BoxDecoration(
                color: calculator['color'],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  'Abrir',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.engineering,
                    color: Color(0xFFFF9800),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Próximamente',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  '$feature estará disponible en breve.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
