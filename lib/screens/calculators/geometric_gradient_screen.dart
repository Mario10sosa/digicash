import 'package:flutter/material.dart';
import 'package:digicash/widgets/custom_button.dart';
import 'package:digicash/widgets/custom_text_field.dart';
import 'package:digicash/utils/financial_calculations.dart';

class GeometricGradientScreen extends StatefulWidget {
  const GeometricGradientScreen({Key? key}) : super(key: key);

  @override
  State<GeometricGradientScreen> createState() =>
      _GeometricGradientScreenState();
}

class _GeometricGradientScreenState extends State<GeometricGradientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstPaymentController = TextEditingController();
  final _growthRateController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _periodsController = TextEditingController();

  String _result = '';
  bool _isCalculating = false;

  @override
  void dispose() {
    _firstPaymentController.dispose();
    _growthRateController.dispose();
    _interestRateController.dispose();
    _periodsController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _result = '';
    });

    try {
      double firstPayment = double.parse(
        _firstPaymentController.text.replaceAll(',', '.'),
      );
      double growthRate =
          double.parse(_growthRateController.text.replaceAll(',', '.')) / 100;
      double interestRate =
          double.parse(_interestRateController.text.replaceAll(',', '.')) / 100;
      int periods = int.parse(_periodsController.text);

      double result = FinancialCalculations.geometricGradientPresentValue(
        firstPayment,
        growthRate,
        interestRate,
        periods,
      );

      _result = 'Valor Presente: \$${result.toStringAsFixed(2)}';

      // Mostrar advertencia si la tasa de crecimiento es igual a la tasa de interés
      if (growthRate == interestRate) {
        _result +=
            '\n\nNota: La tasa de crecimiento es igual a la tasa de interés, se ha aplicado una fórmula especial.';
      }
    } catch (e) {
      _result = 'Error en el cálculo: ${e.toString()}';
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  void _resetForm() {
    _firstPaymentController.clear();
    _growthRateController.clear();
    _interestRateController.clear();
    _periodsController.clear();
    setState(() {
      _result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gradiente Geométrico'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calculadora de Gradiente Geométrico',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calcula el valor presente de una serie con gradiente geométrico',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _firstPaymentController,
                    label: 'Primer Pago (A)',
                    hint: 'Ingresa el valor del primer pago',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el valor del primer pago';
                      }
                      try {
                        double payment = double.parse(
                          value.replaceAll(',', '.'),
                        );
                        if (payment <= 0) {
                          return 'El valor debe ser mayor a cero';
                        }
                        if (payment > 1000000000) {
                          return 'El valor ingresado es demasiado grande';
                        }
                      } catch (e) {
                        return 'Ingresa un valor numérico válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _growthRateController,
                    label: 'Tasa de Crecimiento (g)',
                    hint: 'Ingresa la tasa de crecimiento (%)',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.trending_up,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la tasa de crecimiento';
                      }
                      try {
                        double rate = double.parse(value.replaceAll(',', '.'));
                        if (rate <= -100) {
                          return 'La tasa no puede ser menor o igual a -100%';
                        }
                        if (rate > 100) {
                          return 'La tasa no puede ser mayor al 100%';
                        }
                      } catch (e) {
                        return 'Ingresa un valor numérico válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _interestRateController,
                    label: 'Tasa de Interés (i)',
                    hint: 'Ingresa la tasa de interés (%)',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.percent,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la tasa de interés';
                      }
                      try {
                        double rate = double.parse(value.replaceAll(',', '.'));
                        if (rate <= 0) {
                          return 'La tasa debe ser mayor a cero';
                        }
                        if (rate > 100) {
                          return 'La tasa no puede ser mayor al 100%';
                        }
                      } catch (e) {
                        return 'Ingresa un valor numérico válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _periodsController,
                    label: 'Número de Períodos (n)',
                    hint: 'Ingresa el número de períodos',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.access_time,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el número de períodos';
                      }
                      try {
                        int periods = int.parse(value);
                        if (periods <= 0) {
                          return 'El número de períodos debe ser mayor a cero';
                        }
                        if (periods > 100) {
                          return 'El número de períodos parece ser demasiado grande';
                        }
                      } catch (e) {
                        return 'Ingresa un número entero válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Calcular',
                          isLoading: _isCalculating,
                          onPressed: _calculate,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _resetForm,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Reiniciar',
                      ),
                    ],
                  ),
                  if (_result.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resultado:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _result,
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nota: El gradiente geométrico representa un incremento o decremento porcentual en cada período.',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
