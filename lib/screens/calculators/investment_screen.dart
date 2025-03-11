import 'package:flutter/material.dart';
import 'package:digicash/widgets/custom_button.dart';
import 'package:digicash/widgets/custom_text_field.dart';
import 'package:digicash/utils/financial_calculations.dart';
import 'dart:math';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({Key? key}) : super(key: key);

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _investmentControllers = [];
  final List<TextEditingController> _cashFlowControllers = [];
  final _discountRateController = TextEditingController();

  int _numberOfInvestments = 2;
  int _numberOfPeriods = 5;
  String _result = '';
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _investmentControllers.clear();
    _cashFlowControllers.clear();

    for (int i = 0; i < _numberOfInvestments; i++) {
      _investmentControllers.add(TextEditingController());

      for (int j = 0; j <= _numberOfPeriods; j++) {
        _cashFlowControllers.add(TextEditingController());
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _investmentControllers) {
      controller.dispose();
    }
    for (var controller in _cashFlowControllers) {
      controller.dispose();
    }
    _discountRateController.dispose();
    super.dispose();
  }

  void _updateNumberOfInvestments(String value) {
    if (value.isEmpty) return;

    int newInvestments = int.tryParse(value) ?? 2;
    if (newInvestments < 1) newInvestments = 1;
    if (newInvestments > 5) newInvestments = 5;

    setState(() {
      _numberOfInvestments = newInvestments;
      _initializeControllers();
    });
  }

  void _updateNumberOfPeriods(String value) {
    if (value.isEmpty) return;

    int newPeriods = int.tryParse(value) ?? 5;
    if (newPeriods < 1) newPeriods = 1;
    if (newPeriods > 10) newPeriods = 10;

    setState(() {
      _numberOfPeriods = newPeriods;
      _initializeControllers();
    });
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _result = '';
    });

    try {
      double discountRate =
          double.parse(_discountRateController.text.replaceAll(',', '.')) / 100;
      List<String> investmentNames = [];
      List<List<double>> cashFlows = [];
      List<double> npvs = [];
      List<double> irrs = [];

      for (int i = 0; i < _numberOfInvestments; i++) {
        investmentNames.add(
          _investmentControllers[i].text.isEmpty
              ? 'Inversión ${i + 1}'
              : _investmentControllers[i].text,
        );

        List<double> investmentCashFlows = [];
        for (int j = 0; j <= _numberOfPeriods; j++) {
          int index = i * (_numberOfPeriods + 1) + j;
          double value = double.parse(
            _cashFlowControllers[index].text.replaceAll(',', '.'),
          );
          investmentCashFlows.add(value);
        }

        cashFlows.add(investmentCashFlows);

        // Calcular VPN
        double npv = _calculateNPV(investmentCashFlows, discountRate);
        npvs.add(npv);

        // Calcular TIR
        double irr = FinancialCalculations.calculateIRR(investmentCashFlows);
        irrs.add(irr);
      }

      // Determinar la mejor inversión
      int bestNpvIndex = _findMaxIndex(npvs);
      int bestIrrIndex = _findMaxIndex(irrs);

      _result = 'Resultados de la Evaluación:\n\n';

      for (int i = 0; i < _numberOfInvestments; i++) {
        _result += '${investmentNames[i]}:\n';
        _result += '  VPN: \$${npvs[i].toStringAsFixed(2)}\n';
        _result += '  TIR: ${(irrs[i] * 100).toStringAsFixed(2)}%\n\n';
      }

      _result +=
          'Mejor inversión según VPN: ${investmentNames[bestNpvIndex]}\n';
      _result +=
          'Mejor inversión según TIR: ${investmentNames[bestIrrIndex]}\n';

      if (bestNpvIndex == bestIrrIndex) {
        _result +=
            '\nLa inversión ${investmentNames[bestNpvIndex]} es la mejor opción según ambos criterios.';
      } else {
        _result +=
            '\nHay conflicto entre los criterios de VPN y TIR. Se recomienda evaluar otros factores.';
      }
    } catch (e) {
      _result = 'Error en el cálculo: ${e.toString()}';
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  double _calculateNPV(List<double> cashFlows, double rate) {
    double npv = 0;
    for (int i = 0; i < cashFlows.length; i++) {
      npv += cashFlows[i] / pow(1 + rate, i);
    }
    return npv;
  }

  int _findMaxIndex(List<double> values) {
    int maxIndex = 0;
    double maxValue = values[0];

    for (int i = 1; i < values.length; i++) {
      if (values[i] > maxValue) {
        maxValue = values[i];
        maxIndex = i;
      }
    }

    return maxIndex;
  }

  void _resetForm() {
    for (var controller in _investmentControllers) {
      controller.clear();
    }
    for (var controller in _cashFlowControllers) {
      controller.clear();
    }
    _discountRateController.clear();
    setState(() {
      _result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluación de Inversiones'),
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
                    'Evaluación de Alternativas de Inversión',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Compara diferentes alternativas de inversión',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: TextEditingController(
                            text: _numberOfInvestments.toString(),
                          ),
                          label: 'Número de Inversiones',
                          hint: 'Ingresa el número de inversiones',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.business,
                          onChanged: _updateNumberOfInvestments,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el número de inversiones';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: TextEditingController(
                            text: _numberOfPeriods.toString(),
                          ),
                          label: 'Número de Períodos',
                          hint: 'Ingresa el número de períodos',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.access_time,
                          onChanged: _updateNumberOfPeriods,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el número de períodos';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _discountRateController,
                    label: 'Tasa de Descuento (%)',
                    hint: 'Ingresa la tasa de descuento',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.percent,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la tasa de descuento';
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
                  const SizedBox(height: 24),
                  for (int i = 0; i < _numberOfInvestments; i++) ...[
                    Text(
                      'Inversión ${i + 1}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _investmentControllers[i],
                      label: 'Nombre de la Inversión',
                      hint: 'Ingresa un nombre para la inversión',
                      prefixIcon: Icons.label_outline,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Flujos de Caja:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (int j = 0; j <= _numberOfPeriods; j++) ...[
                      CustomTextField(
                        controller:
                            _cashFlowControllers[i * (_numberOfPeriods + 1) +
                                j],
                        label:
                            j == 0
                                ? 'Inversión Inicial (t=0)'
                                : 'Flujo de Caja Período $j',
                        hint:
                            j == 0
                                ? 'Ingresa la inversión inicial (negativo)'
                                : 'Ingresa el flujo de caja',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.attach_money,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el flujo de caja';
                          }
                          try {
                            double.parse(value.replaceAll(',', '.'));
                            // Los flujos de caja pueden ser positivos o negativos
                          } catch (e) {
                            return 'Ingresa un valor numérico válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Evaluar Inversiones',
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
