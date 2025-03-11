import 'package:flutter/material.dart';
import 'package:digicash/widgets/custom_button.dart';
import 'package:digicash/widgets/custom_text_field.dart';
//import 'package:digicash/utils/financial_calculations.dart';
import 'dart:math';

class BondsScreen extends StatefulWidget {
  const BondsScreen({Key? key}) : super(key: key);

  @override
  State<BondsScreen> createState() => _BondsScreenState();
}

class _BondsScreenState extends State<BondsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nominalValueController = TextEditingController();
  final _couponRateController = TextEditingController();
  final _marketRateController = TextEditingController();
  final _yearsToMaturityController = TextEditingController();
  final _paymentsPerYearController = TextEditingController(text: '2');

  String _calculationType = 'bondPrice';
  String _result = '';
  bool _isCalculating = false;

  @override
  void dispose() {
    _nominalValueController.dispose();
    _couponRateController.dispose();
    _marketRateController.dispose();
    _yearsToMaturityController.dispose();
    _paymentsPerYearController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _result = '';
    });

    try {
      double nominalValue = double.parse(
        _nominalValueController.text.replaceAll(',', '.'),
      );
      double couponRate =
          double.parse(_couponRateController.text.replaceAll(',', '.')) / 100;
      double marketRate =
          double.parse(_marketRateController.text.replaceAll(',', '.')) / 100;
      double yearsToMaturity = double.parse(
        _yearsToMaturityController.text.replaceAll(',', '.'),
      );
      int paymentsPerYear = int.parse(_paymentsPerYearController.text);

      double couponPayment = nominalValue * couponRate / paymentsPerYear;
      int totalPayments = (yearsToMaturity * paymentsPerYear).round();
      double periodicRate = marketRate / paymentsPerYear;

      if (_calculationType == 'bondPrice') {
        double bondPrice = _calculateBondPrice(
          nominalValue,
          couponPayment,
          periodicRate,
          totalPayments,
        );

        _result = 'Precio del Bono: \$${bondPrice.toStringAsFixed(2)}\n';

        if (bondPrice > nominalValue) {
          _result +=
              '\nEl bono se vende con prima (por encima de su valor nominal).';
        } else if (bondPrice < nominalValue) {
          _result +=
              '\nEl bono se vende con descuento (por debajo de su valor nominal).';
        } else {
          _result += '\nEl bono se vende a la par (igual a su valor nominal).';
        }
      } else if (_calculationType == 'yield') {
        double currentYield = (couponRate * nominalValue) / nominalValue;
        double yieldToMaturity = _calculateYieldToMaturity(
          nominalValue,
          couponPayment,
          nominalValue,
          totalPayments,
          paymentsPerYear,
        );

        _result =
            'Rendimiento Actual: ${(currentYield * 100).toStringAsFixed(2)}%\n';
        _result +=
            'Rendimiento al Vencimiento: ${(yieldToMaturity * 100).toStringAsFixed(2)}%';
      } else if (_calculationType == 'duration') {
        double bondPrice = _calculateBondPrice(
          nominalValue,
          couponPayment,
          periodicRate,
          totalPayments,
        );
        double duration = _calculateDuration(
          nominalValue,
          couponPayment,
          periodicRate,
          totalPayments,
        );
        double modifiedDuration = duration / (1 + periodicRate);

        _result = 'Duración: ${duration.toStringAsFixed(2)} períodos\n';
        _result +=
            'Duración Modificada: ${modifiedDuration.toStringAsFixed(2)}\n';
        _result +=
            'Cambio en Precio por 1% de Cambio en Tasa: ${(modifiedDuration * bondPrice * 0.01).toStringAsFixed(2)}';
      }
    } catch (e) {
      _result = 'Error en el cálculo: ${e.toString()}';
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  double _calculateBondPrice(
    double nominalValue,
    double couponPayment,
    double periodicRate,
    int totalPayments,
  ) {
    double presentValueOfCoupons = 0;
    for (int i = 1; i <= totalPayments; i++) {
      presentValueOfCoupons += couponPayment / pow(1 + periodicRate, i);
    }

    double presentValueOfPrincipal =
        nominalValue / pow(1 + periodicRate, totalPayments);

    return presentValueOfCoupons + presentValueOfPrincipal;
  }

  double _calculateYieldToMaturity(
    double nominalValue,
    double couponPayment,
    double bondPrice,
    int totalPayments,
    int paymentsPerYear,
  ) {
    // Método de aproximación para YTM
    double guess = 0.05 / paymentsPerYear;
    double precision = 0.0000001;
    int maxIterations = 100;

    double r = guess;
    int iteration = 0;
    double price = 0;

    do {
      price = 0;
      for (int i = 1; i <= totalPayments; i++) {
        price += couponPayment / pow(1 + r, i);
      }
      price += nominalValue / pow(1 + r, totalPayments);

      if ((price - bondPrice).abs() < precision) {
        return r * paymentsPerYear;
      }

      r += (price > bondPrice) ? 0.0001 : -0.0001;
      iteration++;
    } while (iteration < maxIterations);

    return r * paymentsPerYear;
  }

  double _calculateDuration(
    double nominalValue,
    double couponPayment,
    double periodicRate,
    int totalPayments,
  ) {
    double bondPrice = _calculateBondPrice(
      nominalValue,
      couponPayment,
      periodicRate,
      totalPayments,
    );
    double weightedSum = 0;

    for (int i = 1; i <= totalPayments; i++) {
      double presentValueOfPayment = couponPayment / pow(1 + periodicRate, i);
      weightedSum += i * presentValueOfPayment;
    }

    weightedSum +=
        totalPayments * nominalValue / pow(1 + periodicRate, totalPayments);

    return weightedSum / bondPrice;
  }

  void _resetForm() {
    _nominalValueController.clear();
    _couponRateController.clear();
    _marketRateController.clear();
    _yearsToMaturityController.clear();
    _paymentsPerYearController.text = '2';
    setState(() {
      _result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bonos'), centerTitle: true),
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
                    'Calculadora de Bonos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Realiza cálculos relacionados con bonos',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  _buildCalculationTypeSelector(),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _nominalValueController,
                    label: 'Valor Nominal',
                    hint: 'Ingresa el valor nominal del bono',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el valor nominal';
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
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _couponRateController,
                    label: 'Tasa de Cupón (%)',
                    hint: 'Ingresa la tasa de cupón anual',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.percent,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la tasa de cupón';
                      }
                      try {
                        double rate = double.parse(value.replaceAll(',', '.'));
                        if (rate < 0) {
                          return 'La tasa no puede ser negativa';
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
                    controller: _marketRateController,
                    label: 'Tasa de Mercado (%)',
                    hint: 'Ingresa la tasa de mercado anual',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.percent,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la tasa de mercado';
                      }
                      try {
                        double rate = double.parse(value.replaceAll(',', '.'));
                        if (rate < 0) {
                          return 'La tasa no puede ser negativa';
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
                    controller: _yearsToMaturityController,
                    label: 'Años al Vencimiento',
                    hint: 'Ingresa los años al vencimiento',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.access_time,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa los años al vencimiento';
                      }
                      try {
                        double years = double.parse(value.replaceAll(',', '.'));
                        if (years <= 0) {
                          return 'Los años deben ser mayor a cero';
                        }
                        if (years > 50) {
                          return 'Los años al vencimiento parecen ser demasiados';
                        }
                      } catch (e) {
                        return 'Ingresa un valor numérico válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _paymentsPerYearController,
                    label: 'Pagos por Año',
                    hint: 'Ingresa el número de pagos por año',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.calendar_today,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el número de pagos por año';
                      }
                      try {
                        int payments = int.parse(value);
                        if (payments < 1) {
                          return 'Debe ser un número entero mayor a 0';
                        }
                        if (payments > 12) {
                          return 'El máximo permitido es 12 pagos al año';
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
            title: const Text('Calcular Precio del Bono'),
            value: 'bondPrice',
            groupValue: _calculationType,
            onChanged: (value) {
              setState(() {
                _calculationType = value!;
                _result = '';
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Calcular Rendimiento'),
            value: 'yield',
            groupValue: _calculationType,
            onChanged: (value) {
              setState(() {
                _calculationType = value!;
                _result = '';
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Calcular Duración'),
            value: 'duration',
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
