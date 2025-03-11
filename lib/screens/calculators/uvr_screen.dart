import 'package:flutter/material.dart';
import 'package:digicash/widgets/custom_button.dart';
import 'package:digicash/widgets/custom_text_field.dart';

class UvrScreen extends StatefulWidget {
  const UvrScreen({Key? key}) : super(key: key);

  @override
  State<UvrScreen> createState() => _UvrScreenState();
}

class _UvrScreenState extends State<UvrScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loanAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _periodsController = TextEditingController();
  final _inflationRateController = TextEditingController();
  final _currentUvrValueController = TextEditingController();

  String _calculationType = 'loanToUvr';
  String _result = '';
  bool _isCalculating = false;

  @override
  void dispose() {
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _periodsController.dispose();
    _inflationRateController.dispose();
    _currentUvrValueController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _result = '';
    });

    try {
      if (_calculationType == 'loanToUvr') {
        double loanAmount = double.parse(
          _loanAmountController.text.replaceAll(',', '.'),
        );
        double currentUvrValue = double.parse(
          _currentUvrValueController.text.replaceAll(',', '.'),
        );

        double loanInUvr = loanAmount / currentUvrValue;
        _result = 'Préstamo en UVR: ${loanInUvr.toStringAsFixed(2)} UVR';
      } else if (_calculationType == 'uvrAmortization') {
        double loanAmount = double.parse(
          _loanAmountController.text.replaceAll(',', '.'),
        );
        double interestRate =
            double.parse(_interestRateController.text.replaceAll(',', '.')) /
            100;
        int periods = int.parse(_periodsController.text);
        double inflationRate =
            double.parse(_inflationRateController.text.replaceAll(',', '.')) /
            100;
        double currentUvrValue = double.parse(
          _currentUvrValueController.text.replaceAll(',', '.'),
        );

        double loanInUvr = loanAmount / currentUvrValue;
        double monthlyPaymentUvr = _calculateUvrMonthlyPayment(
          loanInUvr,
          interestRate / 12,
          periods,
        );

        _result = 'Préstamo en UVR: ${loanInUvr.toStringAsFixed(2)} UVR\n';
        _result +=
            'Cuota Mensual en UVR: ${monthlyPaymentUvr.toStringAsFixed(2)} UVR\n';
        _result +=
            'Cuota Inicial en Pesos: \$${(monthlyPaymentUvr * currentUvrValue).toStringAsFixed(2)}\n\n';

        _result += 'Proyección de Cuotas con Inflación:\n';
        double projectedUvrValue = currentUvrValue;

        for (int i = 1; i <= 12; i++) {
          projectedUvrValue *= (1 + inflationRate / 12);
          if (i % 3 == 0) {
            // Mostrar cada 3 meses para no saturar la pantalla
            _result +=
                'Mes $i: \$${(monthlyPaymentUvr * projectedUvrValue).toStringAsFixed(2)}\n';
          }
        }

        // Mostrar también algunos años para ver el efecto a largo plazo
        for (int year = 2; year <= 5; year++) {
          int month = year * 12;
          projectedUvrValue =
              currentUvrValue * pow(1 + inflationRate / 12, month);
          _result +=
              'Año $year (mes $month): \$${(monthlyPaymentUvr * projectedUvrValue).toStringAsFixed(2)}\n';
        }

        // Agregar información sobre el total pagado al final del crédito
        double finalUvrValue =
            currentUvrValue * pow(1 + inflationRate / 12, periods);
        double finalPayment = monthlyPaymentUvr * finalUvrValue;
        double totalPaid = monthlyPaymentUvr * currentUvrValue;
        for (int i = 1; i < periods; i++) {
          double tempUvrValue =
              currentUvrValue * pow(1 + inflationRate / 12, i);
          totalPaid += monthlyPaymentUvr * tempUvrValue;
        }

        _result +=
            '\nÚltima cuota (mes $periods): \$${finalPayment.toStringAsFixed(2)}\n';
        _result += 'Total pagado en pesos: \$${totalPaid.toStringAsFixed(2)}\n';
        _result +=
            'Comparación con préstamo original: ${(totalPaid / loanAmount).toStringAsFixed(2)} veces';
      }
    } catch (e) {
      _result = 'Error en el cálculo: ${e.toString()}';
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  double _calculateUvrMonthlyPayment(
    double loanInUvr,
    double monthlyRate,
    int periods,
  ) {
    // Fórmula de cuota fija para préstamos en UVR (sistema francés)
    return loanInUvr *
        monthlyRate *
        pow(1 + monthlyRate, periods) /
        (pow(1 + monthlyRate, periods) - 1);
  }

  double pow(double x, int y) {
    double result = 1.0;
    for (int i = 0; i < y; i++) {
      result *= x;
    }
    return result;
  }

  void _resetForm() {
    _loanAmountController.clear();
    _interestRateController.clear();
    _periodsController.clear();
    _inflationRateController.clear();
    _currentUvrValueController.clear();
    setState(() {
      _result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UVR - Unidad de Valor Real'),
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
                    'Calculadora de UVR',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Realiza cálculos con la Unidad de Valor Real',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  _buildCalculationTypeSelector(),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _loanAmountController,
                    label: 'Monto del Préstamo (Pesos)',
                    hint: 'Ingresa el monto del préstamo',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el monto del préstamo';
                      }
                      try {
                        double amount = double.parse(
                          value.replaceAll(',', '.'),
                        );
                        if (amount <= 0) {
                          return 'El monto debe ser mayor a cero';
                        }
                        if (amount > 1000000000) {
                          return 'El monto ingresado es demasiado grande';
                        }
                      } catch (e) {
                        return 'Ingresa un valor numérico válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _currentUvrValueController,
                    label: 'Valor Actual de la UVR',
                    hint: 'Ingresa el valor actual de la UVR',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.currency_exchange,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el valor actual de la UVR';
                      }
                      try {
                        double uvrValue = double.parse(
                          value.replaceAll(',', '.'),
                        );
                        if (uvrValue <= 0) {
                          return 'El valor de la UVR debe ser mayor a cero';
                        }
                        if (uvrValue > 10000) {
                          return 'El valor de la UVR parece ser demasiado alto';
                        }
                      } catch (e) {
                        return 'Ingresa un valor numérico válido';
                      }
                      return null;
                    },
                  ),
                  if (_calculationType == 'uvrAmortization') ...[
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _interestRateController,
                      label: 'Tasa de Interés Anual (%)',
                      hint: 'Ingresa la tasa de interés anual',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.percent,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la tasa de interés';
                        }
                        try {
                          double rate = double.parse(
                            value.replaceAll(',', '.'),
                          );
                          if (rate <= 0) {
                            return 'La tasa de interés debe ser mayor a cero';
                          }
                          if (rate > 100) {
                            return 'La tasa de interés no puede ser mayor al 100%';
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
                      label: 'Plazo en Meses',
                      hint: 'Ingresa el plazo en meses',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.access_time,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa el plazo';
                        }
                        try {
                          int periods = int.parse(value);
                          if (periods <= 0) {
                            return 'El plazo debe ser mayor a cero';
                          }
                          if (periods > 360) {
                            return 'El plazo no puede exceder los 360 meses (30 años)';
                          }
                        } catch (e) {
                          return 'Ingresa un número entero válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _inflationRateController,
                      label: 'Tasa de Inflación Anual Proyectada (%)',
                      hint: 'Ingresa la tasa de inflación anual proyectada',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.trending_up,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la tasa de inflación';
                        }
                        try {
                          double rate = double.parse(
                            value.replaceAll(',', '.'),
                          );
                          if (rate < 0) {
                            return 'La tasa de inflación no puede ser negativa';
                          }
                          if (rate > 50) {
                            return 'La tasa de inflación parece demasiado alta';
                          }
                        } catch (e) {
                          return 'Ingresa un valor numérico válido';
                        }
                        return null;
                      },
                    ),
                  ],
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
                              fontSize: 16,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nota: Los créditos en UVR están indexados a la inflación, por lo que las cuotas aumentan con el tiempo.',
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

  Widget _buildCalculationTypeSelector() {
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
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text('Convertir Préstamo a UVR'),
            value: 'loanToUvr',
            groupValue: _calculationType,
            onChanged: (value) {
              setState(() {
                _calculationType = value!;
                _result = '';
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Amortización en UVR'),
            value: 'uvrAmortization',
            groupValue: _calculationType,
            onChanged: (value) {
              setState(() {
                _calculationType = value!;
                _result = '';
              });
            },
          ),
        ],
      ),
    );
  }
}
