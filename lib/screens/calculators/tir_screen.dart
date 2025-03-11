import 'package:flutter/material.dart';
import 'package:digicash/widgets/custom_button.dart';
import 'package:digicash/widgets/custom_text_field.dart';
import 'package:digicash/utils/financial_calculations.dart';

class TirScreen extends StatefulWidget {
  const TirScreen({Key? key}) : super(key: key);

  @override
  State<TirScreen> createState() => _TirScreenState();
}

class _TirScreenState extends State<TirScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _cashFlowControllers = [];
  int _numberOfPeriods = 5;
  String _result = '';
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _initializeCashFlowControllers();
  }

  void _initializeCashFlowControllers() {
    _cashFlowControllers.clear();
    for (int i = 0; i <= _numberOfPeriods; i++) {
      _cashFlowControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in _cashFlowControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateNumberOfPeriods(String value) {
    if (value.isEmpty) return;

    int newPeriods = int.tryParse(value) ?? 5;
    if (newPeriods < 1) newPeriods = 1;
    if (newPeriods > 20) newPeriods = 20;

    setState(() {
      _numberOfPeriods = newPeriods;
      _initializeCashFlowControllers();
    });
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _result = '';
    });

    try {
      List<double> cashFlows = [];
      for (var controller in _cashFlowControllers) {
        cashFlows.add(double.parse(controller.text.replaceAll(',', '.')));
      }

      double irr = FinancialCalculations.calculateIRR(cashFlows);
      _result =
          'Tasa Interna de Retorno (TIR): ${(irr * 100).toStringAsFixed(2)}%';
    } catch (e) {
      _result = 'Error en el cálculo: ${e.toString()}';
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  void _resetForm() {
    for (var controller in _cashFlowControllers) {
      controller.clear();
    }
    setState(() {
      _result = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasa Interna de Retorno (TIR)'),
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
                    'Calculadora de TIR',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresa los flujos de caja para calcular la Tasa Interna de Retorno',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
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
                      if (int.tryParse(value) == null || int.parse(value) < 1) {
                        return 'Debe ser un número entero mayor a 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Flujos de Caja:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _numberOfPeriods + 1,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CustomTextField(
                          controller: _cashFlowControllers[index],
                          label:
                              index == 0
                                  ? 'Inversión Inicial (t=0)'
                                  : 'Flujo de Caja Período $index',
                          hint:
                              index == 0
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
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Calcular TIR',
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
}
