import 'package:flutter/material.dart';
import 'package:digicash/widgets/custom_button.dart';
import 'package:digicash/widgets/custom_text_field.dart';
import 'package:digicash/utils/financial_calculations.dart';

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({Key? key}) : super(key: key);

  @override
  State<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _capitalController = TextEditingController();
  final _rateController = TextEditingController();
  final _timeController = TextEditingController();
  final _futureValueController = TextEditingController();
  final _compoundingController = TextEditingController(text: '1');

  String _calculationType = 'futureValue';
  String _result = '';
  bool _isCalculating = false;

  @override
  void dispose() {
    _capitalController.dispose();
    _rateController.dispose();
    _timeController.dispose();
    _futureValueController.dispose();
    _compoundingController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _result = '';
    });

    try {
      double? capital =
          _capitalController.text.isNotEmpty
              ? double.parse(_capitalController.text.replaceAll(',', '.'))
              : null;
      double? rate =
          _rateController.text.isNotEmpty
              ? double.parse(_rateController.text.replaceAll(',', '.')) / 100
              : null;
      double? time =
          _timeController.text.isNotEmpty
              ? double.parse(_timeController.text.replaceAll(',', '.'))
              : null;
      double? futureValue =
          _futureValueController.text.isNotEmpty
              ? double.parse(_futureValueController.text.replaceAll(',', '.'))
              : null;
      int compounding = int.parse(_compoundingController.text);

      switch (_calculationType) {
        case 'futureValue':
          if (capital != null && rate != null && time != null) {
            double result = FinancialCalculations.compoundInterestFutureValue(
              capital,
              rate,
              time,
              compounding,
            );
            _result = 'Valor Futuro: \$${result.toStringAsFixed(2)}';
          }
          break;
        case 'interestRate':
          if (capital != null && futureValue != null && time != null) {
            double result = FinancialCalculations.compoundInterestRate(
              capital,
              futureValue,
              time,
              compounding,
            );
            _result = 'Tasa de Interés: ${(result * 100).toStringAsFixed(2)}%';
          }
          break;
        case 'time':
          if (capital != null && futureValue != null && rate != null) {
            double result = FinancialCalculations.compoundInterestTime(
              capital,
              futureValue,
              rate,
              compounding,
            );
            _result = 'Tiempo: ${result.toStringAsFixed(2)} períodos';
          }
          break;
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
    _capitalController.clear();
    _rateController.clear();
    _timeController.clear();
    _futureValueController.clear();
    _compoundingController.text = '1';
    setState(() {
      _result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interés Compuesto'), centerTitle: true),
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
                    'Calculadora de Interés Compuesto',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona qué deseas calcular',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  _buildCalculationTypeSelector(),
                  const SizedBox(height: 24),
                  if (_calculationType != 'futureValue')
                    CustomTextField(
                      controller: _futureValueController,
                      label: 'Valor Futuro (F)',
                      hint: 'Ingresa el valor futuro',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator:
                          _calculationType != 'futureValue'
                              ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa el valor futuro';
                                }
                                return null;
                              }
                              : null,
                    ),
                  if (_calculationType != 'futureValue')
                    const SizedBox(height: 16),
                  if (_calculationType != 'capital')
                    CustomTextField(
                      controller: _capitalController,
                      label: 'Capital Inicial (P)',
                      hint: 'Ingresa el capital inicial',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator:
                          _calculationType != 'capital'
                              ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa el capital inicial';
                                }
                                try {
                                  double capital = double.parse(
                                    value.replaceAll(',', '.'),
                                  );
                                  if (capital <= 0) {
                                    return 'El capital debe ser mayor a cero';
                                  }
                                  if (capital > 1000000000) {
                                    return 'El capital ingresado es demasiado grande';
                                  }
                                } catch (e) {
                                  return 'Ingresa un valor numérico válido';
                                }
                                return null;
                              }
                              : null,
                    ),
                  if (_calculationType != 'capital') const SizedBox(height: 16),
                  if (_calculationType != 'interestRate')
                    CustomTextField(
                      controller: _rateController,
                      label: 'Tasa de Interés (i)',
                      hint: 'Ingresa la tasa de interés (%)',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.percent,
                      validator:
                          _calculationType != 'interestRate'
                              ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa la tasa de interés';
                                }
                                try {
                                  double rate = double.parse(
                                    value.replaceAll(',', '.'),
                                  );
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
                              }
                              : null,
                    ),
                  if (_calculationType != 'interestRate')
                    const SizedBox(height: 16),
                  if (_calculationType != 'time')
                    CustomTextField(
                      controller: _timeController,
                      label: 'Tiempo (t)',
                      hint: 'Ingresa el tiempo en períodos',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.access_time,
                      validator:
                          _calculationType != 'time'
                              ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa el tiempo';
                                }
                                try {
                                  double time = double.parse(
                                    value.replaceAll(',', '.'),
                                  );
                                  if (time <= 0) {
                                    return 'El tiempo debe ser mayor a cero';
                                  }
                                  if (time > 100) {
                                    return 'El tiempo ingresado parece ser demasiado largo';
                                  }
                                } catch (e) {
                                  return 'Ingresa un valor numérico válido';
                                }
                                return null;
                              }
                              : null,
                    ),
                  if (_calculationType != 'time') const SizedBox(height: 16),
                  CustomTextField(
                    controller: _compoundingController,
                    label: 'Capitalizaciones por Período',
                    hint: 'Ingresa el número de capitalizaciones',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.repeat,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el número de capitalizaciones';
                      }
                      try {
                        int compounding = int.parse(value);
                        if (compounding < 1) {
                          return 'Debe ser un número entero mayor a 0';
                        }
                        if (compounding > 365) {
                          return 'El número máximo permitido es 365 (diario)';
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
            title: const Text('Calcular Valor Futuro'),
            value: 'futureValue',
            groupValue: _calculationType,
            onChanged: (value) {
              setState(() {
                _calculationType = value!;
                _result = '';
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Calcular Tasa de Interés'),
            value: 'interestRate',
            groupValue: _calculationType,
            onChanged: (value) {
              setState(() {
                _calculationType = value!;
                _result = '';
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Calcular Tiempo'),
            value: 'time',
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
