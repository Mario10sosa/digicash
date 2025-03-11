/*import 'package:flutter/material.dart';
import 'package:digicash/widgets/custom_button.dart';
import 'package:digicash/widgets/custom_text_field.dart';
import 'package:digicash/utils/financial_calculations.dart';

class InflationScreen extends StatefulWidget {
  const InflationScreen({Key? key}) : super(key: key);

  @override
  State<InflationScreen> createState() => _InflationScreenState();
}

class _InflationScreenState extends State<InflationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _presentValueController = TextEditingController();
  final _futureValueController = TextEditingController();
  final _inflationRateController = TextEditingController();
  final _yearsController = TextEditingController();
  
  String _calculationType = 'futureValue';
  String _result = '';
  bool _isCalculating = false;

  @override
  void dispose() {
    _presentValueController.dispose();
    _futureValueController.dispose();
    _inflationRateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _result = '';
    });

    try {
      switch (_calculationType) {
        case 'futureValue':
          double presentValue = double.parse(_presentValueController.text.replaceAll(',', '.'));
          double inflationRate = double.parse(_inflationRateController.text.replaceAll(',', '.')) / 100;
          double years = double.parse(_yearsController.text.replaceAll(',', '.'));
          
          double futureValue = presentValue * pow(1 + inflationRate, years);
          
          _result = 'Valor Futuro Ajustado por Inflación: \$${futureValue.toStringAsFixed(2)}\n';
          _result += 'Pérdida de Poder Adquisitivo: \$${(presentValue - futureValue).abs().toStringAsFixed(2)}\n';
          _result += 'Porcentaje de Pérdida: ${((1 - presentValue / futureValue) * 100).abs().toStringAsFixed(2)}%';
          break;
          
        case 'presentValue':
          double futureValue = double.parse(_futureValueController.text.replaceAll(',', '.'));
          double inflationRate = double.parse(_inflationRateController.text.replaceAll(',', '.')) / 100;
          double years = double.parse(_yearsController.text.replaceAll(',', '.'));
          
          double presentValue = futureValue / pow(1 + inflationRate, years);
          
          _result = 'Valor Presente Ajustado por Inflación: \$${presentValue.toStringAsFixed(2)}\n';
          _result += 'Equivalente en Poder Adquisitivo Actual: \$${presentValue.toStringAsFixed(2)}';
          break;
          
        case 'inflationRate':
          double presentValue = double.parse(_presentValueController.text.replaceAll(',', '.'));
          double futureValue = double.parse(_futureValueController.text.replaceAll(',', '.'));
          double years = double.parse(_yearsController.text.replaceAll(',', '.'));
          
          double inflationRate = pow(futureValue / presentValue, 1 / years) - 1;
          
          _result = 'Tasa de Inflación: ${(inflationRate * 100).toStringAsFixed(2)}%\n';
          _result += 'Tasa de Inflación Acumulada: ${((pow(1 + inflationRate, years) - 1) * 100).toStringAsFixed(2)}%';
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
    _presentValueController.clear();
    _futureValueController.clear();
    _inflationRateController.clear();
    _yearsController.clear();
    setState(() {
      _result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inflación'),
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
                    'Calculadora de Inflación',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calcula el impacto de la inflación en el valor del dinero',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCalculationTypeSelector(),
                  const SizedBox(height: 24),
                  if (_calculationType != 'presentValue')
                    CustomTextField(
                      controller: _presentValueController,
                      label: 'Valor Presente',
                      hint: 'Ingresa el valor presente',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator: _calculationType != 'presentValue'
                          ? (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa el valor presente';
                              }
                              return null;
                            }
                          : null,
                    ),
                  if (_calculationType != 'presentValue')
                    const SizedBox(height: 16),
                  if (_calculationType != 'futureValue')
                    CustomTextField(
                      controller: _futureValueController,
                      label: 'Valor Futuro',
                      hint: 'Ingresa el valor futuro',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator: _calculationType != 'futureValue'
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
                  if (_calculationType != 'inflationRate')
                    CustomTextField(
                      controller: _inflationRateController,
                      label: 'Tasa de Inflación (%)',
                      hint: 'Ingresa la tasa de inflación anual',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.percent,
                      validator: _calculationType != 'inflationRate'
                          ? (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa la tasa de inflación';
                              }
                              return null;
                            }
                          : null,
                    ),
                  if (_calculationType != 'inflationRate')
                    const SizedBox(height: 16),
                  CustomTextField(
                    controller: _yearsController,
                    label: 'Número de Años',
                    hint: 'Ingresa el número de años',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.access_time,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el número de años';
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
                              fontSize: 16,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nota: La inflación reduce el poder adquisitivo del dinero con el tiempo.',
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
            title: const Text('Calcular Valor Futuro con Inflación'),
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
            title: const Text('Calcular Valor Presente con Inflación'),
            value: 'presentValue',
            groupValue: _calculationType,
            onChanged: (value) {
              setState(() {
                _calculationType = value!;
                _result = '';
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Calcular Tasa de Inflación'),
            value: 'inflationRate',
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
}*/

import 'package:flutter/material.dart';
import 'package:digicash/widgets/custom_button.dart';
import 'package:digicash/widgets/custom_text_field.dart';
import 'dart:math' as math; // Importación correcta de math

class InflationScreen extends StatefulWidget {
  const InflationScreen({Key? key}) : super(key: key);

  @override
  State<InflationScreen> createState() => _InflationScreenState();
}

class _InflationScreenState extends State<InflationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _presentValueController = TextEditingController();
  final _futureValueController = TextEditingController();
  final _inflationRateController = TextEditingController();
  final _yearsController = TextEditingController();

  String _calculationType = 'futureValue';
  String _result = '';
  bool _isCalculating = false;

  @override
  void dispose() {
    _presentValueController.dispose();
    _futureValueController.dispose();
    _inflationRateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _result = '';
    });

    try {
      switch (_calculationType) {
        case 'futureValue':
          double presentValue = double.parse(
            _presentValueController.text.replaceAll(',', '.'),
          );
          double inflationRate =
              double.parse(_inflationRateController.text.replaceAll(',', '.')) /
              100;
          double years = double.parse(
            _yearsController.text.replaceAll(',', '.'),
          );

          double futureValue =
              presentValue * math.pow(1 + inflationRate, years);

          _result =
              'Valor Futuro Ajustado por Inflación: \$${futureValue.toStringAsFixed(2)}\n';
          _result +=
              'Pérdida de Poder Adquisitivo: \$${(presentValue - futureValue).abs().toStringAsFixed(2)}\n';
          _result +=
              'Porcentaje de Pérdida: ${((1 - presentValue / futureValue) * 100).abs().toStringAsFixed(2)}%';
          break;

        case 'presentValue':
          double futureValue = double.parse(
            _futureValueController.text.replaceAll(',', '.'),
          );
          double inflationRate =
              double.parse(_inflationRateController.text.replaceAll(',', '.')) /
              100;
          double years = double.parse(
            _yearsController.text.replaceAll(',', '.'),
          );

          double presentValue =
              futureValue / math.pow(1 + inflationRate, years);

          _result =
              'Valor Presente Ajustado por Inflación: \$${presentValue.toStringAsFixed(2)}\n';
          _result +=
              'Equivalente en Poder Adquisitivo Actual: \$${presentValue.toStringAsFixed(2)}';
          break;

        case 'inflationRate':
          double presentValue = double.parse(
            _presentValueController.text.replaceAll(',', '.'),
          );
          double futureValue = double.parse(
            _futureValueController.text.replaceAll(',', '.'),
          );
          double years = double.parse(
            _yearsController.text.replaceAll(',', '.'),
          );

          double inflationRate =
              math.pow(futureValue / presentValue, 1 / years) - 1;

          _result =
              'Tasa de Inflación: ${(inflationRate * 100).toStringAsFixed(2)}%\n';
          _result +=
              'Tasa de Inflación Acumulada: ${((math.pow(1 + inflationRate, years) - 1) * 100).toStringAsFixed(2)}%';
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
    _presentValueController.clear();
    _futureValueController.clear();
    _inflationRateController.clear();
    _yearsController.clear();
    setState(() {
      _result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inflación'), centerTitle: true),
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
                    'Calculadora de Inflación',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calcula el impacto de la inflación en el valor del dinero',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  _buildCalculationTypeSelector(),
                  const SizedBox(height: 24),
                  if (_calculationType != 'presentValue')
                    CustomTextField(
                      controller: _presentValueController,
                      label: 'Valor Presente',
                      hint: 'Ingresa el valor presente',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator:
                          _calculationType != 'presentValue'
                              ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa el valor presente';
                                }
                                try {
                                  double amount = double.parse(
                                    value.replaceAll(',', '.'),
                                  );
                                  if (amount <= 0) {
                                    return 'El valor debe ser mayor a cero';
                                  }
                                  if (amount > 1000000000) {
                                    return 'El valor ingresado es demasiado grande';
                                  }
                                } catch (e) {
                                  return 'Ingresa un valor numérico válido';
                                }
                                return null;
                              }
                              : null,
                    ),
                  if (_calculationType != 'presentValue')
                    const SizedBox(height: 16),
                  if (_calculationType != 'futureValue')
                    CustomTextField(
                      controller: _futureValueController,
                      label: 'Valor Futuro',
                      hint: 'Ingresa el valor futuro',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator:
                          _calculationType != 'futureValue'
                              ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa el valor futuro';
                                }
                                try {
                                  double amount = double.parse(
                                    value.replaceAll(',', '.'),
                                  );
                                  if (amount <= 0) {
                                    return 'El valor debe ser mayor a cero';
                                  }
                                  if (amount > 1000000000) {
                                    return 'El valor ingresado es demasiado grande';
                                  }
                                } catch (e) {
                                  return 'Ingresa un valor numérico válido';
                                }
                                return null;
                              }
                              : null,
                    ),
                  if (_calculationType != 'futureValue')
                    const SizedBox(height: 16),
                  if (_calculationType != 'inflationRate')
                    CustomTextField(
                      controller: _inflationRateController,
                      label: 'Tasa de Inflación (%)',
                      hint: 'Ingresa la tasa de inflación anual',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.percent,
                      validator:
                          _calculationType != 'inflationRate'
                              ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa la tasa de inflación';
                                }
                                try {
                                  double rate = double.parse(
                                    value.replaceAll(',', '.'),
                                  );
                                  if (rate < 0) {
                                    return 'La tasa no puede ser negativa';
                                  }
                                  if (rate > 50) {
                                    return 'La tasa parece ser demasiado alta';
                                  }
                                } catch (e) {
                                  return 'Ingresa un valor numérico válido';
                                }
                                return null;
                              }
                              : null,
                    ),
                  if (_calculationType != 'inflationRate')
                    const SizedBox(height: 16),
                  CustomTextField(
                    controller: _yearsController,
                    label: 'Número de Años',
                    hint: 'Ingresa el número de años',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.access_time,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el número de años';
                      }
                      try {
                        double years = double.parse(value.replaceAll(',', '.'));
                        if (years <= 0) {
                          return 'El número de años debe ser mayor a cero';
                        }
                        if (years > 100) {
                          return 'El número de años parece ser demasiado grande';
                        }
                      } catch (e) {
                        return 'Ingresa un valor numérico válido';
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
                              fontSize: 16,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nota: La inflación reduce el poder adquisitivo del dinero con el tiempo.',
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
            title: const Text('Calcular Valor Futuro con Inflación'),
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
            title: const Text('Calcular Valor Presente con Inflación'),
            value: 'presentValue',
            groupValue: _calculationType,
            onChanged: (value) {
              setState(() {
                _calculationType = value!;
                _result = '';
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Calcular Tasa de Inflación'),
            value: 'inflationRate',
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
