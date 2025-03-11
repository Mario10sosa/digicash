import 'package:flutter/material.dart';
import 'package:digicash/widgets/custom_button.dart';
import 'package:digicash/widgets/custom_text_field.dart';
import 'package:digicash/utils/financial_calculations.dart';

class AmortizationScreen extends StatefulWidget {
  const AmortizationScreen({Key? key}) : super(key: key);

  @override
  State<AmortizationScreen> createState() => _AmortizationScreenState();
}

class _AmortizationScreenState extends State<AmortizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loanAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _periodsController = TextEditingController();

  String _amortizationType = 'french';
  List<Map<String, dynamic>> _amortizationSchedule = [];
  bool _isCalculating = false;

  @override
  void dispose() {
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _periodsController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
      _amortizationSchedule = [];
    });

    try {
      double loanAmount = double.parse(
        _loanAmountController.text.replaceAll(',', '.'),
      );
      double interestRate =
          double.parse(_interestRateController.text.replaceAll(',', '.')) / 100;
      int periods = int.parse(_periodsController.text);

      switch (_amortizationType) {
        case 'german':
          _amortizationSchedule = FinancialCalculations.germanAmortization(
            loanAmount,
            interestRate,
            periods,
          );
          break;
        case 'french':
          _amortizationSchedule = FinancialCalculations.frenchAmortization(
            loanAmount,
            interestRate,
            periods,
          );
          break;
        case 'american':
          _amortizationSchedule = FinancialCalculations.americanAmortization(
            loanAmount,
            interestRate,
            periods,
          );
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en el cálculo: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  void _resetForm() {
    _loanAmountController.clear();
    _interestRateController.clear();
    _periodsController.clear();
    setState(() {
      _amortizationSchedule = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Amortización'), centerTitle: true),
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
                    'Calculadora de Amortización',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona el tipo de amortización',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  _buildAmortizationTypeSelector(),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _loanAmountController,
                    label: 'Monto del Préstamo',
                    hint: 'Ingresa el monto del préstamo',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el monto del préstamo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _interestRateController,
                    label: 'Tasa de Interés',
                    hint: 'Ingresa la tasa de interés (%)',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.percent,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la tasa de interés';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _periodsController,
                    label: 'Número de Períodos',
                    hint: 'Ingresa el número de períodos',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.access_time,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el número de períodos';
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
                  if (_amortizationSchedule.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Tabla de Amortización',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAmortizationTable(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmortizationTypeSelector() {
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
            title: const Text('Amortización Francesa (cuotas constantes)'),
            value: 'french',
            groupValue: _amortizationType,
            onChanged: (value) {
              setState(() {
                _amortizationType = value!;
                _amortizationSchedule = [];
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Amortización Alemana (capital constante)'),
            value: 'german',
            groupValue: _amortizationType,
            onChanged: (value) {
              setState(() {
                _amortizationType = value!;
                _amortizationSchedule = [];
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Amortización Americana (pago al final)'),
            value: 'american',
            groupValue: _amortizationType,
            onChanged: (value) {
              setState(() {
                _amortizationType = value!;
                _amortizationSchedule = [];
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmortizationTable() {
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Período')),
            DataColumn(label: Text('Cuota')),
            DataColumn(label: Text('Capital')),
            DataColumn(label: Text('Interés')),
            DataColumn(label: Text('Saldo')),
          ],
          rows:
              _amortizationSchedule.map((row) {
                return DataRow(
                  cells: [
                    DataCell(Text(row['period'].toString())),
                    DataCell(Text('\$${row['payment'].toStringAsFixed(2)}')),
                    DataCell(Text('\$${row['principal'].toStringAsFixed(2)}')),
                    DataCell(Text('\$${row['interest'].toStringAsFixed(2)}')),
                    DataCell(Text('\$${row['balance'].toStringAsFixed(2)}')),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}
