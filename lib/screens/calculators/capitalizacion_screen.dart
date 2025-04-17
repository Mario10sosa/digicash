import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CapitalizacionScreen extends StatefulWidget {
  const CapitalizacionScreen({super.key});

  @override
  State<CapitalizacionScreen> createState() => _CapitalizacionScreenState();
}

class _CapitalizacionScreenState extends State<CapitalizacionScreen> {
  // Color principal cambiado a cyan
  final Color _primaryColor = const Color(0xFF00BCD4);

  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _finalAmountController = TextEditingController();
  final _deferralPeriodController =
      TextEditingController(); // Para capitalización diferida

  // Controladores para cada unidad de tiempo
  final _yearsController = TextEditingController();
  final _monthsController = TextEditingController();
  final _daysController = TextEditingController();

  // Resultados
  double _calculatedValue = 0.0;
  double _interestEarned = 0.0;
  bool _hasCalculated = false;

  // Controlador para el ScrollView
  final ScrollController _scrollController = ScrollController();

  // Modo de tiempo seleccionado (simple o avanzado)
  bool _advancedTimeMode = false;

  // Variable a calcular
  String _variableToCalculate =
      'finalAmount'; // 'finalAmount', 'principal', 'rate', 'time'

  // Tipos de capitalización
  final List<Map<String, dynamic>> _capitalizationTypes = [
    {
      'label': 'Capitalización Simple',
      'value': 'simple',
      'formula': 'M = C(1 + i×t)',
      'description':
          'El interés se calcula siempre sobre el capital inicial, sin reinversión.',
    },
    {
      'label': 'Capitalización Compuesta',
      'value': 'compound',
      'formula': 'M = C(1 + i/n)^(n×t)',
      'description':
          'El interés generado en cada período se suma al capital para el siguiente período.',
    },
    {
      'label': 'Capitalización Continua',
      'value': 'continuous',
      'formula': 'M = C×e^(i×t)',
      'description':
          'La capitalización ocurre de manera continua, usando la función exponencial.',
    },
    {
      'label': 'Capitalización Periódica',
      'value': 'periodic',
      'formula': 'M = C(1 + i)^t',
      'description':
          'Similar a la compuesta, pero con períodos específicos de capitalización.',
    },
    {
      'label': 'Capitalización Anticipada',
      'value': 'anticipated',
      'formula': 'M = C/(1 - i×t)',
      'description': 'El interés se paga al inicio del período, no al final.',
    },
    {
      'label': 'Capitalización Diferida',
      'value': 'deferred',
      'formula': 'M = C(1 + i)^(t-d)',
      'description':
          'La capitalización comienza después de un período de diferimiento (d).',
    },
  ];

  // Tipo de capitalización seleccionado (por defecto: compuesta)
  Map<String, dynamic> _selectedCapitalizationType = {
    'label': 'Capitalización Compuesta',
    'value': 'compound',
    'formula': 'M = C(1 + i/n)^(n×t)',
    'description':
        'El interés generado en cada período se suma al capital para el siguiente período.',
  };

  // Opciones para unidades de tiempo en modo simple
  final List<Map<String, dynamic>> _timeUnits = [
    {'label': 'Años', 'value': 'years', 'factor': 1.0},
    {'label': 'Semestres', 'value': 'semesters', 'factor': 0.5},
    {'label': 'Trimestres', 'value': 'quarters', 'factor': 0.25},
    {'label': 'Meses', 'value': 'months', 'factor': 1 / 12},
    {'label': 'Días', 'value': 'days', 'factor': 1 / 365},
  ];

  // Unidad de tiempo seleccionada para modo simple (por defecto: años)
  Map<String, dynamic> _selectedTimeUnit = {
    'label': 'Años',
    'value': 'years',
    'factor': 1.0,
  };

  // Frecuencia de capitalización
  final List<Map<String, dynamic>> _compoundingFrequencies = [
    {'label': 'Anual', 'value': 'annual', 'times': 1},
    {'label': 'Semestral', 'value': 'semiannual', 'times': 2},
    {'label': 'Trimestral', 'value': 'quarterly', 'times': 4},
    {'label': 'Mensual', 'value': 'monthly', 'times': 12},
    {'label': 'Diaria', 'value': 'daily', 'times': 365},
  ];

  // Frecuencia de capitalización seleccionada (por defecto: anual)
  Map<String, dynamic> _selectedFrequency = {
    'label': 'Anual',
    'value': 'annual',
    'times': 1,
  };

  // Controlador para tiempo en modo simple
  final _simpleTimeController = TextEditingController();

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _finalAmountController.dispose();
    _deferralPeriodController.dispose();
    _simpleTimeController.dispose();
    _yearsController.dispose();
    _monthsController.dispose();
    _daysController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Calcular el tiempo total en años
  double _calculateTimeInYears() {
    if (_advancedTimeMode) {
      double years =
          _yearsController.text.isEmpty
              ? 0
              : double.parse(_yearsController.text.replaceAll(',', '.'));
      double months =
          _monthsController.text.isEmpty
              ? 0
              : double.parse(_monthsController.text.replaceAll(',', '.'));
      double days =
          _daysController.text.isEmpty
              ? 0
              : double.parse(_daysController.text.replaceAll(',', '.'));

      return years + (months / 12) + (days / 365);
    } else {
      if (_simpleTimeController.text.isEmpty) return 0;
      double timeValue = double.parse(
        _simpleTimeController.text.replaceAll(',', '.'),
      );
      return timeValue * _selectedTimeUnit['factor'];
    }
  }

  void _calculate() {
    // Ocultar el teclado
    FocusScope.of(context).unfocus();

    try {
      switch (_variableToCalculate) {
        case 'finalAmount':
          _calculateFinalAmount();
          break;
        case 'principal':
          _calculatePrincipal();
          break;
        case 'rate':
          _calculateRate();
          break;
        case 'time':
          _calculateTime();
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en el cálculo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _calculateFinalAmount() {
    // Validar que los campos principales tengan valores
    if (_principalController.text.isEmpty || _rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de capital y tasa de interés',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar que haya al menos un valor de tiempo
    if (_advancedTimeMode) {
      if (_yearsController.text.isEmpty &&
          _monthsController.text.isEmpty &&
          _daysController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa al menos un valor de tiempo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      if (_simpleTimeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa el valor de tiempo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Validar campo de período de diferimiento para capitalización diferida
    if (_selectedCapitalizationType['value'] == 'deferred' &&
        _deferralPeriodController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor ingresa el período de diferimiento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convertir valores a números
    final principal = double.parse(
      _principalController.text.replaceAll(',', '.'),
    );
    final rate =
        double.parse(_rateController.text.replaceAll(',', '.')) /
        100; // Convertir a decimal

    // Obtener tiempo en años
    final timeInYears = _calculateTimeInYears();

    // Calcular según el tipo de capitalización seleccionado
    double finalAmount = 0.0;

    switch (_selectedCapitalizationType['value']) {
      case 'simple':
        // Capitalización Simple: M = C(1 + i×t)
        finalAmount = principal * (1 + rate * timeInYears);
        break;

      case 'compound':
        // Capitalización Compuesta: M = C(1 + i/n)^(n×t)
        final compoundingFrequency = _selectedFrequency['times'];
        finalAmount =
            principal *
            pow(
              1 + (rate / compoundingFrequency),
              compoundingFrequency * timeInYears,
            );
        break;

      case 'continuous':
        // Capitalización Continua: M = C×e^(i×t)
        finalAmount = principal * exp(rate * timeInYears);
        break;

      case 'periodic':
        // Capitalización Periódica: M = C(1 + i)^t
        finalAmount = principal * pow(1 + rate, timeInYears);
        break;

      case 'anticipated':
        // Capitalización Anticipada: M = C/(1 - i×t)
        if (rate * timeInYears >= 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: Para capitalización anticipada, i×t debe ser menor que 1',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        finalAmount = principal / (1 - rate * timeInYears);
        break;

      case 'deferred':
        // Capitalización Diferida: M = C(1 + i)^(t-d)
        final deferralPeriod = double.parse(
          _deferralPeriodController.text.replaceAll(',', '.'),
        );
        if (deferralPeriod >= timeInYears) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: El período de diferimiento debe ser menor que el tiempo total',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        finalAmount = principal * pow(1 + rate, timeInYears - deferralPeriod);
        break;
    }

    final interestEarned = finalAmount - principal;

    setState(() {
      _calculatedValue = finalAmount;
      _interestEarned = interestEarned;
      _hasCalculated = true;
    });

    // Desplazar hacia abajo para mostrar los resultados
    _scrollToResults();
  }

  void _calculatePrincipal() {
    // Validar que los campos necesarios tengan valores
    if (_finalAmountController.text.isEmpty || _rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor completa los campos de monto final y tasa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar que haya al menos un valor de tiempo
    if (_advancedTimeMode) {
      if (_yearsController.text.isEmpty &&
          _monthsController.text.isEmpty &&
          _daysController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa al menos un valor de tiempo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      if (_simpleTimeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa el valor de tiempo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Validar campo de período de diferimiento para capitalización diferida
    if (_selectedCapitalizationType['value'] == 'deferred' &&
        _deferralPeriodController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor ingresa el período de diferimiento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convertir valores a números
    final finalAmount = double.parse(
      _finalAmountController.text.replaceAll(',', '.'),
    );
    final rate =
        double.parse(_rateController.text.replaceAll(',', '.')) /
        100; // Convertir a decimal

    // Obtener tiempo en años
    final timeInYears = _calculateTimeInYears();

    // Calcular según el tipo de capitalización seleccionado
    double principal = 0.0;

    switch (_selectedCapitalizationType['value']) {
      case 'simple':
        // Capitalización Simple: C = M/(1 + i×t)
        principal = finalAmount / (1 + rate * timeInYears);
        break;

      case 'compound':
        // Capitalización Compuesta: C = M/(1 + i/n)^(n×t)
        final compoundingFrequency = _selectedFrequency['times'];
        principal =
            finalAmount /
            pow(
              1 + (rate / compoundingFrequency),
              compoundingFrequency * timeInYears,
            );
        break;

      case 'continuous':
        // Capitalización Continua: C = M/e^(i×t)
        principal = finalAmount / exp(rate * timeInYears);
        break;

      case 'periodic':
        // Capitalización Periódica: C = M/(1 + i)^t
        principal = finalAmount / pow(1 + rate, timeInYears);
        break;

      case 'anticipated':
        // Capitalización Anticipada: C = M(1 - i×t)
        if (rate * timeInYears >= 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: Para capitalización anticipada, i×t debe ser menor que 1',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        principal = finalAmount * (1 - rate * timeInYears);
        break;

      case 'deferred':
        // Capitalización Diferida: C = M/(1 + i)^(t-d)
        final deferralPeriod = double.parse(
          _deferralPeriodController.text.replaceAll(',', '.'),
        );
        if (deferralPeriod >= timeInYears) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: El período de diferimiento debe ser menor que el tiempo total',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        principal = finalAmount / pow(1 + rate, timeInYears - deferralPeriod);
        break;
    }

    final interestEarned = finalAmount - principal;

    setState(() {
      _calculatedValue = principal;
      _interestEarned = interestEarned;
      _hasCalculated = true;
    });

    // Desplazar hacia abajo para mostrar los resultados
    _scrollToResults();
  }

  void _calculateRate() {
    // Validar que los campos necesarios tengan valores
    if (_principalController.text.isEmpty ||
        _finalAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de capital y monto final',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar que haya al menos un valor de tiempo
    if (_advancedTimeMode) {
      if (_yearsController.text.isEmpty &&
          _monthsController.text.isEmpty &&
          _daysController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa al menos un valor de tiempo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      if (_simpleTimeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingresa el valor de tiempo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Validar campo de período de diferimiento para capitalización diferida
    if (_selectedCapitalizationType['value'] == 'deferred' &&
        _deferralPeriodController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor ingresa el período de diferimiento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convertir valores a números
    final principal = double.parse(
      _principalController.text.replaceAll(',', '.'),
    );
    final finalAmount = double.parse(
      _finalAmountController.text.replaceAll(',', '.'),
    );

    // Obtener tiempo en años
    final timeInYears = _calculateTimeInYears();

    // Calcular según el tipo de capitalización seleccionado
    double rate = 0.0;

    switch (_selectedCapitalizationType['value']) {
      case 'simple':
        // Capitalización Simple: i = (M/C - 1)/t
        rate = (finalAmount / principal - 1) / timeInYears;
        break;

      case 'compound':
        // Capitalización Compuesta: i = n * [(M/C)^(1/(n*t)) - 1]
        final compoundingFrequency = _selectedFrequency['times'];
        rate =
            compoundingFrequency *
            (pow(
                  finalAmount / principal,
                  1 / (compoundingFrequency * timeInYears),
                ) -
                1);
        break;

      case 'continuous':
        // Capitalización Continua: i = ln(M/C)/t
        rate = log(finalAmount / principal) / timeInYears;
        break;

      case 'periodic':
        // Capitalización Periódica: i = (M/C)^(1/t) - 1
        rate = pow(finalAmount / principal, 1 / timeInYears) - 1;
        break;

      case 'anticipated':
        // Capitalización Anticipada: i = (1 - C/M)/t
        rate = (1 - principal / finalAmount) / timeInYears;
        break;

      case 'deferred':
        // Capitalización Diferida: i = (M/C)^(1/(t-d)) - 1
        final deferralPeriod = double.parse(
          _deferralPeriodController.text.replaceAll(',', '.'),
        );
        if (deferralPeriod >= timeInYears) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: El período de diferimiento debe ser menor que el tiempo total',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        rate =
            pow(finalAmount / principal, 1 / (timeInYears - deferralPeriod)) -
            1;
        break;
    }

    final interestEarned = finalAmount - principal;

    setState(() {
      _calculatedValue = rate * 100; // Convertir a porcentaje
      _interestEarned = interestEarned;
      _hasCalculated = true;
    });

    // Desplazar hacia abajo para mostrar los resultados
    _scrollToResults();
  }

  void _calculateTime() {
    // Validar que los campos necesarios tengan valores
    if (_principalController.text.isEmpty ||
        _rateController.text.isEmpty ||
        _finalAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de capital, tasa y monto final',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar campo de período de diferimiento para capitalización diferida
    if (_selectedCapitalizationType['value'] == 'deferred' &&
        _deferralPeriodController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor ingresa el período de diferimiento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convertir valores a números
    final principal = double.parse(
      _principalController.text.replaceAll(',', '.'),
    );
    final rate =
        double.parse(_rateController.text.replaceAll(',', '.')) /
        100; // Convertir a decimal
    final finalAmount = double.parse(
      _finalAmountController.text.replaceAll(',', '.'),
    );

    // Calcular según el tipo de capitalización seleccionado
    double timeInYears = 0.0;

    switch (_selectedCapitalizationType['value']) {
      case 'simple':
        // Capitalización Simple: t = (M/C - 1)/i
        timeInYears = (finalAmount / principal - 1) / rate;
        break;

      case 'compound':
        // Capitalización Compuesta: t = ln(M/C)/(n * ln(1 + i/n))
        final compoundingFrequency = _selectedFrequency['times'];
        timeInYears =
            log(finalAmount / principal) /
            (compoundingFrequency * log(1 + rate / compoundingFrequency));
        break;

      case 'continuous':
        // Capitalización Continua: t = ln(M/C)/i
        timeInYears = log(finalAmount / principal) / rate;
        break;

      case 'periodic':
        // Capitalización Periódica: t = ln(M/C)/ln(1 + i)
        timeInYears = log(finalAmount / principal) / log(1 + rate);
        break;

      case 'anticipated':
        // Capitalización Anticipada: t = (1 - C/M)/i
        timeInYears = (1 - principal / finalAmount) / rate;
        break;

      case 'deferred':
        // Capitalización Diferida: t = ln(M/C)/ln(1 + i) + d
        final deferralPeriod = double.parse(
          _deferralPeriodController.text.replaceAll(',', '.'),
        );
        timeInYears =
            log(finalAmount / principal) / log(1 + rate) + deferralPeriod;
        break;
    }

    final interestEarned = finalAmount - principal;

    setState(() {
      _calculatedValue = timeInYears;
      _interestEarned = interestEarned;
      _hasCalculated = true;
    });

    // Desplazar hacia abajo para mostrar los resultados
    _scrollToResults();
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
      _principalController.clear();
      _rateController.clear();
      _finalAmountController.clear();
      _deferralPeriodController.clear();
      _simpleTimeController.clear();
      _yearsController.clear();
      _monthsController.clear();
      _daysController.clear();
      _calculatedValue = 0.0;
      _interestEarned = 0.0;
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

  // Generar descripción del tiempo para mostrar en resultados
  String _getTimeDescription() {
    if (_advancedTimeMode) {
      List<String> parts = [];

      if (_yearsController.text.isNotEmpty &&
          double.parse(_yearsController.text.replaceAll(',', '.')) > 0) {
        double years = double.parse(_yearsController.text.replaceAll(',', '.'));
        parts.add(
          '${years.toStringAsFixed(years.truncateToDouble() == years ? 0 : 2)} año${years == 1 ? '' : 's'}',
        );
      }

      if (_monthsController.text.isNotEmpty &&
          double.parse(_monthsController.text.replaceAll(',', '.')) > 0) {
        double months = double.parse(
          _monthsController.text.replaceAll(',', '.'),
        );
        parts.add(
          '${months.toStringAsFixed(months.truncateToDouble() == months ? 0 : 2)} mes${months == 1 ? '' : 'es'}',
        );
      }

      if (_daysController.text.isNotEmpty &&
          double.parse(_daysController.text.replaceAll(',', '.')) > 0) {
        double days = double.parse(_daysController.text.replaceAll(',', '.'));
        parts.add(
          '${days.toStringAsFixed(days.truncateToDouble() == days ? 0 : 2)} día${days == 1 ? '' : 's'}',
        );
      }

      return parts.join(', ');
    } else {
      return '${_simpleTimeController.text.replaceAll(',', '.')} ${_selectedTimeUnit['label'].toLowerCase()}';
    }
  }

  // Obtener el título del resultado según la variable calculada
  String _getResultTitle() {
    switch (_variableToCalculate) {
      case 'finalAmount':
        return 'Monto final:';
      case 'principal':
        return 'Capital inicial:';
      case 'rate':
        return 'Tasa de interés anual:';
      case 'time':
        return 'Tiempo en años:';
      default:
        return '';
    }
  }

  // Obtener el valor formateado del resultado
  String _getFormattedResult() {
    switch (_variableToCalculate) {
      case 'finalAmount':
      case 'principal':
        return '\$${_formatNumber(_calculatedValue)}';
      case 'rate':
        return '${_formatNumber(_calculatedValue)}%';
      case 'time':
        return '${_formatNumber(_calculatedValue)} años';
      default:
        return '';
    }
  }

  // Obtener el ícono para el resultado
  IconData _getResultIcon() {
    switch (_variableToCalculate) {
      case 'finalAmount':
        return Icons.account_balance_wallet;
      case 'principal':
        return Icons.attach_money;
      case 'rate':
        return Icons.percent;
      case 'time':
        return Icons.access_time;
      default:
        return Icons.calculate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Capitalización',
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

              // Tarjeta de fórmula
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
                          '¿Qué es la Capitalización?',
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
                      'La capitalización es un proceso financiero donde los intereses generados en cada período se suman al capital para el siguiente período. Esto permite que el capital crezca de manera exponencial, ya que los intereses generan nuevos intereses en los períodos subsiguientes.',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Selector de tipo de capitalización
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipo de Capitalización',
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
                              value: _selectedCapitalizationType['value'],
                              hint: Text('Seleccione tipo de capitalización'),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCapitalizationType =
                                      _capitalizationTypes.firstWhere(
                                        (type) => type['value'] == value,
                                      );
                                });
                              },
                              icon: Icon(
                                Icons.arrow_drop_down_circle_outlined,
                                color: _primaryColor,
                              ),
                              items:
                                  _capitalizationTypes.map((type) {
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

                    // Descripción del tipo de capitalización seleccionado
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
                              _selectedCapitalizationType['description'],
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
                              _selectedCapitalizationType['formula'],
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
                              _buildFormulaItem('M', 'Monto final'),
                              _buildFormulaItem('C', 'Capital inicial'),
                              _buildFormulaItem('i', 'Tasa anual'),
                              if (_selectedCapitalizationType['value'] ==
                                  'compound')
                                _buildFormulaItem('n', 'Frecuencia'),
                              if (_selectedCapitalizationType['value'] ==
                                  'deferred')
                                _buildFormulaItem('d', 'Diferimiento'),
                              _buildFormulaItem('t', 'Tiempo (años)'),
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
                              'El interés generado será: M - C',
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

                    // Selector de variable a calcular
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Qué deseas calcular?',
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
                              value: _variableToCalculate,
                              hint: Text('Seleccione una opción'),
                              onChanged: (value) {
                                setState(() {
                                  _variableToCalculate = value!;
                                });
                              },
                              icon: Icon(
                                Icons.arrow_drop_down_circle_outlined,
                                color: _primaryColor,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'finalAmount',
                                  child: Text(
                                    'Monto final (M)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'principal',
                                  child: Text(
                                    'Capital inicial (C)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'rate',
                                  child: Text(
                                    'Tasa de interés (i)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'time',
                                  child: Text(
                                    'Tiempo (t)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Frecuencia de capitalización (solo para capitalización compuesta)
                    if (_selectedCapitalizationType['value'] == 'compound') ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Frecuencia de capitalización',
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
                                value: _selectedFrequency['value'],
                                hint: Text('Seleccione frecuencia'),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedFrequency = _compoundingFrequencies
                                        .firstWhere(
                                          (freq) => freq['value'] == value,
                                        );
                                  });
                                },
                                icon: Icon(
                                  Icons.arrow_drop_down_circle_outlined,
                                  color: _primaryColor,
                                ),
                                items:
                                    _compoundingFrequencies.map((freq) {
                                      return DropdownMenuItem<String>(
                                        value: freq['value'],
                                        child: Text(
                                          freq['label'],
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
                      const SizedBox(height: 20),
                    ],

                    // Período de diferimiento (solo para capitalización diferida)
                    if (_selectedCapitalizationType['value'] == 'deferred') ...[
                      _buildInputField(
                        controller: _deferralPeriodController,
                        label: 'Período de diferimiento (d) en años',
                        hint: 'Ej: 2',
                        prefixIcon: Icons.timelapse,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        color: _primaryColor,
                      ),
                      const SizedBox(height: 15),
                    ],

                    // Campo de capital inicial (excepto cuando se calcula P)
                    if (_variableToCalculate != 'principal') ...[
                      _buildInputField(
                        controller: _principalController,
                        label: 'Capital inicial (C)',
                        hint: 'Ej: 9000000',
                        prefixIcon: Icons.attach_money,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        color: _primaryColor,
                      ),
                      const SizedBox(height: 15),
                    ],

                    // Campo de tasa de interés (excepto cuando se calcula r)
                    if (_variableToCalculate != 'rate') ...[
                      _buildInputField(
                        controller: _rateController,
                        label: 'Tasa de interés anual (i) %',
                        hint: 'Ej: 5',
                        prefixIcon: Icons.percent,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        color: _primaryColor,
                      ),
                      const SizedBox(height: 15),
                    ],

                    // Campo de monto final (excepto cuando se calcula A)
                    if (_variableToCalculate != 'finalAmount') ...[
                      _buildInputField(
                        controller: _finalAmountController,
                        label: 'Monto final (M)',
                        hint: 'Ej: 10000000',
                        prefixIcon: Icons.account_balance_wallet,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        color: _primaryColor,
                      ),
                      const SizedBox(height: 15),
                    ],

                    // Selector de modo de tiempo (excepto cuando se calcula t)
                    if (_variableToCalculate != 'time') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiempo (t)',
                            style: TextStyle(
                              color: const Color(0xFF293431),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Avanzado',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                              Switch(
                                value: _advancedTimeMode,
                                onChanged: (value) {
                                  setState(() {
                                    _advancedTimeMode = value;
                                  });
                                },
                                activeColor: _primaryColor,
                                activeTrackColor: Colors.green.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Modo de tiempo simple
                      if (!_advancedTimeMode) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Campo de entrada para el valor del tiempo
                            Expanded(
                              flex: 3,
                              child: Container(
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
                                  controller: _simpleTimeController,
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Ej: 2',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                    prefixIcon: Icon(
                                      Icons.access_time,
                                      color: _primaryColor,
                                    ),
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
                                      borderSide: BorderSide(
                                        color: _primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 15,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: const Color(0xFF151616),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.,]'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Selector de unidad de tiempo
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 56, // Misma altura que el TextField
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey[300]!),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedTimeUnit['value'],
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: _primaryColor,
                                    ),
                                    isExpanded: true,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    items:
                                        _timeUnits.map((unit) {
                                          return DropdownMenuItem<String>(
                                            value: unit['value'],
                                            child: Text(
                                              unit['label'],
                                              style: TextStyle(
                                                color: const Color(0xFF151616),
                                                fontSize: 16,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedTimeUnit = _timeUnits
                                            .firstWhere(
                                              (unit) =>
                                                  unit['value'] == newValue,
                                            );
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Modo de tiempo avanzado
                      if (_advancedTimeMode) ...[
                        Container(
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
                              // Años
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Años:',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.03,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: _yearsController,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: InputDecoration(
                                          hintText: 'Ej: 2',
                                          hintStyle: TextStyle(
                                            color: Colors.grey[400],
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color: _primaryColor,
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 15,
                                                vertical: 10,
                                              ),
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color(0xFF151616),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9.,]'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Meses
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Meses:',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.03,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: _monthsController,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: InputDecoration(
                                          hintText: 'Ej: 6',
                                          hintStyle: TextStyle(
                                            color: Colors.grey[400],
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color: _primaryColor,
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 15,
                                                vertical: 10,
                                              ),
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color(0xFF151616),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9.,]'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Días
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Días:',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.03,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: _daysController,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: InputDecoration(
                                          hintText: 'Ej: 15',
                                          hintStyle: TextStyle(
                                            color: Colors.grey[400],
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color: _primaryColor,
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 15,
                                                vertical: 10,
                                              ),
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color(0xFF151616),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9.,]'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Nota informativa
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: _primaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Puedes combinar años, meses y días para un cálculo más preciso.',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],

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

                      // Valor calculado
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: _buildResultItem(
                          label: _getResultTitle(),
                          value: _getFormattedResult(),
                          icon: _getResultIcon(),
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Interés generado
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: _buildResultItem(
                          label: 'Interés generado:',
                          value: '\$${_formatNumber(_interestEarned)}',
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Detalles del cálculo
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: _primaryColor,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Detalles del cálculo:',
                                  style: TextStyle(
                                    color: const Color(0xFF293431),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Mostrar tipo de capitalización
                                  Text(
                                    'Tipo de capitalización: ${_selectedCapitalizationType['label']}',
                                    style: TextStyle(
                                      color: const Color(0xFF293431),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Divider(height: 20),

                                  // Mostrar capital inicial (si no es lo que se calculó)
                                  if (_variableToCalculate != 'principal') ...[
                                    Text(
                                      'Capital inicial: \$${_formatNumber(double.parse(_principalController.text.replaceAll(',', '.')))}',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Divider(height: 20),
                                  ],

                                  // Mostrar tasa de interés (si no es lo que se calculó)
                                  if (_variableToCalculate != 'rate') ...[
                                    Text(
                                      'Tasa de interés anual: ${_rateController.text.replaceAll(',', '.')}%',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Divider(height: 20),
                                  ],

                                  // Mostrar monto final (si no es lo que se calculó)
                                  if (_variableToCalculate !=
                                      'finalAmount') ...[
                                    Text(
                                      'Monto final: \$${_formatNumber(double.parse(_finalAmountController.text.replaceAll(',', '.')))}',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Divider(height: 20),
                                  ],

                                  // Mostrar tiempo (si no es lo que se calculó)
                                  if (_variableToCalculate != 'time') ...[
                                    Text(
                                      'Tiempo: ${_getTimeDescription()}',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Tiempo en años (para el cálculo): ${_calculateTimeInYears().toStringAsFixed(4)}',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Divider(height: 20),
                                  ],

                                  // Mostrar frecuencia de capitalización (solo para capitalización compuesta)
                                  if (_selectedCapitalizationType['value'] ==
                                      'compound') ...[
                                    Text(
                                      'Frecuencia de capitalización: ${_selectedFrequency['label']} (${_selectedFrequency['times']} veces al año)',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Divider(height: 20),
                                  ],

                                  // Mostrar período de diferimiento (solo para capitalización diferida)
                                  if (_selectedCapitalizationType['value'] ==
                                          'deferred' &&
                                      _deferralPeriodController
                                          .text
                                          .isNotEmpty) ...[
                                    Text(
                                      'Período de diferimiento: ${_deferralPeriodController.text.replaceAll(',', '.')} años',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
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
                                'La capitalización genera más rendimiento que el interés simple porque los intereses se reinvierten y generan más intereses en cada período.',
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

  // Widget para los elementos de resultado
  Widget _buildResultItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              Text(
                value,
                style: TextStyle(
                  color: const Color(0xFF151616),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
