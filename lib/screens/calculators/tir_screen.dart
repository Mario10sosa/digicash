import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TirScreen extends StatefulWidget {
  const TirScreen({super.key});

  @override
  State<TirScreen> createState() => _TirScreenState();
}

class _TirScreenState extends State<TirScreen> {
  // Color principal rojo
  final Color _primaryColor = const Color(0xFFE53935);

  // Controladores para los flujos de caja
  final List<TextEditingController> _cashFlowControllers = [];

  // Número de períodos
  int _numberOfPeriods = 5;

  // Resultado del cálculo
  double? _tirResult;
  bool _hasCalculated = false;
  String? _errorMessage;

  // Controlador para el ScrollView
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }

  void _updateNumberOfPeriods(int newPeriods) {
    if (newPeriods < 1) newPeriods = 1;
    if (newPeriods > 20) newPeriods = 20;

    setState(() {
      _numberOfPeriods = newPeriods;

      // Guardar los valores actuales
      List<String> currentValues = [];
      for (int i = 0; i < _cashFlowControllers.length; i++) {
        currentValues.add(_cashFlowControllers[i].text);
      }

      // Reinicializar los controladores
      _initializeCashFlowControllers();

      // Restaurar los valores anteriores
      for (
        int i = 0;
        i < currentValues.length && i < _cashFlowControllers.length;
        i++
      ) {
        _cashFlowControllers[i].text = currentValues[i];
      }
    });
  }

  void _calculate() {
    // Ocultar el teclado
    FocusScope.of(context).unfocus();

    // Validar que todos los campos tengan valores
    for (int i = 0; i < _cashFlowControllers.length; i++) {
      if (_cashFlowControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor completa todos los flujos de caja'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      // Convertir los flujos de caja a números
      List<double> cashFlows = [];
      for (var controller in _cashFlowControllers) {
        cashFlows.add(double.parse(controller.text.replaceAll(',', '.')));
      }

      // Calcular la TIR
      double? tir = _calculateIRR(cashFlows);

      setState(() {
        _tirResult = tir;
        _hasCalculated = true;
        _errorMessage = null;
      });

      // Desplazar hacia abajo para mostrar los resultados
      _scrollToResults();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error en el cálculo: $e';
        _hasCalculated = true;
        _tirResult = null;
      });

      // Desplazar hacia abajo para mostrar el error
      _scrollToResults();
    }
  }

  // Algoritmo para calcular la TIR
  double? _calculateIRR(List<double> cashFlows) {
    // Verificar que hay al menos un flujo positivo y uno negativo
    bool hasPositive = false;
    bool hasNegative = false;

    for (double flow in cashFlows) {
      if (flow > 0) hasPositive = true;
      if (flow < 0) hasNegative = true;
    }

    if (!hasPositive || !hasNegative) {
      throw Exception(
        'Para calcular la TIR, debe haber al menos un flujo positivo y uno negativo',
      );
    }

    // Implementación del método de Newton-Raphson para encontrar la TIR
    double guess = 0.1; // Valor inicial
    double precision = 0.0000001; // Precisión deseada
    int maxIterations = 100; // Máximo número de iteraciones

    for (int i = 0; i < maxIterations; i++) {
      double f = _npv(cashFlows, guess);
      double fPrime = _npvDerivative(cashFlows, guess);

      // Evitar división por cero
      if (fPrime.abs() < precision) {
        break;
      }

      double newGuess = guess - f / fPrime;

      // Verificar convergencia
      if ((newGuess - guess).abs() < precision) {
        return newGuess;
      }

      guess = newGuess;
    }

    // Si no converge, intentar con otro método
    return _calculateIRRBisection(cashFlows);
  }

  // Método de bisección como respaldo
  double? _calculateIRRBisection(List<double> cashFlows) {
    double lowerBound = -0.99; // Límite inferior
    double upperBound = 10.0; // Límite superior
    double precision = 0.0000001; // Precisión deseada
    int maxIterations = 1000; // Máximo número de iteraciones

    double fLower = _npv(cashFlows, lowerBound);
    double fUpper = _npv(cashFlows, upperBound);

    // Verificar que hay un cambio de signo
    if (fLower * fUpper >= 0) {
      throw Exception(
        'No se puede calcular la TIR con los flujos de caja proporcionados',
      );
    }

    for (int i = 0; i < maxIterations; i++) {
      double mid = (lowerBound + upperBound) / 2;
      double fMid = _npv(cashFlows, mid);

      // Verificar convergencia
      if (fMid.abs() < precision || (upperBound - lowerBound) / 2 < precision) {
        return mid;
      }

      // Actualizar límites
      if (fMid * fLower < 0) {
        upperBound = mid;
        fUpper = fMid;
      } else {
        lowerBound = mid;
        fLower = fMid;
      }
    }

    throw Exception(
      'No se pudo calcular la TIR después de $maxIterations iteraciones',
    );
  }

  // Calcular el Valor Presente Neto (VPN) para una tasa dada
  double _npv(List<double> cashFlows, double rate) {
    double npv = 0;
    for (int i = 0; i < cashFlows.length; i++) {
      npv += cashFlows[i] / pow(1 + rate, i);
    }
    return npv;
  }

  // Calcular la derivada del VPN para el método de Newton-Raphson
  double _npvDerivative(List<double> cashFlows, double rate) {
    double derivative = 0;
    for (int i = 1; i < cashFlows.length; i++) {
      derivative -= i * cashFlows[i] / pow(1 + rate, i + 1);
    }
    return derivative;
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
      for (var controller in _cashFlowControllers) {
        controller.clear();
      }
      _tirResult = null;
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
          'Tasa Interna de Retorno (TIR)',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
                          '¿Qué es la TIR?',
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
                      'La Tasa Interna de Retorno (TIR) es la tasa de interés o rentabilidad que ofrece una inversión. Es decir, es el porcentaje de beneficio o pérdida que tendrá una inversión para las cantidades que no se han retirado del proyecto.',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'La TIR es la tasa de descuento que hace que el Valor Presente Neto (VPN) de un proyecto sea igual a cero. Se utiliza para evaluar la rentabilidad de un proyecto: a mayor TIR, mayor rentabilidad.',
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
                              'VPN = Σ Ft / (1 + TIR)^t',
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
                              _buildFormulaItem('Ft', 'Flujo en t'),
                              _buildFormulaItem('t', 'Período'),
                              _buildFormulaItem('TIR', 'Tasa'),
                              _buildFormulaItem('Σ', 'Sumatoria'),
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
                              'La TIR es la tasa que hace que el VPN sea igual a cero.',
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

                    // Selector de número de períodos
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Número de Períodos',
                          style: TextStyle(
                            color: const Color(0xFF293431),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (_numberOfPeriods > 1) {
                                          _updateNumberOfPeriods(
                                            _numberOfPeriods - 1,
                                          );
                                        }
                                      },
                                      icon: Icon(
                                        Icons.remove_circle_outline,
                                        color: _primaryColor,
                                      ),
                                    ),
                                    Text(
                                      '$_numberOfPeriods',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF293431),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (_numberOfPeriods < 20) {
                                          _updateNumberOfPeriods(
                                            _numberOfPeriods + 1,
                                          );
                                        }
                                      },
                                      icon: Icon(
                                        Icons.add_circle_outline,
                                        color: _primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Máximo 20 períodos',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Flujos de caja
                    Text(
                      'Flujos de Caja',
                      style: TextStyle(
                        color: const Color(0xFF293431),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Inversión inicial (t=0)
                    _buildInputField(
                      controller: _cashFlowControllers[0],
                      label: 'Inversión Inicial (t=0)',
                      hint: 'Ej: -10000 (negativo)',
                      prefixIcon: Icons.arrow_downward,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      color: _primaryColor,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'La inversión inicial generalmente es un valor negativo',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Flujos de caja para cada período
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _numberOfPeriods,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: _buildInputField(
                            controller: _cashFlowControllers[index + 1],
                            label: 'Flujo de Caja Período ${index + 1}',
                            hint: 'Ej: 2500',
                            prefixIcon: Icons.arrow_upward,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            color: _primaryColor,
                          ),
                        );
                      },
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
                        // Resultado de la TIR
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
                                    Icons.trending_up,
                                    color: _primaryColor,
                                    size: 28,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Tasa Interna de Retorno (TIR)',
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
                                '${(_tirResult! * 100).toStringAsFixed(2)}%',
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

                        // Interpretación del resultado
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Interpretación:',
                                style: TextStyle(
                                  color: const Color(0xFF293431),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildInterpretationItem(
                                'Si TIR > Tasa de Descuento: El proyecto es rentable',
                                Icons.thumb_up,
                                Colors.green,
                              ),
                              const SizedBox(height: 8),
                              _buildInterpretationItem(
                                'Si TIR = Tasa de Descuento: El proyecto es indiferente',
                                Icons.thumbs_up_down,
                                Colors.amber,
                              ),
                              const SizedBox(height: 8),
                              _buildInterpretationItem(
                                'Si TIR < Tasa de Descuento: El proyecto no es rentable',
                                Icons.thumb_down,
                                Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Resumen de flujos de caja
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
                              'Resumen de Flujos de Caja:',
                              style: TextStyle(
                                color: const Color(0xFF293431),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _cashFlowControllers.length,
                              itemBuilder: (context, index) {
                                if (_cashFlowControllers[index].text.isEmpty) {
                                  return SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        index == 0
                                            ? 'Inversión Inicial (t=0):'
                                            : 'Período $index:',
                                        style: TextStyle(
                                          color: const Color(0xFF293431),
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '\$${_formatNumber(double.parse(_cashFlowControllers[index].text.replaceAll(',', '.')))}',
                                        style: TextStyle(
                                          color: const Color(0xFF293431),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
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
                                'La TIR es una herramienta clave para evaluar y comparar proyectos de inversión. A mayor TIR, mayor rentabilidad potencial.',
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
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
            ],
          ),
        ),
      ],
    );
  }

  // Widget para los elementos de interpretación
  Widget _buildInterpretationItem(String text, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: const Color(0xFF293431), fontSize: 14),
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
