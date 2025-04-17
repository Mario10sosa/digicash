import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmortizacionScreen extends StatefulWidget {
  const AmortizacionScreen({super.key});

  @override
  State<AmortizacionScreen> createState() => _AmortizacionScreenState();
}

class _AmortizacionScreenState extends State<AmortizacionScreen> {
  // Color principal teal
  final Color _primaryColor = const Color(0xFF009688);

  final _loanAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _periodsController = TextEditingController();

  // Controlador para el ScrollView
  final ScrollController _scrollController = ScrollController();

  // Tabla de amortización
  List<Map<String, dynamic>> _amortizationSchedule = [];
  bool _hasCalculated = false;

  // Tipos de amortización
  final List<Map<String, dynamic>> _amortizationTypes = [
    {
      'label': 'Amortización Francesa',
      'value': 'french',
      'description':
          'Cuota fija durante todo el préstamo. La parte de interés disminuye y la de capital aumenta con cada pago.',
      'formula': 'A = P × r × (1 + r)^n / [(1 + r)^n - 1]',
    },
    {
      'label': 'Amortización Alemana',
      'value': 'german',
      'description':
          'Amortización constante de capital. La cuota total disminuye con el tiempo ya que los intereses se reducen.',
      'formula': 'A = P/n + r × P × (1 - (k-1)/n)',
    },
    {
      'label': 'Amortización Americana',
      'value': 'american',
      'description':
          'Solo se pagan intereses durante el plazo y el capital se devuelve íntegramente al final.',
      'formula': 'A = r × P (k < n), A = P × (1 + r) (k = n)',
    },
  ];

  // Tipo de amortización seleccionado (por defecto: francesa)
  Map<String, dynamic> _selectedAmortizationType = {
    'label': 'Amortización Francesa',
    'value': 'french',
    'description':
        'Cuota fija durante todo el préstamo. La parte de interés disminuye y la de capital aumenta con cada pago.',
    'formula': 'A = P × r × (1 + r)^n / [(1 + r)^n - 1]',
  };

  @override
  void dispose() {
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _periodsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculate() {
    // Ocultar el teclado
    FocusScope.of(context).unfocus();

    // Validar que los campos tengan valores
    if (_loanAmountController.text.isEmpty ||
        _interestRateController.text.isEmpty ||
        _periodsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Convertir valores a números
      final loanAmount = double.parse(
        _loanAmountController.text.replaceAll(',', '.'),
      );
      final interestRate =
          double.parse(_interestRateController.text.replaceAll(',', '.')) /
          100; // Convertir a decimal
      final periods = int.parse(_periodsController.text);

      // Calcular tabla de amortización según el tipo seleccionado
      List<Map<String, dynamic>> schedule = [];

      switch (_selectedAmortizationType['value']) {
        case 'french':
          schedule = _calculateFrenchAmortization(
            loanAmount,
            interestRate,
            periods,
          );
          break;
        case 'german':
          schedule = _calculateGermanAmortization(
            loanAmount,
            interestRate,
            periods,
          );
          break;
        case 'american':
          schedule = _calculateAmericanAmortization(
            loanAmount,
            interestRate,
            periods,
          );
          break;
      }

      setState(() {
        _amortizationSchedule = schedule;
        _hasCalculated = true;
      });

      // Desplazar hacia abajo para mostrar los resultados
      _scrollToResults();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en el cálculo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Cálculo de amortización francesa (cuotas constantes)
  List<Map<String, dynamic>> _calculateFrenchAmortization(
    double loanAmount,
    double interestRate,
    int periods,
  ) {
    List<Map<String, dynamic>> schedule = [];

    // Convertir tasa anual a tasa periódica mensual
    double periodicRate = interestRate / 12;

    // Calcular cuota constante: A = P × r × (1 + r)^n / [(1 + r)^n - 1]
    double payment =
        loanAmount *
        periodicRate *
        pow(1 + periodicRate, periods) /
        (pow(1 + periodicRate, periods) - 1);

    double remainingBalance = loanAmount;

    for (int period = 1; period <= periods; period++) {
      // Calcular interés del período
      double interest = remainingBalance * periodicRate;

      // Calcular amortización de capital
      double principal = payment - interest;

      // Actualizar saldo pendiente
      remainingBalance -= principal;

      // Ajustar el último período para evitar errores de redondeo
      if (period == periods) {
        principal += remainingBalance;
        remainingBalance = 0;
      }

      // Agregar fila a la tabla
      schedule.add({
        'period': period,
        'payment': payment,
        'principal': principal,
        'interest': interest,
        'balance': remainingBalance,
      });
    }

    return schedule;
  }

  // Cálculo de amortización alemana (capital constante)
  List<Map<String, dynamic>> _calculateGermanAmortization(
    double loanAmount,
    double interestRate,
    int periods,
  ) {
    List<Map<String, dynamic>> schedule = [];

    // Convertir tasa anual a tasa periódica mensual
    double periodicRate = interestRate / 12;

    // Amortización constante de capital
    double principalPayment = loanAmount / periods;
    double remainingBalance = loanAmount;

    for (int period = 1; period <= periods; period++) {
      // Calcular interés del período
      double interest = remainingBalance * periodicRate;

      // Calcular cuota total
      double payment = principalPayment + interest;

      // Actualizar saldo pendiente
      remainingBalance -= principalPayment;

      // Ajustar el último período para evitar errores de redondeo
      if (period == periods) {
        principalPayment += remainingBalance;
        remainingBalance = 0;
      }

      // Agregar fila a la tabla
      schedule.add({
        'period': period,
        'payment': payment,
        'principal': principalPayment,
        'interest': interest,
        'balance': remainingBalance,
      });
    }

    return schedule;
  }

  // Cálculo de amortización americana (pago único al final)
  List<Map<String, dynamic>> _calculateAmericanAmortization(
    double loanAmount,
    double interestRate,
    int periods,
  ) {
    List<Map<String, dynamic>> schedule = [];

    // Convertir tasa anual a tasa periódica mensual
    double periodicRate = interestRate / 12;

    double remainingBalance = loanAmount;

    for (int period = 1; period <= periods; period++) {
      // Calcular interés del período
      double interest = remainingBalance * periodicRate;

      double principal = 0;
      double payment = interest;

      // En el último período se paga todo el capital
      if (period == periods) {
        principal = remainingBalance;
        payment = principal + interest;
        remainingBalance = 0;
      }

      // Agregar fila a la tabla
      schedule.add({
        'period': period,
        'payment': payment,
        'principal': principal,
        'interest': interest,
        'balance': remainingBalance,
      });
    }

    return schedule;
  }

  void _scrollToResults() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // Limpiar todos los campos
  void _clearFields() {
    setState(() {
      _loanAmountController.clear();
      _interestRateController.clear();
      _periodsController.clear();
      _amortizationSchedule = [];
      _hasCalculated = false;
    });

    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Todos los campos han sido limpiados'),
        backgroundColor: const Color(0xFF293431),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Amortización',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFF5F7FA), const Color(0xFFE4E9F2)],
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              // Tarjeta de explicación
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calculate_outlined,
                            color: _primaryColor,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 15),
                        Text(
                          '¿Qué es la Amortización?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'La amortización es el proceso de pago de una deuda y sus intereses mediante una serie de cuotas periódicas en un tiempo determinado. Existen diferentes sistemas de amortización que determinan cómo se distribuye el pago del capital e intereses a lo largo del tiempo.',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Selector de tipo de amortización
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipo de Amortización',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey[300]!),
                            color: _primaryColor.withOpacity(0.05),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedAmortizationType['value'],
                              hint: Text('Seleccione tipo de amortización'),
                              onChanged: (value) {
                                setState(() {
                                  _selectedAmortizationType = _amortizationTypes
                                      .firstWhere(
                                        (type) => type['value'] == value,
                                      );
                                  _amortizationSchedule = [];
                                  _hasCalculated = false;
                                });
                              },
                              icon: Icon(
                                Icons.arrow_drop_down_circle_outlined,
                                color: _primaryColor,
                              ),
                              items:
                                  _amortizationTypes.map((type) {
                                    return DropdownMenuItem<String>(
                                      value: type['value'],
                                      child: Text(
                                        type['label'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Descripción del tipo de amortización seleccionado
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: _primaryColor,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedAmortizationType['description'],
                              style: TextStyle(
                                color: const Color(0xFF151616),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: _primaryColor),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Fórmula',
                              style: TextStyle(
                                color: _primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _selectedAmortizationType['formula'],
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              _buildFormulaItem('P', 'Préstamo'),
                              _buildFormulaItem('i', 'Tasa interés'),
                              _buildFormulaItem('n', 'Períodos'),
                              _buildFormulaItem('C', 'Cuota'),
                              if (_selectedAmortizationType['value'] ==
                                  'german')
                                _buildFormulaItem('A', 'Amortización'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: _primaryColor,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'La tabla de amortización muestra el detalle de cada pago a lo largo del tiempo.',
                              style: TextStyle(
                                color: const Color(0xFF151616),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Tarjeta de calculadora
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calculate_rounded,
                            color: _primaryColor,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 15),
                        Text(
                          'Calculadora',
                          style: TextStyle(
                            color: const Color(0xFF151616),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Campo de monto del préstamo
                    _buildInputField(
                      controller: _loanAmountController,
                      label: 'Monto del Préstamo (P)',
                      hint: 'Ej: 10000000',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      color: _primaryColor,
                    ),
                    const SizedBox(height: 15),

                    // Campo de tasa de interés
                    _buildInputField(
                      controller: _interestRateController,
                      label: 'Tasa de Interés Anual (i) %',
                      hint: 'Ej: 5',
                      prefixIcon: Icons.percent,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      color: _primaryColor,
                    ),
                    const SizedBox(height: 15),

                    // Campo de número de períodos
                    _buildInputField(
                      controller: _periodsController,
                      label: 'Número de Períodos (meses)',
                      hint: 'Ej: 12',
                      prefixIcon: Icons.access_time,
                      keyboardType: TextInputType.number,
                      color: _primaryColor,
                    ),
                    const SizedBox(height: 25),

                    // Botón de calcular
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _calculate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calculate_rounded,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Calcular',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _clearFields,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 2,
                          ),
                          child: Icon(Icons.clear, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Resultados - Tabla de amortización
              if (_hasCalculated && _amortizationSchedule.isNotEmpty) ...[
                const SizedBox(height: 25),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.table_chart,
                              color: _primaryColor,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Tabla de Amortización',
                            style: TextStyle(
                              color: const Color(0xFF151616),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Resumen del préstamo
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumen del Préstamo',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryItem(
                                    'Monto del Préstamo',
                                    '\$${_formatNumber(double.parse(_loanAmountController.text.replaceAll(',', '.')))}',
                                    Icons.attach_money,
                                  ),
                                ),
                                Expanded(
                                  child: _buildSummaryItem(
                                    'Tasa de Interés',
                                    '${_interestRateController.text.replaceAll(',', '.')}%',
                                    Icons.percent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryItem(
                                    'Número de Períodos',
                                    _periodsController.text,
                                    Icons.access_time,
                                  ),
                                ),
                                Expanded(
                                  child: _buildSummaryItem(
                                    'Tipo de Amortización',
                                    _selectedAmortizationType['label'].split(
                                      ' ',
                                    )[1],
                                    Icons.account_balance,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Divider(color: _primaryColor.withOpacity(0.3)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryItem(
                                    'Total a Pagar',
                                    '\$${_formatNumber(_calculateTotalPayment())}',
                                    Icons.account_balance_wallet,
                                  ),
                                ),
                                Expanded(
                                  child: _buildSummaryItem(
                                    'Total Intereses',
                                    '\$${_formatNumber(_calculateTotalInterest())}',
                                    Icons.trending_up,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tabla de amortización
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            _primaryColor.withOpacity(0.1),
                          ),
                          headingTextStyle: TextStyle(
                            color: const Color(0xFF293431),
                            fontWeight: FontWeight.bold,
                          ),
                          dataRowColor:
                              MaterialStateProperty.resolveWith<Color>((
                                Set<MaterialState> states,
                              ) {
                                if (states.contains(MaterialState.selected)) {
                                  return _primaryColor.withOpacity(0.1);
                                }
                                return Colors.white;
                              }),
                          border: TableBorder(
                            horizontalInside: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                            verticalInside: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          columns: [
                            DataColumn(
                              label: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Text('Período'),
                              ),
                            ),
                            DataColumn(
                              label: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Text('Cuota'),
                              ),
                            ),
                            DataColumn(
                              label: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Text('Capital'),
                              ),
                            ),
                            DataColumn(
                              label: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Text('Interés'),
                              ),
                            ),
                            DataColumn(
                              label: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Text('Saldo'),
                              ),
                            ),
                          ],
                          rows:
                              _amortizationSchedule.map((row) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          row['period'].toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          '\$${_formatNumber(row['payment'])}',
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          '\$${_formatNumber(row['principal'])}',
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          '\$${_formatNumber(row['interest'])}',
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          '\$${_formatNumber(row['balance'])}',
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Nota explicativa
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _primaryColor.withOpacity(0.1),
                              _primaryColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: _primaryColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'La elección del sistema de amortización afecta directamente a la distribución de los pagos de capital e intereses a lo largo del tiempo.',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  // Calcular el total a pagar
  double _calculateTotalPayment() {
    double total = 0;
    for (var row in _amortizationSchedule) {
      total += row['payment'];
    }
    return total;
  }

  // Calcular el total de intereses
  double _calculateTotalInterest() {
    double total = 0;
    for (var row in _amortizationSchedule) {
      total += row['interest'];
    }
    return total;
  }

  // Widget para los elementos de la fórmula
  Widget _buildFormulaItem(String symbol, String description) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  color: _primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget para los campos de entrada
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required TextInputType keyboardType,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF293431),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(prefixIcon, color: color),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: color, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
            ),
            style: TextStyle(fontSize: 16, color: const Color(0xFF151616)),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
          ),
        ),
      ],
    );
  }

  // Widget para los elementos del resumen
  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: _primaryColor),
            SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF293431),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Formatear números con separadores de miles
  String _formatNumber(double number) {
    return number
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
