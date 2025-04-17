import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GradienteGeometricoScreen extends StatefulWidget {
  const GradienteGeometricoScreen({super.key});

  @override
  State<GradienteGeometricoScreen> createState() =>
      _GradienteGeometricoScreenState();
}

class _GradienteGeometricoScreenState extends State<GradienteGeometricoScreen> {
  // Color principal índigo
  final Color _primaryColor = const Color(0xFF3F51B5);

  final _firstPaymentController = TextEditingController();
  final _growthRateController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _periodsController = TextEditingController();

  // Tipo de cálculo (valor presente o valor futuro)
  String _calculationType = 'presentValue';

  // Tipo de tasa de crecimiento (crecimiento o decrecimiento)
  String _growthRateType = 'increasing';

  // Resultados
  double _calculatedValue = 0.0;
  bool _hasCalculated = false;
  String? _errorMessage;

  // Controlador para el ScrollView
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _firstPaymentController.dispose();
    _growthRateController.dispose();
    _interestRateController.dispose();
    _periodsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculate() {
    // Ocultar el teclado
    FocusScope.of(context).unfocus();

    // Validar que los campos tengan valores
    if (_firstPaymentController.text.isEmpty ||
        _growthRateController.text.isEmpty ||
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
      final firstPayment = double.parse(
        _firstPaymentController.text.replaceAll(',', '.'),
      );

      // Obtener el valor absoluto de la tasa de crecimiento
      double growthRateValue =
          double.parse(_growthRateController.text.replaceAll(',', '.')) / 100;

      // Aplicar signo según el tipo seleccionado
      final growthRate =
          _growthRateType == 'decreasing'
              ? -growthRateValue.abs()
              : growthRateValue.abs();

      final interestRate =
          double.parse(_interestRateController.text.replaceAll(',', '.')) /
          100; // Convertir a decimal
      final periods = int.parse(_periodsController.text);

      // Validar valores
      if (periods <= 0) {
        throw Exception('El número de períodos debe ser mayor a cero');
      }

      if (interestRate <= 0) {
        throw Exception('La tasa de interés debe ser mayor a cero');
      }

      if (growthRate <= -1) {
        throw Exception('La tasa de crecimiento debe ser mayor a -100%');
      }

      // Calcular según el tipo seleccionado
      double result = 0.0;

      if (_calculationType == 'presentValue') {
        // Calcular valor presente
        result = _calculatePresentValue(
          firstPayment,
          growthRate,
          interestRate,
          periods,
        );
      } else {
        // Calcular valor futuro
        result = _calculateFutureValue(
          firstPayment,
          growthRate,
          interestRate,
          periods,
        );
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

  // Calcular valor presente de un gradiente geométrico
  double _calculatePresentValue(
    double firstPayment,
    double growthRate,
    double interestRate,
    int periods,
  ) {
    // Caso especial: tasa de crecimiento igual a tasa de interés
    if ((1 + growthRate).abs() - (1 + interestRate).abs() < 0.0000001) {
      return firstPayment * periods / (1 + interestRate);
    }

    // Caso general: tasa de crecimiento diferente a tasa de interés
    double factor =
        (1 - pow((1 + growthRate) / (1 + interestRate), periods)) /
        (interestRate - growthRate);
    return firstPayment * factor;
  }

  // Calcular valor futuro de un gradiente geométrico
  double _calculateFutureValue(
    double firstPayment,
    double growthRate,
    double interestRate,
    int periods,
  ) {
    // Caso especial: tasa de crecimiento igual a tasa de interés
    if ((1 + growthRate).abs() - (1 + interestRate).abs() < 0.0000001) {
      return firstPayment * periods * pow(1 + interestRate, periods - 1);
    }

    // Caso general: tasa de crecimiento diferente a tasa de interés
    double factor =
        (pow(1 + interestRate, periods) - pow(1 + growthRate, periods)) /
        (interestRate - growthRate);
    return firstPayment * factor;
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
      _growthRateController.clear();
      _interestRateController.clear();
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
          'Gradiente Geométrico',
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
                          '¿Qué es un Gradiente Geométrico?',
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
                      'Un gradiente geométrico es una serie de flujos de caja que aumentan o disminuyen en una tasa porcentual constante (g) en cada período. El primer flujo es A, el segundo es A(1+g), el tercero es A(1+g)², y así sucesivamente.',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Este tipo de series es común en situaciones donde los pagos o ingresos crecen o decrecen a un ritmo porcentual constante, como en algunos contratos con ajuste por inflación, inversiones con rendimiento compuesto o proyecciones de crecimiento económico.',
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
                          // Título del gradiente geométrico
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Gradiente Geométrico',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Caso general: i ≠ g
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Caso General (i ≠ g):',
                                  style: TextStyle(
                                    color: _primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 15),

                                // Fórmula para valor presente
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Valor Presente (VP):',
                                        style: TextStyle(
                                          color: _primaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'VP = A × [ 1 - ((1+g)/(1+i))^n ] / (i-g)',
                                        style: TextStyle(
                                          color: const Color(0xFF293431),
                                          fontSize: 14,
                                          fontFamily: 'monospace',
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 15),

                                // Fórmula para valor futuro
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Valor Futuro (VF):',
                                        style: TextStyle(
                                          color: _primaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'VF = A × [ (1+i)^n - (1+g)^n ] / (i-g)',
                                        style: TextStyle(
                                          color: const Color(0xFF293431),
                                          fontSize: 14,
                                          fontFamily: 'monospace',
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Caso especial: i = g
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Caso Especial (i = g):',
                                  style: TextStyle(
                                    color: _primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 15),

                                // Fórmula para valor presente
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Valor Presente (VP):',
                                        style: TextStyle(
                                          color: _primaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'VP = A × n / (1+i)',
                                        style: TextStyle(
                                          color: const Color(0xFF293431),
                                          fontSize: 14,
                                          fontFamily: 'monospace',
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 15),

                                // Fórmula para valor futuro
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Valor Futuro (VF):',
                                        style: TextStyle(
                                          color: _primaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'VF = A × n × (1+i)^(n-1)',
                                        style: TextStyle(
                                          color: const Color(0xFF293431),
                                          fontSize: 14,
                                          fontFamily: 'monospace',
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),

                          Row(
                            children: [
                              _buildFormulaItem('A', 'Primer pago'),
                              _buildFormulaItem('g', 'Tasa crec.'),
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
                              'La tasa de crecimiento (g) puede ser positiva (crecimiento) o negativa (decrecimiento).',
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

                    // Selector de tipo de tasa de crecimiento
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tasa de Crecimiento',
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
                                      'Crecimiento',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                value: 'increasing',
                                groupValue: _growthRateType,
                                activeColor: _primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _growthRateType = value!;
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
                                      'Decrecimiento',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                value: 'decreasing',
                                groupValue: _growthRateType,
                                activeColor: _primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _growthRateType = value!;
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

                    // Campo de tasa de crecimiento
                    _buildInputField(
                      controller: _growthRateController,
                      label: 'Tasa de Crecimiento (g) % (valor absoluto)',
                      hint: 'Ej: 5',
                      prefixIcon:
                          _growthRateType == 'increasing'
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
                      controller: _interestRateController,
                      label: 'Tasa de Interés (i) %',
                      hint: 'Ej: 8',
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
                                'Primer Pago (A):',
                                '\$${_formatNumber(double.parse(_firstPaymentController.text.replaceAll(',', '.')))}',
                              ),
                              _buildDataRow(
                                'Tipo de Tasa:',
                                _growthRateType == 'increasing'
                                    ? 'Crecimiento'
                                    : 'Decrecimiento',
                              ),
                              _buildDataRow(
                                'Tasa de Crecimiento (g):',
                                '${_growthRateType == 'decreasing' ? '-' : ''}${_growthRateController.text.replaceAll(',', '.')}%',
                              ),
                              _buildDataRow(
                                'Tasa de Interés (i):',
                                '${_interestRateController.text.replaceAll(',', '.')}%',
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
                                                  "\$${_formatNumber(flow['cashFlow'])}",
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
                                'A = Primer pago, g = Tasa de crecimiento',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Caso especial
                        if (_isSpecialCase()) ...[
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.amber[700],
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Nota: La tasa de crecimiento (g) es igual a la tasa de interés (i). Se ha aplicado una fórmula especial para este caso.',
                                    style: TextStyle(
                                      color: Colors.amber[900],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],

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
                                'El gradiente geométrico es útil para modelar flujos de caja que aumentan o disminuyen a una tasa porcentual constante, como en situaciones con inflación o crecimiento económico.',
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

  // Verificar si es un caso especial (i = g)
  bool _isSpecialCase() {
    try {
      // Obtener el valor absoluto de la tasa de crecimiento
      double growthRateValue =
          double.parse(_growthRateController.text.replaceAll(',', '.')) / 100;

      // Aplicar signo según el tipo seleccionado
      final growthRate =
          _growthRateType == 'decreasing'
              ? -growthRateValue.abs()
              : growthRateValue.abs();

      final interestRate =
          double.parse(_interestRateController.text.replaceAll(',', '.')) / 100;

      return (1 + growthRate).abs() - (1 + interestRate).abs() < 0.0000001;
    } catch (e) {
      return false;
    }
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

      // Obtener el valor absoluto de la tasa de crecimiento
      double growthRateValue =
          double.parse(_growthRateController.text.replaceAll(',', '.')) / 100;

      // Aplicar signo según el tipo seleccionado
      final growthRate =
          _growthRateType == 'decreasing'
              ? -growthRateValue.abs()
              : growthRateValue.abs();

      final periods = int.parse(_periodsController.text);

      // Calcular flujo para cada período
      for (int i = 1; i <= periods; i++) {
        double cashFlow = firstPayment * pow(1 + growthRate, i - 1);
        String calculation =
            'A × (1+g)^(${i - 1}) = $firstPayment × (1${_growthRateType == 'decreasing' ? '-' : '+'}${(growthRateValue * 100).toStringAsFixed(2)}%)^${i - 1}';

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
