import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GradienteAritmeticoScreen extends StatefulWidget {
  const GradienteAritmeticoScreen({super.key});

  @override
  State<GradienteAritmeticoScreen> createState() =>
      _GradienteAritmeticoScreenState();
}

class _GradienteAritmeticoScreenState extends State<GradienteAritmeticoScreen> {
  // Color principal naranja
  final Color _primaryColor = const Color(0xFFFF9800);

  final _firstPaymentController = TextEditingController();
  final _gradientController = TextEditingController();
  final _rateController = TextEditingController();
  final _periodsController = TextEditingController();

  // Tipo de cálculo (valor presente o valor futuro)
  String _calculationType = 'presentValue';

  // Tipo de gradiente (creciente o decreciente)
  String _gradientType = 'increasing';

  // Resultados
  double _calculatedValue = 0.0;
  bool _hasCalculated = false;
  String? _errorMessage;

  // Controlador para el ScrollView
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _firstPaymentController.dispose();
    _gradientController.dispose();
    _rateController.dispose();
    _periodsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculate() {
    // Ocultar el teclado
    FocusScope.of(context).unfocus();

    // Validar que los campos tengan valores
    if (_firstPaymentController.text.isEmpty ||
        _gradientController.text.isEmpty ||
        _rateController.text.isEmpty ||
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
      final firstPayment = double.parse(
        _firstPaymentController.text.replaceAll(',', '.'),
      );

      // Obtener el valor absoluto del gradiente
      double gradientValue = double.parse(
        _gradientController.text.replaceAll(',', '.'),
      );

      // Aplicar signo según el tipo seleccionado
      final gradient =
          _gradientType == 'decreasing'
              ? -gradientValue.abs()
              : gradientValue.abs();

      final rate =
          double.parse(_rateController.text.replaceAll(',', '.')) /
          100; // Convertir a decimal
      final periods = int.parse(_periodsController.text);

      // Validar valores
      if (periods <= 0) {
        throw Exception('El número de períodos debe ser mayor a cero');
      }

      if (rate <= 0) {
        throw Exception('La tasa de interés debe ser mayor a cero');
      }

      // Calcular según el tipo seleccionado
      double result = 0.0;

      if (_calculationType == 'presentValue') {
        // Calcular valor presente
        result = _calculatePresentValue(firstPayment, gradient, rate, periods);
      } else {
        // Calcular valor futuro
        result = _calculateFutureValue(firstPayment, gradient, rate, periods);
      }

      setState(() {
        _calculatedValue = result;
        _hasCalculated = true;
        _errorMessage = null;
      });

      // Desplazar hacia abajo para mostrar los resultados
      _scrollToResults();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error en el cálculo: $e';
        _hasCalculated = true;
      });

      // Desplazar hacia abajo para mostrar el error
      _scrollToResults();
    }
  }

  // Calcular valor presente de un gradiente aritmético
  double _calculatePresentValue(
    double firstPayment,
    double gradient,
    double rate,
    int periods,
  ) {
    // Valor presente de una anualidad ordinaria
    double annuityPV = firstPayment * ((1 - pow(1 + rate, -periods)) / rate);

    // Factor de gradiente aritmético
    double gradientFactor =
        (1 / rate) *
        ((1 - pow(1 + rate, -periods)) / rate -
            periods * pow(1 + rate, -periods));

    // Valor presente del gradiente
    double gradientPV = gradient * gradientFactor;

    return annuityPV + gradientPV;
  }

  // Calcular valor futuro de un gradiente aritmético
  double _calculateFutureValue(
    double firstPayment,
    double gradient,
    double rate,
    int periods,
  ) {
    // Valor futuro de una anualidad ordinaria
    double annuityFV = firstPayment * ((pow(1 + rate, periods) - 1) / rate);

    // Factor de gradiente aritmético para valor futuro
    double gradientFactor =
        (1 / rate) * ((pow(1 + rate, periods) - 1) / rate - periods);

    // Valor futuro del gradiente
    double gradientFV = gradient * gradientFactor;

    return annuityFV + gradientFV;
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
      _firstPaymentController.clear();
      _gradientController.clear();
      _rateController.clear();
      _periodsController.clear();
      _calculatedValue = 0.0;
      _hasCalculated = false;
      _errorMessage = null;
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
          'Gradiente Aritmético',
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
                            Icons.trending_up,
                            color: _primaryColor,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 15),
                        Text(
                          '¿Qué es un Gradiente Aritmético?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Un gradiente aritmético es una serie de flujos de caja que aumentan o disminuyen en una cantidad constante (G) en cada período. El primer flujo es A, el segundo es A+G, el tercero es A+2G, y así sucesivamente.',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Este tipo de series es común en situaciones donde los pagos o ingresos crecen o decrecen a un ritmo constante, como en algunos contratos de arrendamiento, planes de ahorro o proyectos de inversión con rendimientos variables.',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

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
                              'Fórmulas',
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
                          // Título del gradiente aritmético
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Gradiente Aritmético: Creciente y Decreciente',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Fórmula para valor presente
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Valor Presente (VP):',
                                  style: TextStyle(
                                    color: _primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 15),

                                // Fórmula matemática detallada para VP
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    _gradientType == 'increasing'
                                        ? 'Vp = A [ (1-(1+i)^-n) / i ] + (G/i) [ (1-(1+i)^-n) / i - n / (1+i)^n ]'
                                        : 'Vp = A [ (1-(1+i)^-n) / i ] - (G/i) [ (1-(1+i)^-n) / i - n / (1+i)^n ]',
                                    style: TextStyle(
                                      color: const Color(0xFF293431),
                                      fontSize: 14,
                                      fontFamily: 'monospace',
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Fórmula para valor futuro
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Valor Futuro (VF):',
                                  style: TextStyle(
                                    color: _primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 15),

                                // Fórmula matemática detallada para VF
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    _gradientType == 'increasing'
                                        ? 'Vf = A [ ((1+i)^n - 1) / i ] + (G/i) [ ((1+i)^n - 1) / i - n ]'
                                        : 'Vf = A [ ((1+i)^n - 1) / i ] - (G/i) [ ((1+i)^n - 1) / i - n ]',
                                    style: TextStyle(
                                      color: const Color(0xFF293431),
                                      fontSize: 14,
                                      fontFamily: 'monospace',
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),

                          Row(
                            children: [
                              _buildFormulaItem('A', 'Primer pago'),
                              _buildFormulaItem('G', 'Gradiente'),
                              _buildFormulaItem('i', 'Tasa interés'),
                              _buildFormulaItem('n', 'Períodos'),
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
                              'El gradiente puede ser positivo (creciente) o negativo (decreciente).',
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

                    // Selector de tipo de cálculo
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipo de Cálculo',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              RadioListTile<String>(
                                title: Text(
                                  'Calcular Valor Presente',
                                  style: TextStyle(
                                    color: const Color(0xFF293431),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                value: 'presentValue',
                                groupValue: _calculationType,
                                activeColor: _primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _calculationType = value!;
                                    _hasCalculated = false;
                                  });
                                },
                              ),
                              RadioListTile<String>(
                                title: Text(
                                  'Calcular Valor Futuro',
                                  style: TextStyle(
                                    color: const Color(0xFF293431),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                value: 'futureValue',
                                groupValue: _calculationType,
                                activeColor: _primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _calculationType = value!;
                                    _hasCalculated = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Selector de tipo de gradiente
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipo de Gradiente',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              RadioListTile<String>(
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Gradiente Creciente',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                value: 'increasing',
                                groupValue: _gradientType,
                                activeColor: _primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _gradientType = value!;
                                    _hasCalculated = false;
                                  });
                                },
                              ),
                              RadioListTile<String>(
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.trending_down,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Gradiente Decreciente',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                value: 'decreasing',
                                groupValue: _gradientType,
                                activeColor: _primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _gradientType = value!;
                                    _hasCalculated = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Campo de primer pago
                    _buildInputField(
                      controller: _firstPaymentController,
                      label: 'Primer Pago (A)',
                      hint: 'Ej: 1000',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      color: _primaryColor,
                    ),
                    const SizedBox(height: 15),

                    // Campo de gradiente
                    _buildInputField(
                      controller: _gradientController,
                      label: 'Gradiente (G) (valor absoluto)',
                      hint: 'Ej: 100',
                      prefixIcon:
                          _gradientType == 'increasing'
                              ? Icons.trending_up
                              : Icons.trending_down,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      color: _primaryColor,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Ingrese el valor absoluto. El signo se aplicará según la selección anterior.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Campo de tasa de interés
                    _buildInputField(
                      controller: _rateController,
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
                      label: 'Número de Períodos (n)',
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

              // Resultados
              if (_hasCalculated) ...[
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
                              Icons.analytics_rounded,
                              color: _primaryColor,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Resultados',
                            style: TextStyle(
                              color: const Color(0xFF151616),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (_errorMessage != null) ...[
                        // Mensaje de error
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Resultado del cálculo
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _calculationType == 'presentValue'
                                        ? Icons.account_balance_wallet
                                        : Icons.trending_up,
                                    color: _primaryColor,
                                    size: 28,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    _calculationType == 'presentValue'
                                        ? 'Valor Presente'
                                        : 'Valor Futuro',
                                    style: TextStyle(
                                      color: const Color(0xFF293431),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Text(
                                '\$${_formatNumber(_calculatedValue)}',
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Resumen de datos ingresados
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Datos Ingresados:',
                                style: TextStyle(
                                  color: const Color(0xFF293431),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildDataRow(
                                'Tipo de Gradiente:',
                                _gradientType == 'increasing'
                                    ? 'Creciente'
                                    : 'Decreciente',
                              ),
                              _buildDataRow(
                                'Primer Pago (A):',
                                '\$${_formatNumber(double.parse(_firstPaymentController.text.replaceAll(',', '.')))}',
                              ),
                              _buildDataRow(
                                'Gradiente (G):',
                                '\$${_formatNumber(double.parse(_gradientController.text.replaceAll(',', '.')) * (_gradientType == 'decreasing' ? -1 : 1))}',
                              ),
                              _buildDataRow(
                                'Tasa de Interés (i):',
                                '${_rateController.text.replaceAll(',', '.')}%',
                              ),
                              _buildDataRow(
                                'Número de Períodos (n):',
                                _periodsController.text,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tabla de flujo de caja
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.show_chart,
                                    color: _primaryColor,
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Flujo de Caja por Período:',
                                    style: TextStyle(
                                      color: const Color(0xFF293431),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(
                                    _primaryColor.withOpacity(0.1),
                                  ),
                                  headingTextStyle: TextStyle(
                                    color: const Color(0xFF293431),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  dataRowColor:
                                      MaterialStateProperty.resolveWith<Color>((
                                        Set<MaterialState> states,
                                      ) {
                                        if (states.contains(
                                          MaterialState.selected,
                                        )) {
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
                                        child: Text('Flujo de Caja'),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                        child: Text('Cálculo'),
                                      ),
                                    ),
                                  ],
                                  rows:
                                      _buildCashFlowTable().map((flow) {
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 8,
                                                  horizontal: 4,
                                                ),
                                                child: Text(
                                                  flow['period'].toString(),
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
                                                  '\$${_formatNumber(flow['cashFlow'])}',
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
                                                  flow['calculation'],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'A = Primer pago, G = Gradiente',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

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
                                'El gradiente aritmético es útil para modelar flujos de caja que aumentan o disminuyen en una cantidad constante en cada período.',
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

  // Widget para filas de datos en el resumen
  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: const Color(0xFF293431), fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF293431),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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

  // Método para construir la tabla de flujo de caja
  List<Map<String, dynamic>> _buildCashFlowTable() {
    List<Map<String, dynamic>> cashFlows = [];

    try {
      // Obtener valores de los controladores
      final firstPayment = double.parse(
        _firstPaymentController.text.replaceAll(',', '.'),
      );

      // Obtener el valor absoluto del gradiente
      double gradientValue = double.parse(
        _gradientController.text.replaceAll(',', '.'),
      );

      // Aplicar signo según el tipo seleccionado
      final gradient =
          _gradientType == 'decreasing'
              ? -gradientValue.abs()
              : gradientValue.abs();

      final periods = int.parse(_periodsController.text);

      // Calcular flujo para cada período
      for (int i = 1; i <= periods; i++) {
        double cashFlow = firstPayment + (i - 1) * gradient;
        String calculation;

        if (_gradientType == 'increasing') {
          calculation =
              'A + (${i - 1})G = $firstPayment + ${(i - 1)} × ${gradientValue.abs()}';
        } else {
          calculation =
              'A - (${i - 1})G = $firstPayment - ${(i - 1)} × ${gradientValue.abs()}';
        }

        cashFlows.add({
          'period': i,
          'cashFlow': cashFlow,
          'calculation': calculation,
        });
      }
    } catch (e) {
      // En caso de error, devolver lista vacía
      print('Error al construir tabla de flujo de caja: $e');
    }

    return cashFlows;
  }
}
