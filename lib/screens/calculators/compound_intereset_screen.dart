import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class CompoundInterestScreen extends StatefulWidget {
  const CompoundInterestScreen({super.key});

  @override
  State<CompoundInterestScreen> createState() => _CompoundInterestScreenState();
}

class _CompoundInterestScreenState extends State<CompoundInterestScreen> {
  final _capitalController = TextEditingController(); // Capital (C)
  final _tasaController = TextEditingController(); // Tasa de interés (i)
  final _interesController = TextEditingController(); // Interés compuesto (IC)
  final _montoController = TextEditingController(); // Monto compuesto (MC)

  // Controladores para cada unidad de tiempo
  final _yearsController = TextEditingController();
  final _monthsController = TextEditingController();
  final _daysController = TextEditingController();

  // Resultados
  double _calculatedValue = 0.0;
  double _totalAmount = 0.0;
  bool _hasCalculated = false;

  // Controlador para el ScrollView
  final ScrollController _scrollController = ScrollController();

  // Modo de tiempo seleccionado (simple o avanzado)
  bool _advancedTimeMode = false;

  // Variable a calcular
  String _variableToCalculate =
      'interes'; // 'interes', 'capital', 'tasa', 'tiempo', 'monto'

  // Opciones para variable a calcular
  final List<Map<String, dynamic>> _calculationOptions = [
    {'label': 'Interés compuesto (IC)', 'value': 'interes'},
    {'label': 'Capital inicial (C)', 'value': 'capital'},
    {'label': 'Tasa de interés (i)', 'value': 'tasa'},
    {'label': 'Tiempo (t)', 'value': 'tiempo'},
    {'label': 'Monto compuesto (MC)', 'value': 'monto'},
  ];

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

  // Opciones para frecuencia de capitalización
  final List<Map<String, dynamic>> _compoundingFrequencies = [
    {'label': 'Anual', 'value': 'annual', 'periods': 1},
    {'label': 'Semestral', 'value': 'semiannual', 'periods': 2},
    {'label': 'Trimestral', 'value': 'quarterly', 'periods': 4},
    {'label': 'Mensual', 'value': 'monthly', 'periods': 12},
    {'label': 'Diaria', 'value': 'daily', 'periods': 365},
  ];

  // Frecuencia de capitalización seleccionada (por defecto: anual)
  Map<String, dynamic> _selectedFrequency = {
    'label': 'Anual',
    'value': 'annual',
    'periods': 1,
  };

  // Opciones para formato de tasa de interés
  final List<Map<String, dynamic>> _interestRateFormats = [
    {'label': 'Anual', 'value': 'annual', 'factor': 1.0},
    {'label': 'Semestral', 'value': 'semiannual', 'factor': 2.0},
    {'label': 'Trimestral', 'value': 'quarterly', 'factor': 4.0},
    {'label': 'Mensual', 'value': 'monthly', 'factor': 12.0},
    {'label': 'Diaria', 'value': 'daily', 'factor': 365.0},
  ];

  // Formato de tasa de interés seleccionado (por defecto: anual)
  Map<String, dynamic> _selectedRateFormat = {
    'label': 'Anual',
    'value': 'annual',
    'factor': 1.0,
  };

  // Controlador para tiempo en modo simple
  final _simpleTimeController = TextEditingController();

  // Agregar estas variables de estado para validación después de las variables existentes
  // Variables para validación
  final Map<String, String> _errors = {
    'capital': '',
    'tasa': '',
    'monto': '',
    'tiempo': '',
  };

  // Colores para validación
  final Color _errorColor = Colors.red;
  final Color _successColor = const Color(0xFF4CAF50);
  final Color _primaryColor = const Color(0xFF4CAF50);

  // Validar campo de capital
  void _validateCapital(String value) {
    setState(() {
      if (value.isEmpty) {
        _errors['capital'] = 'El capital es requerido';
      } else if (double.tryParse(value.replaceAll(',', '.')) == null) {
        _errors['capital'] = 'Ingrese un número válido';
      } else if (double.parse(value.replaceAll(',', '.')) <= 0) {
        _errors['capital'] = 'El capital debe ser mayor a 0';
      } else if (double.parse(value.replaceAll(',', '.')) > 1000000000) {
        _errors['capital'] = 'El valor es demasiado grande';
      } else {
        _errors['capital'] = '';
      }
    });
  }

  // Validar campo de tasa
  void _validateTasa(String value) {
    setState(() {
      if (value.isEmpty) {
        _errors['tasa'] = 'La tasa es requerida';
      } else if (double.tryParse(value.replaceAll(',', '.')) == null) {
        _errors['tasa'] = 'Ingrese un número válido';
      } else if (double.parse(value.replaceAll(',', '.')) <= 0) {
        _errors['tasa'] = 'La tasa debe ser mayor a 0';
      } else if (double.parse(value.replaceAll(',', '.')) > 100) {
        _errors['tasa'] = 'La tasa no debe exceder el 100%';
      } else {
        _errors['tasa'] = '';
      }
    });
  }

  // Validar campo de monto
  void _validateMonto(String value) {
    setState(() {
      if (value.isEmpty) {
        _errors['monto'] = 'El monto es requerido';
      } else if (double.tryParse(value.replaceAll(',', '.')) == null) {
        _errors['monto'] = 'Ingrese un número válido';
      } else if (double.parse(value.replaceAll(',', '.')) <= 0) {
        _errors['monto'] = 'El monto debe ser mayor a 0';
      } else if (double.parse(value.replaceAll(',', '.')) > 1000000000) {
        _errors['monto'] = 'El valor es demasiado grande';
      } else {
        _errors['monto'] = '';
      }
    });
  }

  // Validar campo de tiempo simple
  void _validateTiempoSimple(String value) {
    setState(() {
      if (value.isEmpty) {
        _errors['tiempo'] = 'El tiempo es requerido';
      } else if (double.tryParse(value.replaceAll(',', '.')) == null) {
        _errors['tiempo'] = 'Ingrese un número válido';
      } else if (double.parse(value.replaceAll(',', '.')) <= 0) {
        _errors['tiempo'] = 'El tiempo debe ser mayor a 0';
      } else if (double.parse(value.replaceAll(',', '.')) > 100) {
        _errors['tiempo'] = 'El valor es demasiado grande';
      } else {
        _errors['tiempo'] = '';
      }
    });
  }

  // Validar campos de tiempo avanzado
  void _validateTiempoAvanzado() {
    setState(() {
      if (_yearsController.text.isEmpty &&
          _monthsController.text.isEmpty &&
          _daysController.text.isEmpty) {
        _errors['tiempo'] = 'Ingrese al menos un valor de tiempo';
      } else {
        // Validar años
        if (_yearsController.text.isNotEmpty) {
          if (double.tryParse(_yearsController.text.replaceAll(',', '.')) ==
              null) {
            _errors['tiempo'] = 'Años: ingrese un número válido';
            return;
          } else if (double.parse(_yearsController.text.replaceAll(',', '.')) <
              0) {
            _errors['tiempo'] = 'Años: debe ser un valor positivo';
            return;
          } else if (double.parse(_yearsController.text.replaceAll(',', '.')) >
              100) {
            _errors['tiempo'] = 'Años: valor demasiado grande';
            return;
          }
        }

        // Validar meses
        if (_monthsController.text.isNotEmpty) {
          if (double.tryParse(_monthsController.text.replaceAll(',', '.')) ==
              null) {
            _errors['tiempo'] = 'Meses: ingrese un número válido';
            return;
          } else if (double.parse(_monthsController.text.replaceAll(',', '.')) <
              0) {
            _errors['tiempo'] = 'Meses: debe ser un valor positivo';
            return;
          } else if (double.parse(_monthsController.text.replaceAll(',', '.')) >
              1200) {
            _errors['tiempo'] = 'Meses: valor demasiado grande';
            return;
          }
        }

        // Validar días
        if (_daysController.text.isNotEmpty) {
          if (double.tryParse(_daysController.text.replaceAll(',', '.')) ==
              null) {
            _errors['tiempo'] = 'Días: ingrese un número válido';
            return;
          } else if (double.parse(_daysController.text.replaceAll(',', '.')) <
              0) {
            _errors['tiempo'] = 'Días: debe ser un valor positivo';
            return;
          } else if (double.parse(_daysController.text.replaceAll(',', '.')) >
              36500) {
            _errors['tiempo'] = 'Días: valor demasiado grande';
            return;
          }
        }

        _errors['tiempo'] = '';
      }
    });
  }

  // Verificar si hay errores de validación
  bool _hasValidationErrors() {
    // Determinar qué campos necesitan validación según la variable a calcular
    List<String> fieldsToValidate = [];

    switch (_variableToCalculate) {
      case 'interes':
        fieldsToValidate = ['capital', 'monto'];
        break;
      case 'capital':
        fieldsToValidate = ['monto', 'tasa', 'tiempo'];
        break;
      case 'tasa':
        fieldsToValidate = ['capital', 'monto', 'tiempo'];
        break;
      case 'tiempo':
        fieldsToValidate = ['capital', 'tasa', 'monto'];
        break;
      case 'monto':
        fieldsToValidate = ['capital', 'tasa', 'tiempo'];
        break;
    }

    // Validar los campos requeridos
    for (String field in fieldsToValidate) {
      if (field == 'capital' && _variableToCalculate != 'capital') {
        _validateCapital(_capitalController.text);
      } else if (field == 'tasa' && _variableToCalculate != 'tasa') {
        _validateTasa(_tasaController.text);
      } else if (field == 'monto' && _variableToCalculate != 'monto') {
        _validateMonto(_montoController.text);
      } else if (field == 'tiempo' && _variableToCalculate != 'tiempo') {
        if (_advancedTimeMode) {
          _validateTiempoAvanzado();
        } else {
          _validateTiempoSimple(_simpleTimeController.text);
        }
      }
    }

    // Verificar si hay errores en los campos requeridos
    for (String field in fieldsToValidate) {
      if (_errors[field]!.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  // Mostrar mensaje de error
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _errorColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Agregar listeners para validación en tiempo real
    _capitalController.addListener(
      () => _validateCapital(_capitalController.text),
    );
    _tasaController.addListener(() => _validateTasa(_tasaController.text));
    _montoController.addListener(() => _validateMonto(_montoController.text));
    _simpleTimeController.addListener(
      () => _validateTiempoSimple(_simpleTimeController.text),
    );
    _yearsController.addListener(_validateTiempoAvanzado);
    _monthsController.addListener(_validateTiempoAvanzado);
    _daysController.addListener(_validateTiempoAvanzado);
  }

  @override
  void dispose() {
    _capitalController.dispose();
    _tasaController.dispose();
    _interesController.dispose();
    _montoController.dispose();
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

  // Convertir la tasa de interés al formato anual
  double _getAnnualRate() {
    if (_tasaController.text.isEmpty) return 0;

    double inputRate =
        double.parse(_tasaController.text.replaceAll(',', '.')) / 100;
    double annualRate;

    // Si la tasa ya es anual, no necesita conversión
    if (_selectedRateFormat['value'] == 'annual') {
      annualRate = inputRate;
    } else {
      // Convertir de tasa periódica a tasa anual efectiva
      // Fórmula: (1 + i)^n - 1, donde i es la tasa periódica y n es el número de períodos por año
      annualRate = pow(1 + inputRate, _selectedRateFormat['factor']) - 1;
    }

    return annualRate;
  }

  // Obtener la tasa periódica según la frecuencia de capitalización
  double _getPeriodicRate() {
    double annualRate = _getAnnualRate();
    int periodsPerYear = _selectedFrequency['periods'];

    // Convertir tasa anual efectiva a tasa periódica
    // Fórmula: (1 + i)^(1/n) - 1, donde i es la tasa anual y n es el número de períodos por año
    return pow(1 + annualRate, 1 / periodsPerYear) - 1;
  }

  // Reemplazar el método _calculate() con esta versión mejorada
  void _calculate() {
    // Ocultar el teclado
    FocusScope.of(context).unfocus();

    // Validar campos antes de calcular
    if (_hasValidationErrors()) {
      // Buscar el primer error para mostrarlo
      String errorMessage = '';
      _errors.forEach((field, error) {
        if (error.isNotEmpty && errorMessage.isEmpty) {
          errorMessage = error;
        }
      });

      _showErrorMessage(errorMessage);
      return;
    }

    try {
      switch (_variableToCalculate) {
        case 'interes':
          _calculateInteres();
          break;
        case 'capital':
          _calculateCapital();
          break;
        case 'tasa':
          _calculateTasa();
          break;
        case 'tiempo':
          _calculateTiempo();
          break;
        case 'monto':
          _calculateMonto();
          break;
      }
    } catch (e) {
      _showErrorMessage('Error en el cálculo: $e');
    }
  }

  // Calcular Interés Compuesto (IC = MC - C)
  void _calculateInteres() {
    // Validar que los campos principales tengan valores
    if (_capitalController.text.isEmpty || _montoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de capital y monto compuesto',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convertir valores a números
    final capital = double.parse(_capitalController.text.replaceAll(',', '.'));
    final montoCompuesto = double.parse(
      _montoController.text.replaceAll(',', '.'),
    );

    // Calcular interés compuesto usando la fórmula IC = MC - C
    final interesCompuesto = montoCompuesto - capital;

    setState(() {
      _calculatedValue = interesCompuesto;
      _totalAmount = montoCompuesto;
      _hasCalculated = true;
    });

    // Desplazar hacia abajo para mostrar los resultados
    _scrollToResults();
  }

  // Calcular Capital (C = MC / (1+i)^n)
  void _calculateCapital() {
    // Validar que los campos necesarios tengan valores
    if (_montoController.text.isEmpty || _tasaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de monto compuesto y tasa',
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

    // Convertir valores a números
    final montoCompuesto = double.parse(
      _montoController.text.replaceAll(',', '.'),
    );

    // Obtener tiempo en años
    final timeInYears = _calculateTimeInYears();

    // Obtener número de períodos de capitalización
    final periodsPerYear = _selectedFrequency['periods'];
    final totalPeriods = timeInYears * periodsPerYear;

    // Calcular tasa por período
    final tasaPorPeriodo = _getPeriodicRate();

    // Calcular capital usando la fórmula C = MC / (1+i)^n
    final capital = montoCompuesto / pow(1 + tasaPorPeriodo, totalPeriods);

    // Calcular interés compuesto
    final interesCompuesto = montoCompuesto - capital;

    setState(() {
      _calculatedValue = capital;
      _totalAmount = montoCompuesto;
      _hasCalculated = true;
    });

    // Desplazar hacia abajo para mostrar los resultados
    _scrollToResults();
  }

  // Calcular Tasa de interés (i = (MC/C)^(1/n) - 1)
  void _calculateTasa() {
    // Validar que los campos necesarios tengan valores
    if (_capitalController.text.isEmpty || _montoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de capital y monto compuesto',
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

    // Convertir valores a números
    final capital = double.parse(_capitalController.text.replaceAll(',', '.'));
    final montoCompuesto = double.parse(
      _montoController.text.replaceAll(',', '.'),
    );

    // Obtener tiempo en años
    final timeInYears = _calculateTimeInYears();

    // Obtener número de períodos de capitalización
    final periodsPerYear = _selectedFrequency['periods'];
    final totalPeriods = timeInYears * periodsPerYear;

    // Calcular tasa de interés por período usando la fórmula i = (MC/C)^(1/n) - 1
    final tasaPorPeriodo = pow(montoCompuesto / capital, 1 / totalPeriods) - 1;

    // Convertir a tasa anual efectiva

    // Convertir a la tasa en el formato seleccionado por el usuario
    double tasaEnFormatoSeleccionado;
    if (_selectedRateFormat['value'] == 'annual') {
      tasaEnFormatoSeleccionado = pow(1 + tasaPorPeriodo, periodsPerYear) - 1;
    } else {
      // Convertir de tasa anual efectiva a tasa periódica en el formato seleccionado
      tasaEnFormatoSeleccionado =
          pow(
            1 + pow(1 + tasaPorPeriodo, periodsPerYear) - 1,
            1 / _selectedRateFormat['factor'],
          ) -
          1;
    }

    // Calcular interés compuesto
    final interesCompuesto = montoCompuesto - capital;

    setState(() {
      _calculatedValue =
          tasaEnFormatoSeleccionado * 100; // Convertir a porcentaje
      _totalAmount = montoCompuesto;
      _hasCalculated = true;
    });

    // Desplazar hacia abajo para mostrar los resultados
    _scrollToResults();
  }

  // Calcular Tiempo (n = (Log MC - Log C) / Log(1+i))
  void _calculateTiempo() {
    // Validar que los campos necesarios tengan valores
    if (_capitalController.text.isEmpty ||
        _tasaController.text.isEmpty ||
        _montoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa los campos de capital, tasa y monto compuesto',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convertir valores a números
    final capital = double.parse(_capitalController.text.replaceAll(',', '.'));
    final montoCompuesto = double.parse(
      _montoController.text.replaceAll(',', '.'),
    );

    // Obtener períodos de capitalización por año
    final periodsPerYear = _selectedFrequency['periods'];

    // Calcular tasa por período
    final tasaPorPeriodo = _getPeriodicRate();

    // Calcular tiempo en períodos usando la fórmula n = (Log MC - Log C) / Log(1+i)
    final periodsTime =
        (log(montoCompuesto) - log(capital)) / log(1 + tasaPorPeriodo);

    // Convertir a tiempo en años
    final timeInYears = periodsTime / periodsPerYear;

    // Calcular interés compuesto
    final interesCompuesto = montoCompuesto - capital;

    setState(() {
      _calculatedValue = timeInYears;
      _totalAmount = montoCompuesto;
      _hasCalculated = true;
    });

    // Desplazar hacia abajo para mostrar los resultados
    _scrollToResults();
  }

  // Calcular Monto Compuesto (MC = C(1+i)^n)
  void _calculateMonto() {
    // Validar que los campos necesarios tengan valores
    if (_capitalController.text.isEmpty || _tasaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor completa los campos de capital y tasa'),
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

    // Convertir valores a números
    final capital = double.parse(_capitalController.text.replaceAll(',', '.'));

    // Obtener tiempo en años
    final timeInYears = _calculateTimeInYears();

    // Obtener número de períodos de capitalización
    final periodsPerYear = _selectedFrequency['periods'];
    final totalPeriods = timeInYears * periodsPerYear;

    // Calcular tasa por período
    final tasaPorPeriodo = _getPeriodicRate();

    // Calcular monto compuesto usando la fórmula MC = C(1+i)^n
    final montoCompuesto = capital * pow(1 + tasaPorPeriodo, totalPeriods);

    // Calcular interés compuesto
    final interesCompuesto = montoCompuesto - capital;

    setState(() {
      _calculatedValue = montoCompuesto;
      _totalAmount = montoCompuesto;
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
      _capitalController.clear();
      _tasaController.clear();
      _interesController.clear();
      _montoController.clear();
      _simpleTimeController.clear();
      _yearsController.clear();
      _monthsController.clear();
      _daysController.clear();
      _calculatedValue = 0.0;
      _totalAmount = 0.0;
      _hasCalculated = false;

      // Limpiar errores
      _errors['capital'] = '';
      _errors['tasa'] = '';
      _errors['monto'] = '';
      _errors['tiempo'] = '';
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
    if (_variableToCalculate == 'tiempo') {
      // Si estamos calculando el tiempo, mostrar el resultado calculado
      double years = _calculatedValue;
      int fullYears = years.floor();
      double remainingMonths = (years - fullYears) * 12;
      int months = remainingMonths.floor();
      double remainingDays = (remainingMonths - months) * 30; // Aproximación
      int days = remainingDays.round();

      List<String> parts = [];
      if (fullYears > 0) {
        parts.add('$fullYears año${fullYears == 1 ? '' : 's'}');
      }
      if (months > 0) {
        parts.add('$months mes${months == 1 ? '' : 'es'}');
      }
      if (days > 0) {
        parts.add('$days día${days == 1 ? '' : 's'}');
      }

      return parts.join(', ');
    } else {
      // Si no estamos calculando el tiempo, mostrar los valores ingresados
      if (_advancedTimeMode) {
        List<String> parts = [];

        if (_yearsController.text.isNotEmpty &&
            double.parse(_yearsController.text.replaceAll(',', '.')) > 0) {
          double years = double.parse(
            _yearsController.text.replaceAll(',', '.'),
          );
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
  }

  // Obtener el título del resultado según la variable calculada
  String _getResultTitle() {
    switch (_variableToCalculate) {
      case 'interes':
        return 'Interés compuesto (IC):';
      case 'capital':
        return 'Capital (C):';
      case 'tasa':
        return 'Tasa de interés ${_selectedRateFormat['label'].toLowerCase()} (i):';
      case 'tiempo':
        return 'Tiempo (n):';
      case 'monto':
        return 'Monto compuesto (MC):';
      default:
        return '';
    }
  }

  // Obtener el valor formateado del resultado
  String _getFormattedResult() {
    switch (_variableToCalculate) {
      case 'interes':
      case 'capital':
      case 'monto':
        return '\$${_formatNumber(_calculatedValue)}';
      case 'tasa':
        return '${_formatNumber(_calculatedValue)}%';
      case 'tiempo':
        return '${_formatNumber(_calculatedValue)} años';
      default:
        return '';
    }
  }

  // Obtener el ícono para el resultado
  IconData _getResultIcon() {
    switch (_variableToCalculate) {
      case 'interes':
        return Icons.trending_up;
      case 'capital':
        return Icons.attach_money;
      case 'tasa':
        return Icons.percent;
      case 'tiempo':
        return Icons.access_time;
      case 'monto':
        return Icons.account_balance_wallet;
      default:
        return Icons.calculate;
    }
  }

  // Método para calcular el interés de manera segura
  double _getInterestAmount() {
    try {
      if (_variableToCalculate == 'interes') {
        return _calculatedValue;
      } else if (_variableToCalculate == 'monto') {
        return _calculatedValue -
            double.parse(_capitalController.text.replaceAll(',', '.'));
      } else {
        // Para otros cálculos, el interés es la diferencia entre monto y capital
        return _totalAmount -
            (_variableToCalculate == 'capital'
                ? _calculatedValue
                : double.parse(_capitalController.text.replaceAll(',', '.')));
      }
    } catch (e) {
      // En caso de error, devolver 0
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Interés Compuesto',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
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
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.auto_graph,
                            color: const Color(0xFF4CAF50),
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 15),
                        Text(
                          '¿Qué es el Interés Compuesto?',
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
                      'El interés compuesto es aquel que se calcula sobre el capital inicial más los intereses acumulados en períodos anteriores. A diferencia del interés simple, el interés compuesto genera "interés sobre interés", lo que resulta en un crecimiento exponencial del capital a lo largo del tiempo.',
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
                        color: const Color(0xFF4CAF50).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: const Color(0xFF4CAF50),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Fórmula',
                              style: TextStyle(
                                color: const Color(0xFF4CAF50),
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
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
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
                              'A = P(1 + r/n)^(nt)',
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
                              _buildFormulaItem('A', 'Monto futuro'),
                              _buildFormulaItem('P', 'Capital inicial'),
                              _buildFormulaItem('r', 'Tasa de interés anual'),
                              _buildFormulaItem('n', 'Períodos por año'),
                              _buildFormulaItem('t', 'Tiempo en años'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFF4CAF50),
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'El interés generado será: A - P',
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
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calculate_rounded,
                            color: const Color(0xFF4CAF50),
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

                    // Selector de variable a calcular (ahora como menú desplegable)
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
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey[300]!),
                            color: const Color(0xFF4CAF50).withOpacity(0.05),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _variableToCalculate,
                              icon: Icon(
                                Icons.arrow_drop_down_circle_outlined,
                                color: const Color(0xFF4CAF50),
                              ),
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(10),
                              items:
                                  _calculationOptions.map((option) {
                                    return DropdownMenuItem<String>(
                                      value: option['value'],
                                      child: Text(
                                        option['label'],
                                        style: TextStyle(
                                          color: const Color(0xFF151616),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _variableToCalculate = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Frecuencia de capitalización
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
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey[300]!),
                            color: const Color(0xFF4CAF50).withOpacity(0.05),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedFrequency['value'],
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: const Color(0xFF4CAF50),
                              ),
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(10),
                              items:
                                  _compoundingFrequencies.map((frequency) {
                                    return DropdownMenuItem<String>(
                                      value: frequency['value'],
                                      child: Text(
                                        frequency['label'],
                                        style: TextStyle(
                                          color: const Color(0xFF151616),
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedFrequency = _compoundingFrequencies
                                      .firstWhere(
                                        (frequency) =>
                                            frequency['value'] == newValue,
                                      );
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Formato de tasa de interés (oculto cuando se calcula la tasa)
                    if (_variableToCalculate != 'tasa') ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Formato de tasa de interés',
                            style: TextStyle(
                              color: const Color(0xFF293431),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey[300]!),
                              color: const Color(0xFF4CAF50).withOpacity(0.05),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedRateFormat['value'],
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: const Color(0xFF4CAF50),
                                ),
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(10),
                                items:
                                    _interestRateFormats.map((format) {
                                      return DropdownMenuItem<String>(
                                        value: format['value'],
                                        child: Text(
                                          format['label'],
                                          style: TextStyle(
                                            color: const Color(0xFF151616),
                                            fontSize: 16,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedRateFormat = _interestRateFormats
                                        .firstWhere(
                                          (format) =>
                                              format['value'] == newValue,
                                        );
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Campo de capital (excepto cuando se calcula C)
                    if (_variableToCalculate != 'capital') ...[
                      _buildInputField(
                        controller: _capitalController,
                        label: 'Capital inicial (C)',
                        hint: 'Ej: 1000000',
                        prefixIcon: Icons.attach_money,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        color: const Color(0xFF4CAF50),
                        errorKey: 'capital',
                      ),
                      const SizedBox(height: 15),
                    ],

                    // Campo de tasa de interés (excepto cuando se calcula i)
                    if (_variableToCalculate != 'tasa') ...[
                      _buildInputField(
                        controller: _tasaController,
                        label:
                            'Tasa de interés ${_selectedRateFormat['label'].toLowerCase()} (i) %',
                        hint: 'Ej: 5',
                        prefixIcon: Icons.percent,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        color: const Color(0xFF4CAF50),
                        errorKey: 'tasa',
                      ),
                      const SizedBox(height: 15),
                    ],

                    // Campo de monto compuesto (excepto cuando se calcula MC)
                    if (_variableToCalculate != 'monto') ...[
                      _buildInputField(
                        controller: _montoController,
                        label: 'Monto compuesto (MC)',
                        hint: 'Ej: 1500000',
                        prefixIcon: Icons.account_balance_wallet,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        color: const Color(0xFF4CAF50),
                        errorKey: 'monto',
                      ),
                      const SizedBox(height: 15),
                    ],

                    // Selector de modo de tiempo (excepto cuando se calcula t)
                    if (_variableToCalculate != 'tiempo') ...[
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
                                    // Limpiar errores de tiempo al cambiar el modo
                                    _errors['tiempo'] = '';
                                  });
                                },
                                activeColor: const Color(0xFF4CAF50),
                                activeTrackColor: const Color(
                                  0xFF9C27B0,
                                ).withOpacity(0.3),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                      controller: _simpleTimeController,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: InputDecoration(
                                        hintText: 'Ej: 2',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                        ),
                                        prefixIcon: Icon(
                                          Icons.access_time,
                                          color:
                                              _errors['tiempo']!.isNotEmpty &&
                                                      _simpleTimeController
                                                          .text
                                                          .isNotEmpty
                                                  ? _errorColor
                                                  : const Color(0xFF4CAF50),
                                        ),
                                        suffixIcon:
                                            _simpleTimeController
                                                    .text
                                                    .isNotEmpty
                                                ? Icon(
                                                  _errors['tiempo']!.isNotEmpty
                                                      ? Icons.error_outline
                                                      : Icons
                                                          .check_circle_outline,
                                                  color:
                                                      _errors['tiempo']!
                                                              .isNotEmpty
                                                          ? _errorColor
                                                          : _successColor,
                                                )
                                                : null,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          borderSide:
                                              _simpleTimeController
                                                      .text
                                                      .isNotEmpty
                                                  ? BorderSide(
                                                    color:
                                                        _errors['tiempo']!
                                                                .isNotEmpty
                                                            ? _errorColor
                                                            : _successColor,
                                                    width: 1.5,
                                                  )
                                                  : BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          borderSide: BorderSide(
                                            color:
                                                _errors['tiempo']!.isNotEmpty
                                                    ? _errorColor
                                                    : const Color(0xFF4CAF50),
                                            width: 2,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
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
                                  if (_errors['tiempo']!.isNotEmpty &&
                                      _simpleTimeController.text.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 5,
                                        left: 5,
                                      ),
                                      child: Text(
                                        _errors['tiempo']!,
                                        style: TextStyle(
                                          color: _errorColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
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
                                      color: const Color(0xFF4CAF50),
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
                      // Reemplazar el bloque de código para el modo de tiempo avanzado
                      if (_advancedTimeMode) ...[
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color:
                                  _errors['tiempo']!.isNotEmpty
                                      ? _errorColor.withOpacity(0.5)
                                      : const Color(
                                        0xFF9C27B0,
                                      ).withOpacity(0.3),
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
                                              color: const Color(0xFF4CAF50),
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
                                              color: const Color(0xFF4CAF50),
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
                                              color: const Color(0xFF4CAF50),
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

                              // Mensaje de error para tiempo avanzado
                              if (_errors['tiempo']!.isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _errorColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _errorColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: _errorColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errors['tiempo']!,
                                          style: TextStyle(
                                            color: _errorColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                // Nota informativa
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: const Color(0xFF4CAF50),
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
                              backgroundColor: const Color(0xFF4CAF50),
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
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.analytics_rounded,
                              color: const Color(0xFF4CAF50),
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
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: _buildResultItem(
                          label: _getResultTitle(),
                          value: _getFormattedResult(),
                          icon: _getResultIcon(),
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Interés generado (si no es lo que se calculó)
                      if (_variableToCalculate != 'interes') ...[
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: _buildResultItem(
                            label: 'Interés generado:',
                            value: '\$${_formatNumber(_getInterestAmount())}',
                            icon: Icons.trending_up,
                            color: const Color(0xFF293431),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],

                      // Detalles del cálculo
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: const Color(0xFF4CAF50),
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
                                  // Mostrar capital (si no es lo que se calculó)
                                  if (_variableToCalculate != 'capital' &&
                                      _capitalController.text.isNotEmpty) ...[
                                    Text(
                                      'Capital inicial: \$${_formatNumber(double.parse(_capitalController.text.replaceAll(',', '.')))}',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Divider(height: 20),
                                  ],

                                  // Mostrar tasa de interés (si no es lo que se calculó)
                                  if (_variableToCalculate != 'tasa' &&
                                      _tasaController.text.isNotEmpty) ...[
                                    Text(
                                      'Tasa de interés ${_selectedRateFormat['label'].toLowerCase()}: ${_tasaController.text.replaceAll(',', '.')}%',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Tasa efectiva por período: ${(_getPeriodicRate() * 100).toStringAsFixed(4)}%',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Divider(height: 20),
                                  ],

                                  // Mostrar monto compuesto (si no es lo que se calculó)
                                  if (_variableToCalculate != 'monto' &&
                                      _montoController.text.isNotEmpty) ...[
                                    Text(
                                      'Monto compuesto: \$${_formatNumber(double.parse(_montoController.text.replaceAll(',', '.')))}',
                                      style: TextStyle(
                                        color: const Color(0xFF293431),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Divider(height: 20),
                                  ],

                                  // Mostrar tiempo (si no es lo que se calculó)
                                  if (_variableToCalculate != 'tiempo') ...[
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

                                  // Frecuencia de capitalización
                                  Text(
                                    'Frecuencia de capitalización: ${_selectedFrequency['label']} (${_selectedFrequency['periods']} período(s) por año)',
                                    style: TextStyle(
                                      color: const Color(0xFF293431),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
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
                              const Color(0xFF4CAF50).withOpacity(0.1),
                              const Color(0xFF4CAF50).withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: const Color(0xFF4CAF50),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'El interés compuesto genera un crecimiento exponencial del capital a lo largo del tiempo, ya que se calcula sobre el capital inicial más los intereses acumulados en períodos anteriores.',
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
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  color: const Color(0xFF4CAF50),
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

  // Modificar el método _buildInputField para mostrar errores de validación
  // Widget para los campos de entrada
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    required TextInputType keyboardType,
    required Color color,
    String? errorKey,
  }) {
    // Determinar el color del borde basado en el estado de validación
    Color borderColor = color;
    if (errorKey != null &&
        _errors[errorKey]!.isNotEmpty &&
        controller.text.isNotEmpty) {
      borderColor = _errorColor;
    } else if (controller.text.isNotEmpty) {
      borderColor = _successColor;
    }

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
              prefixIcon: Icon(
                prefixIcon,
                color:
                    errorKey != null &&
                            _errors[errorKey]!.isNotEmpty &&
                            controller.text.isNotEmpty
                        ? _errorColor
                        : color,
              ),
              suffixIcon:
                  controller.text.isNotEmpty
                      ? Icon(
                        errorKey != null && _errors[errorKey]!.isNotEmpty
                            ? Icons.error_outline
                            : Icons.check_circle_outline,
                        color:
                            errorKey != null && _errors[errorKey]!.isNotEmpty
                                ? _errorColor
                                : _successColor,
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    controller.text.isNotEmpty
                        ? BorderSide(color: borderColor, width: 1.5)
                        : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: borderColor, width: 2),
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
        if (errorKey != null &&
            _errors[errorKey]!.isNotEmpty &&
            controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 5),
            child: Text(
              _errors[errorKey]!,
              style: TextStyle(color: _errorColor, fontSize: 12),
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
