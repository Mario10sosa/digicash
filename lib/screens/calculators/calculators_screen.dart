import 'package:flutter/material.dart';
import 'package:digicash/screens/calculators/simple_interest_screen.dart';
import 'package:digicash/screens/calculators/compound_intereset_screen.dart';
import 'package:digicash/screens/calculators/arithmetic_gradient_screen.dart';
import 'package:digicash/screens/calculators/geometric_gradient_screen.dart';
import 'package:digicash/screens/calculators/amortization_screen.dart';
import 'package:digicash/screens/calculators/tir_screen.dart';
import 'package:digicash/screens/calculators/uvr_screen.dart';
import 'package:digicash/screens/calculators/investment_screen.dart';
import 'package:digicash/screens/calculators/bonds_screen.dart';
import 'package:digicash/screens/calculators/inflation_screen.dart';

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadoras Financieras'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecciona una Calculadora',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Herramientas para cálculos financieros',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildCalculatorCard(
                      context,
                      'Interés Simple',
                      Icons.calculate_outlined,
                      Colors.blue,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SimpleInterestScreen(),
                          ),
                        );
                      },
                    ),
                    _buildCalculatorCard(
                      context,
                      'Interés Compuesto',
                      Icons.auto_graph,
                      Colors.green,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CompoundInterestScreen(),
                          ),
                        );
                      },
                    ),
                    _buildCalculatorCard(
                      context,
                      'Gradiente Aritmético',
                      Icons.trending_up,
                      Colors.orange,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ArithmeticGradientScreen(),
                          ),
                        );
                      },
                    ),
                    _buildCalculatorCard(
                      context,
                      'Gradiente Geométrico',
                      Icons.show_chart,
                      Colors.purple,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GeometricGradientScreen(),
                          ),
                        );
                      },
                    ),
                    _buildCalculatorCard(
                      context,
                      'Amortización',
                      Icons.account_balance_outlined,
                      Colors.teal,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AmortizationScreen(),
                          ),
                        );
                      },
                    ),
                    _buildCalculatorCard(
                      context,
                      'TIR',
                      Icons.assessment_outlined,
                      Colors.red,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TirScreen()),
                        );
                      },
                    ),
                    _buildCalculatorCard(
                      context,
                      'UVR',
                      Icons.home_outlined,
                      Colors.amber,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UvrScreen()),
                        );
                      },
                    ),
                    _buildCalculatorCard(
                      context,
                      'Inversiones',
                      Icons.attach_money,
                      Colors.indigo,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InvestmentScreen(),
                          ),
                        );
                      },
                    ),
                    _buildCalculatorCard(
                      context,
                      'Bonos',
                      Icons.description_outlined,
                      Colors.deepOrange,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BondsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildCalculatorCard(
                      context,
                      'Inflación',
                      Icons.trending_down,
                      Colors.brown,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InflationScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
